import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/session_controller.dart';

class SessionModal extends ConsumerWidget {
  const SessionModal({super.key});

  List<Map<String, dynamic>> _contracts(Map<String, dynamic>? user) {
    final raw = user?['contracts'];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  String _userTitle(Map<String, dynamic>? user) {
    if (user == null) return '';
    final fn = (user['firstName'] ?? '').toString();
    final ln = (user['lastName'] ?? '').toString();
    final full = ('$fn $ln').trim();
    return full.isEmpty ? 'Użytkownik' : full;
  }

  Future<int?> _pickContractId(BuildContext context, List<Map<String, dynamic>> contracts) async {
    if (contracts.isEmpty) return null;

    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Wybierz kontrakt'),
          content: SizedBox(
            width: 420,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: contracts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = contracts[i];
                final id = c['id'];
                final idInt = (id is int) ? id : int.tryParse(id?.toString() ?? '');
                final pos = (c['contractPosition'] ?? '').toString();
                final type = (c['contractType'] ?? '').toString();
                final title = [pos, type].where((s) => s.trim().isNotEmpty).join(' • ');
                return ListTile(
                  title: Text(title.isEmpty ? 'Kontrakt ${idInt ?? ''}' : title),
                  onTap: () => Navigator.of(ctx).pop(idInt),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final ctrl = ref.read(sessionControllerProvider.notifier);

    final user = state.user;
    final active = state.active;
    final contracts = _contracts(user);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _userTitle(user),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: state.isBusy ? null : ctrl.close,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (state.error != null) ...[
                Text(state.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],

              // Status aktywności
              if (active == null) ...[
                const Text('Brak aktywnej zmiany.'),
              ] else ...[
                Text('Aktywna zmiana: ${active.contract?.contractPosition ?? '-'}'),
                Text(active.isOnBreak ? 'Status: PRZERWA' : 'Status: PRACA'),
              ],

              const SizedBox(height: 16),

              if (state.isBusy) const CircularProgressIndicator(),
              if (!state.isBusy) ...[
                if (active == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final id = await _pickContractId(context, contracts);
                        if (id == null) return;
                        await ctrl.startShiftWithContract(id);
                      },
                      child: const Text('Start shift'),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ctrl.stopShift,
                          child: const Text('Stop shift'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: active.isOnBreak ? ctrl.stopBreak : ctrl.startBreak,
                          child: Text(active.isOnBreak ? 'Stop break' : 'Start break'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
