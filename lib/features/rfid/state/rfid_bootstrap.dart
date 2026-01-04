import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rfid_reader_provider.dart';
import 'rfid_controller.dart';

final rfidBootstrapProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<String>>(rfidUidStreamProvider, (prev, next) {
    next.whenData((uid) {
      // Nie blokujemy UI – controller sam sprawdzi gate.
      unawaited(ref.read(rfidControllerProvider.notifier).handleUid(uid));
    });
  });
});
