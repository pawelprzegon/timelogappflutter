import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rfid_reader_provider.dart';
import 'rfid_controller.dart';

final rfidBootstrapProvider = Provider<void>((ref) {
  ref.listen(rfidUidStreamProvider, (prev, next) {
    next.whenData((uid) {
      ref.read(rfidControllerProvider.notifier).handleUid(uid);
    });
  });
});
