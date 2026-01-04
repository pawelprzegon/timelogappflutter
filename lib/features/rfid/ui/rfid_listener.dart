import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rfid_reader_provider.dart';
import '../state/rfid_controller.dart';

class RfidListener extends ConsumerWidget {
  const RfidListener({super.key});

  @override
  Widget build(context, ref) {
    ref.listen(rfidUidStreamProvider, (prev, next) {
      next.whenData((uid) {
        ref.read(rfidControllerProvider.notifier).handleUid(uid);
      });
    });

    return const SizedBox.shrink();
  }
}
