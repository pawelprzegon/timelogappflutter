package com.gms.usbnfcreader

import androidx.annotation.NonNull

import android.app.Activity
import android.content.IntentFilter
import android.content.Intent
import android.hardware.usb.UsbManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import com.acs.smartcard.Reader
import io.flutter.plugin.common.MethodChannel.Result
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.hardware.usb.UsbDevice
import android.util.Log
import java.lang.Exception
import android.os.Build
import androidx.core.content.ContextCompat

/** UsbnfcreaderPlugin */
class UsbnfcreaderPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "USB_NFC_READER"
    }

    private lateinit var channel : MethodChannel
    private lateinit var activity: Activity
    private lateinit var reader: Reader
    private lateinit var usbManager: UsbManager
    private lateinit var context: Context

    // akcja będzie inicjalizowana po onAttachedToEngine (mamy context)
    private var actionUsbPermission: String = "USB_PERMISSION"

    private var turnOffBuzzer = false

    fun hexToDecimal(hex: String): Int = hex.toInt(16)

    private fun bytesToHex(bytes: ByteArray): String =
        bytes.joinToString("") { String.format("%02x", it) }

    private fun bytesToDecimalArray(bytes: ByteArray): Array<Int> {
        var list = arrayOf<Int>()
        for (b in bytes) {
            val currentValue = String.format("%02x", b)
            list += hexToDecimal(currentValue)
        }
        return list
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "usbnfcreader")
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        reader = Reader(usbManager)

        // unikalna akcja per aplikacja
        actionUsbPermission = "${context.packageName}.USB_PERMISSION"
    }

    private fun registerReceiverCompat(receiver: BroadcastReceiver, filter: IntentFilter) {
        if (Build.VERSION.SDK_INT >= 33) {
            ContextCompat.registerReceiver(
                context,
                receiver,
                filter,
                ContextCompat.RECEIVER_NOT_EXPORTED
            )
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(receiver, filter)
        }
    }

    private val receiverPermission = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.d(TAG, "receiverPermission.onReceive action=${intent.action} " +
                    "hasGrantedExtra=${intent.hasExtra(UsbManager.EXTRA_PERMISSION_GRANTED)}")

            val device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE) as? UsbDevice
            val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)

            if (granted && device != null) {
                Log.d(TAG, "Permission granted, opening connection to reader ...")
                try {
                    reader.open(device)
                    Log.d(TAG, "Reader is connected")
                } catch (e: Exception) {
                    Log.e(TAG, "reader.open failed: ${e.message}")
                }
            } else {
                Log.d(TAG, "Permission denied OR device null (granted=$granted, device=$device)")
            }
        }
    }

    private val receiverDetached = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val device = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE) as? UsbDevice
            if (device != null && device == reader.device) {
                Log.d(TAG,"Reader detached")
                try { reader.close() } catch (_: Exception) {}

                channel.invokeMethod("onReaderDetached", null)

                val filterAttached = IntentFilter().apply {
                    addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
                }
                registerReceiverCompat(receiverAttached, filterAttached)
            }
        }
    }

    private val receiverAttached = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.d(TAG, "USB Attached")
            channel.invokeMethod("onReaderAttached", null)
            startNFCScanner()
        }
    }

    private fun pickAcrDevice(): UsbDevice? {
        // Preferuj ACS (ACR122U). VendorId ACS: 0x072F
        val devices = usbManager.deviceList.values.toList()
        return devices.firstOrNull { it.vendorId == 0x072F } ?: devices.firstOrNull()
    }

    private fun startNFCScanner() {
        val device = pickAcrDevice()

        if (device == null) {
            Log.d("startNFCScanner", "no device detected")
            val filterAttached = IntentFilter().apply {
                addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            }
            registerReceiverCompat(receiverAttached, filterAttached)
            return
        }

        Log.d(TAG, "device detected vendorId=${device.vendorId} productId=${device.productId}")

        // rejestrujemy receivery (permission + detach)
        val filterPermission = IntentFilter().apply { addAction(actionUsbPermission) }
        registerReceiverCompat(receiverPermission, filterPermission)

        val filterDetached = IntentFilter().apply { addAction(UsbManager.ACTION_USB_DEVICE_DETACHED) }
        registerReceiverCompat(receiverDetached, filterDetached)

        // Jeśli permission już jest, nie prosimy drugi raz — tylko otwieramy.
        if (usbManager.hasPermission(device)) {
            Log.d(TAG, "Already has USB permission -> opening reader")
            try {
                reader.open(device)
                Log.d(TAG, "Reader is connected")
            } catch (e: Exception) {
                Log.e(TAG, "reader.open failed: ${e.message}")
            }
            return
        }

        Log.d(TAG, "Requesting USB permission...")

        // Jawny intent + MUTABLE (ważne dla EXTRA_PERMISSION_GRANTED)
        val usbIntent = Intent(actionUsbPermission).apply {
            setPackage(context.packageName)
        }

        val piFlags =
            PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0)

        val permissionIntent = PendingIntent.getBroadcast(context, 0, usbIntent, piFlags)
        usbManager.requestPermission(device, permissionIntent)
    }

    private fun silentBuzzer(reader: Reader) {
        val command = byteArrayOf(0xFF.toByte(), 0x00.toByte(), 0x52.toByte(), 0x00.toByte(), 0x00.toByte())
        val response = ByteArray(256)
        reader.transmit(0, command, command.size, response, response.size)
    }

    private fun alertSuccess(reader: Reader) {
        try {
            val binaryValue = "10001110".toInt(2)
            val command = byteArrayOf(
                0xFF.toByte(), 0x00.toByte(), 0x40.toByte(), binaryValue.toByte(), 0x04.toByte(),
                0x01.toByte(), 0x01.toByte(), 0x01.toByte(), 0x02.toByte()
            )
            val response = ByteArray(256)
            reader.transmit(0, command, command.size, response, response.size)
        } catch (exc: Exception) {
            Log.e(TAG, "Failed at alertSuccess: ${exc.message}")
        }
    }

    private fun alertError(reader: Reader) {
        try {
            val binaryValue = "01001101".toInt(2)
            val command = byteArrayOf(
                0xFF.toByte(), 0x00.toByte(), 0x40.toByte(), binaryValue.toByte(), 0x04.toByte(),
                0x01.toByte(), 0x01.toByte(), 0x02.toByte(), 0x02.toByte()
            )
            val response = ByteArray(256)
            reader.transmit(0, command, command.size, response, response.size)
        } catch (exc: Exception) {
            Log.e(TAG, "Failed at alertError: ${exc.message}")
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startSession" -> {
                reader.setOnStateChangeListener { _, _, currState ->
                    if (currState == Reader.CARD_PRESENT) {
                        Log.d(TAG, "Found a card")

                        val command = byteArrayOf(0xFF.toByte(), 0xCA.toByte(), 0x00.toByte(), 0x00.toByte(), 0x00.toByte())
                        reader.power(0, Reader.CARD_WARM_RESET)
                        reader.setProtocol(0, Reader.PROTOCOL_T0 or Reader.PROTOCOL_T1)

                        if (turnOffBuzzer) silentBuzzer(reader)

                        val response = ByteArray(256)
                        val responseLength: Int = reader.transmit(0, command, command.size, response, response.size)

                        if (responseLength >= 2) {
                            val idBytes = response.copyOf(responseLength - 2)
                            val idNumber = bytesToDecimalArray(idBytes)
                            val idHex = bytesToHex(idBytes)

                            activity.runOnUiThread {
                                val payload = mapOf(
                                    "idNumber" to idNumber.joinToString(","),
                                    "idHex" to idHex
                                )
                                channel.invokeMethod("onDiscovered", payload)
                            }

                            Log.d(TAG, "Success getting id : ${idNumber.joinToString(",")}")
                        } else {
                            Log.d(TAG, "Failed getting id")
                        }
                    }
                }

                startNFCScanner()
                result.success(null)
            }

            "stopSession" -> {
                try { reader.close() } catch (_: Exception) {}
                result.success(null)
            }

            "alertSuccess" -> {
                alertSuccess(reader)
                result.success(null)
            }

            "alertError" -> {
                alertError(reader)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun unregisterAll() {
        try { context.unregisterReceiver(receiverAttached) } catch (_: Exception) {}
        try { context.unregisterReceiver(receiverDetached) } catch (_: Exception) {}
        try { context.unregisterReceiver(receiverPermission) } catch (_: Exception) {}
        try { reader.close() } catch (_: Exception) {}
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        unregisterAll()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivityForConfigChanges() {}
}
