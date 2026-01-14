import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelogappflutter/features/session/ui/widgets/simple/session_shell_simple.dart';

import '../../admin/widgets/session_ui_toggle.dart';
import '../state/session_controller.dart';
import 'widgets/detail/session_shell.dart';

class SessionModal extends ConsumerWidget {
  const SessionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    final isDetailed = ref.watch(sessionUiProvider);

    print(isDetailed);
    if (isDetailed) return SessionShell(session: session);
    else return SessionShellSimple(session: session);
  }
}
