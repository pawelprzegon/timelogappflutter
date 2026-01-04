import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/session_controller.dart';
import '../../state/session_event.dart';

class SessionSnackbarListener extends ConsumerWidget {
  const SessionSnackbarListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionControllerProvider, (prev, next) {
      final e = next.event;
      if (e == null) return;
      if (prev?.event?.id == e.id) return;

      final isOk = e.kind == SessionEventKind.success;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isOk ? Colors.green.shade700 : Colors.red.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    });

    return child;
  }
}
