import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/state/input_coordinator.dart';
import '../state/qr_controller.dart';

class QrPane extends ConsumerWidget {
  const QrPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coord = ref.watch(inputCoordinatorProvider);
    final qr = ref.watch(qrControllerProvider);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            qr.cameraActive ? 'Kamera aktywna' : 'Kamera wyłączona',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            'Powrót do PIN za: ${coord.secondsLeft}s',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => ref.read(inputCoordinatorProvider.notifier).showPin(),
            child: const Text('Zamknij QR (wróć do PIN)'),
          ),
        ],
      ),
    );
  }
}
