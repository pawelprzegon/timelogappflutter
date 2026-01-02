import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_controller.dart';

class SessionModal extends ConsumerWidget {
  const SessionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(sessionControllerProvider);
    final ctrl = ref.read(sessionControllerProvider.notifier);

    final a = st.active;
    if (a == null) return const SizedBox.shrink();

    final title = a.contract?.contractPosition.isNotEmpty == true
        ? a.contract!.contractPosition
        : 'Sesja użytkownika';

    String fmt(DateTime? dt) {
      if (dt == null) return '-';
      final local = dt.toLocal();
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    // Logika przycisków:
    final canStartShift = !a.hasShift;
    final canStopShift = a.hasShift;
    final canStartBreak = a.hasShift && !a.isOnBreak;
    final canStopBreak = a.hasShift && a.isOnBreak;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            color: const Color(0xFF10151D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: st.isBusy ? null : ctrl.close,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text('User ID: ${a.userId}', style: const TextStyle(color: Colors.white70)),
                  if (a.contract != null) ...[
                    const SizedBox(height: 6),
                    Text('Typ: ${a.contract!.contractType}', style: const TextStyle(color: Colors.white70)),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _kv('Start', fmt(a.start))),
                      const SizedBox(width: 12),
                      Expanded(child: _kv('Przerwa', fmt(a.workbreak))),
                    ],
                  ),

                  if (st.error != null) ...[
                    const SizedBox(height: 12),
                    Text(st.error!, style: const TextStyle(color: Colors.redAccent)),
                  ],

                  const SizedBox(height: 16),

                  if (st.isBusy) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                  ],

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: (st.isBusy || !canStartShift) ? null : ctrl.startShift,
                        child: const Text('Start zmiany'),
                      ),
                      FilledButton(
                        onPressed: (st.isBusy || !canStopShift) ? null : ctrl.stopShift,
                        child: const Text('Stop zmiany'),
                      ),
                      OutlinedButton(
                        onPressed: (st.isBusy || !canStartBreak) ? null : ctrl.startBreak,
                        child: const Text('Start przerwy'),
                      ),
                      OutlinedButton(
                        onPressed: (st.isBusy || !canStopBreak) ? null : ctrl.stopBreak,
                        child: const Text('Stop przerwy'),
                      ),
                      TextButton(
                        onPressed: st.isBusy ? null : ctrl.refresh,
                        child: const Text('Odśwież'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _kv(String k, String v) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(k, style: const TextStyle(color: Colors.white54)),
      const SizedBox(height: 4),
      Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ],
  );
}
