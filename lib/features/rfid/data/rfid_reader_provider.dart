import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usbnfcreader/usbnfcreader.dart';

import '../state/rfid_controller.dart';

/// Stream UID-ów z ACR122U (np. "04A1B2C3D4").

final rfidUidStreamProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>.broadcast();
  final reader = Usbnfcreader.instance;

  reader.startSession(
    autoConnect: true,

    // ✅ plugin chce Future<void>
    onDiscovered: (tag) async {
      if (controller.isClosed) return;
      final uid = tag.hexId.toUpperCase();
      // ignore: avoid_print
      print('RFID UID (dart): $uid');
      controller.add(uid);
    },

    onReaderAttached: () async {
      if (controller.isClosed) return;
      // ignore: avoid_print
      print('ACR122U attached');
      ref.read(rfidControllerProvider.notifier).setConnected(true);
    },

    onReaderDetached: () async {
      if (controller.isClosed) return;
      // ignore: avoid_print
      print('ACR122U detached');
      ref.read(rfidControllerProvider.notifier).setConnected(false);
    },
  );

  ref.onDispose(() {
    ref.read(rfidControllerProvider.notifier).setConnected(false);
    reader.stopSession();
    controller.close();
  });

  return controller.stream;
});
