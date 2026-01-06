import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_controller.dart';

class AccentPicker extends ConsumerWidget {
  const AccentPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(seedColorProvider);

    final colors = <Color>[
      Colors.teal,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.pink,
    ];

    return Wrap(
      spacing: 10,
      children: [
        for (final c in colors)
          InkWell(
            onTap: () => ref.read(seedColorProvider.notifier).state = c,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  width: current == c ? 3 : 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
