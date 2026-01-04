import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../home/state/input_coordinator.dart';
import '../../session/model/auth_input.dart';
import '../../session/state/session_controller.dart';

class QrPane extends ConsumerStatefulWidget {
  const QrPane({super.key});

  @override
  ConsumerState<QrPane> createState() => _QrPaneState();
}

class _QrPaneState extends ConsumerState<QrPane> {
  late final MobileScannerController _controller;
  ProviderSubscription<InputCoordinatorState>? _inputSub;

  Timer? _ticker;
  bool _handlingDetect = false;

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      autoStart: false,
      facing: CameraFacing.front, // ✅ przednia kamera
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );

    // Reagujemy na włączenie/wyłączenie kamery przez InputCoordinator
    _inputSub = ref.listenManual<InputCoordinatorState>(
      inputCoordinatorProvider,
          (prev, next) {
        final prevActive = prev?.cameraActive ?? false;
        final nextActive = next.cameraActive;

        if (!prevActive && nextActive) {
          _startTicker();
          unawaited(_safeStart());
        } else if (prevActive && !nextActive) {
          _stopTicker();
          unawaited(_safeStop());
        }
      },
    );

    // Jeśli kamera już aktywna po pierwszym buildzie – startujemy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final input = ref.read(inputCoordinatorProvider);
      if (input.cameraActive) {
        _startTicker();
        unawaited(_safeStart());
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {}); // odświeża secondsLeft
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _safeStart() async {
    final v = _controller.value;

    // ✅ chroni przed controllerInitializing
    if (v.isRunning || v.isStarting) return;

    try {
      await _controller.start();
    } catch (_) {
      // ignorujemy — nie crashujemy apki
    }
  }

  Future<void> _safeStop() async {
    final v = _controller.value;

    // jeśli już nie działa, nie rób nic
    if (!v.isRunning && !v.isStarting) return;

    try {
      await _controller.stop();
    } catch (_) {
      // ignorujemy — nie crashujemy apki
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handlingDetect) return;

    final code = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (code == null || code.isEmpty) return;

    _handlingDetect = true;

    // 1) natychmiast wracamy do PIN (to też wyłączy kamerę przez coordinator)
    ref.read(inputCoordinatorProvider.notifier).showPin();

    // 2) 2 requesty + modal
    unawaited(
      ref.read(sessionControllerProvider.notifier).openFromAuth(
        AuthInput.qr(code),
      ),
    );

    // odblokowanie skanowania po chwili (gdy user wróci do QR później)
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _handlingDetect = false;
    });
  }

  @override
  void dispose() {
    _stopTicker();
    _inputSub?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(inputCoordinatorProvider);
    final secondsLeft = input.secondsLeft;

    return Stack(
      children: [
        Positioned.fill(
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
        ),

        // Overlay z licznikiem
        Positioned(
          top: 12,
          left: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Powrót do PIN za: ${secondsLeft}s',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
