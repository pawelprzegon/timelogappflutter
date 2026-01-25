import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../device/data/device_providers.dart';

final selectedUserIdProvider = StateProvider<int?>((_) => null);

class PickUserDropdown extends ConsumerWidget {
  const PickUserDropdown({
    super.key,
    this.onChanged,
    this.value,
    this.width = 420,
  });

  final int? value;
  final ValueChanged<int?>? onChanged;
  final double width;

  String _norm(String s) {
    final v = s.toLowerCase().trim();
    const repl = {
      'ą': 'a',
      'ć': 'c',
      'ę': 'e',
      'ł': 'l',
      'ń': 'n',
      'ó': 'o',
      'ś': 's',
      'ż': 'z',
      'ź': 'z',
    };
    var out = v;
    repl.forEach((k, val) => out = out.replaceAll(k, val));
    return out;
  }

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
            onPressed: () => ref.invalidate(deviceUsersProvider),
            child: const Text('Odśwież'),
          ),
        ],
      ),
      data: (users) {
        if (users.isEmpty) return const Text('Brak użytkowników');

        // Domyślny wybór: z zewnątrz albo pierwszy user
        final selected = value ?? users.first.id;

        // Label do listy + tekst do wyszukiwania
        final entries = users
            .map(
              (u) => DropdownMenuEntry<int>(
            value: u.id,
            label: u.label,
          ),
        )
            .toList();

        // Tekst do wyszukiwania dla każdego id (normalized)
        final searchIndex = <int, String>{
          for (final u in users)
            u.id: _norm('${u.firstName} ${u.lastName} ${u.username}')
        };

        return Material(
          child: DropdownMenu<int>(
            width: width,
            enableFilter: true,
            requestFocusOnTap: true,
            initialSelection: selected,
            onSelected: (v) {
              ref.read(selectedUserIdProvider.notifier).state = v;
              onChanged?.call(v);
            },
            dropdownMenuEntries: entries,
            filterCallback: (list, query) {
              final q = _norm(query);
              if (q.isEmpty) return list;
              return list.where((e) => (searchIndex[e.value] ?? '').contains(q)).toList();
            },
          ),
        );
      },
    );
  }
}
