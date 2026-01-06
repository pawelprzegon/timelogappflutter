import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/session_controller.dart';
import 'widgets/session_shell.dart';
import 'widgets/session_snackbar_listener.dart';

class SessionModal extends ConsumerWidget {
  const SessionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return SessionShell(session: session);
  }
}
