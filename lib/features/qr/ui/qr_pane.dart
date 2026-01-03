import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/state/input_coordinator.dart';

class QrPane extends ConsumerWidget {
  const QrPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(inputCoordinatorProvider);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code_scanner, size: 72, color: Colors.white70),
          const SizedBox(height: 12),
          const Text(
            'QR aktywne (placeholder)',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            input.qrEndsAt == null
                ? 'Za chwilę wrócimy do PIN'
                : 'Wracamy do PIN o: ${_hhmmss(input.qrEndsAt!)}',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  String _hhmmss(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
