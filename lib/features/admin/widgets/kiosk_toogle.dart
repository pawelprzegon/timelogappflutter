import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/kiosk_controller.dart';


class KioskToggle extends ConsumerWidget {
  const KioskToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(kioskControllerProvider);

    ref.listen(kioskControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kiosk: ${next.error}')),
        );
      }
    });

    return Row(
      children: [
        Expanded(
          child: Text(
            'Przypięcie aplikacji (screen pinning)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (s.isBusy)
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 10),
        Switch(
          value: s.pinned,
          onChanged: s.isBusy ? null : (v) => ref.read(kioskControllerProvider.notifier).setPinned(v),
        ),
      ],
    );
  }
}
