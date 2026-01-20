import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../device/data/device_providers.dart';


class PickUserDropdown extends ConsumerWidget {
  const PickUserDropdown({
    super.key,
    this.onChanged,
    this.value,
  });

  /// Opcjonalnie: kontroluj wybór z zewnątrz
  final int? value;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(deviceUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Błąd: $e'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.invalidate(deviceUsersProvider), // refresh
            child: const Text('Odśwież'),
          ),
        ],
      ),
      data: (users) {
        if (users.isEmpty) return const Text('Brak użytkowników');

        final selected = value ?? users.first.id;

        final entries = users
            .map((u) => DropdownMenuEntry<int>(
          value: u.id,
          label: '${u.firstName} ${u.lastName}'.trim(),
        )).toList();

        // Ten Material wrapper rozwiązuje "No Material widget found"
        return Material(
          child: DropdownMenu<int>(
            initialSelection: selected,
            onSelected: onChanged ?? (_) {},
            dropdownMenuEntries: entries,
          ),
        );
      },
    );
  }
}
