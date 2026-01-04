import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/active_session.dart';
import '../../state/session_controller.dart';
import 'session_contract_picker.dart';

class SessionActions extends ConsumerWidget {
  const SessionActions({super.key, required this.active, required this.user, required this.scale});
  final ActiveSession? active;
  final Map<String, dynamic>? user;
  final double scale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = active;

    // SHIFT (mocniejsze)
    const shiftStartGreen = Color(0xFF1E8E3E); // ciemniejsza zieleń
    const shiftStopRed    = Color(0xFFC62828); // głęboka czerwień

// BREAK (jaśniejsze / “łagodniejsze”)
    const breakStartGreen = Color(0xFF2EAD65); // jaśniejsza zieleń
    const breakStopRed    = Color(0xFFE57373); // jaśniejsza czerwień

    // brak aktywnej zmiany → START (wybór kontraktu)
    if (a == null) {
      return _bigButton(
        text: 'START ZMIANY',
        icon: Icons.play_arrow_rounded,
        bg: shiftStartGreen,
        onTap: () async {
          final contractId = await showContractPicker(context, user);
          if (contractId == null) return;
          await ref.read(sessionControllerProvider.notifier).startShiftWithContract(contractId);
        },
      );
    }

    final hasBreak = active?.isOnBreak ?? false;

    // aktywna zmiana, brak przerwy → STOP SHIFT + START BREAK
    if (!hasBreak) {
      return Column(
        children: [
          _bigButton(
            text: 'ZAKOŃCZ ZMIANĘ',
            icon: Icons.stop_rounded,
            bg: shiftStopRed,
            onTap: () => ref.read(sessionControllerProvider.notifier).stopShift(),
          ),
          const SizedBox(height: 12),
          _bigButton(
            text: 'ROZPOCZNIJ PRZERWĘ',
            icon: Icons.pause_rounded,
            bg: breakStartGreen,
            onTap: () => ref.read(sessionControllerProvider.notifier).startBreak(),
          ),
        ],
      );
    }

    // aktywna zmiana i przerwa → STOP SHIFT + STOP BREAK
    return Column(
      children: [
        _bigButton(
          text: 'ZAKOŃCZ ZMIANĘ',
          icon: Icons.stop_rounded,
          bg: shiftStopRed,
          onTap: () => ref.read(sessionControllerProvider.notifier).stopShift(),
        ),
        const SizedBox(height: 12),
        _bigButton(
          text: 'ZAKOŃCZ PRZERWĘ',
          icon: Icons.play_arrow_rounded,
          bg: breakStopRed,
          fg: Colors.black,
          onTap: () => ref.read(sessionControllerProvider.notifier).stopBreak(),
        ),
      ],
    );
  }

  Widget _bigButton({
    required String text,
    required IconData icon,
    required VoidCallback? onTap,
    required Color bg,
    Color? fg,
  }) {
    final foreground = fg ?? Colors.white;

    return SizedBox(
      height: 78 * scale,
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: foreground, // kolor tekstu + ikony
          disabledBackgroundColor: bg.withOpacity(0.35),
          disabledForegroundColor: foreground.withOpacity(0.6),
          padding: EdgeInsets.symmetric(horizontal: 18 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 34 * scale),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

}
