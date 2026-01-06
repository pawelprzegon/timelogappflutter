import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/kiosk/wakelock_controller.dart';

class WakelockToggle extends ConsumerWidget {
  const WakelockToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(wakelockControllerProvider);

    ref.listen(wakelockControllerProvider, (prev, next) {
      final err = next.error;
      if (err != null && err.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wakelock error: $err')),
        );
      }
    });

    return Row(
      children: [
        Expanded(
          child: Text(
            'Ekran zawsze włączony',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (s.isBusy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const SizedBox(width: 10),
        Switch(
          value: s.enabled,
          onChanged: s.isBusy ? null : (v) => ref.read(wakelockControllerProvider.notifier).setEnabled(v),
        ),
      ],
    );
  }
}
