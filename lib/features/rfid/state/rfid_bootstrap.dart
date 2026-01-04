import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rfid_reader_provider.dart';
import '../../home/state/input_coordinator.dart';

final rfidBootstrapProvider = Provider<void>((ref) {
  ref.listen(rfidUidStreamProvider, (prev, next) {
    next.whenData((uid) {
      unawaited(ref.read(inputCoordinatorProvider.notifier).onRfidScanned(uid));
    });
  });
});
