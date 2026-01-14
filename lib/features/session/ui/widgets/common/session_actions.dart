import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../home/state/input_coordinator.dart';
import '../../../model/active_session.dart';
import '../../../state/session_controller.dart';

class SessionActions extends ConsumerStatefulWidget {
  const SessionActions({
    super.key,
    required this.active,
    required this.user,
    required this.scale,
  });

  final ActiveSession? active;
  final Map<String, dynamic>? user;
  final double scale;

  @override
  ConsumerState<SessionActions> createState() => _SessionActionsState();
}

class _SessionActionsState extends ConsumerState<SessionActions> {
  late final sessionCtrl = ref.read(sessionControllerProvider.notifier);
  late final inputCtrl = ref.read(inputCoordinatorProvider.notifier);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isOpen = ref.read(sessionControllerProvider).isOpen;
      if (isOpen && widget.active == null) {
        sessionCtrl.pauseUiAutoClose(true);
      }
    });
  }

  void _setAutoClosePaused(bool paused) {
    Future.microtask(() => sessionCtrl.pauseUiAutoClose(paused));
  }

  @override
  void didUpdateWidget(covariant SessionActions oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isOpen = ref.read(sessionControllerProvider).isOpen;
    if (!isOpen) return;

    if (oldWidget.active == null && widget.active != null) {
      _setAutoClosePaused(false);
    } else if (oldWidget.active != null && widget.active == null) {
      _setAutoClosePaused(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionCtrl.pauseUiAutoClose(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.active;

    // SHIFT (mocniejsze)
    const shiftStartGreen = Color(0xFF1E8E3E);
    const shiftStopRed = Color(0xFFC62828);

    // BREAK (jaśniejsze / “łagodniejsze”)
    const breakStartGreen = Color(0xFF2EAD65);
    const breakStopRed = Color(0xFFE57373);

    // ✅ brak aktywnej zmiany → pokaż listę kontraktów do wyboru
    if (a == null) {
      final contracts = (widget.user?['contracts'] as List?)?.cast<Map>() ?? const [];

      if (contracts.isEmpty) {
        return _bigButton(
          text: 'BRAK KONTRAKTÓW',
          icon: Icons.error_outline,
          bg: Colors.grey,
          onTap: null,
        );
      }

      final maxH = MediaQuery.of(context).size.height * 0.45;

      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => inputCtrl.bumpIdle(),
        onPointerMove: (_) => inputCtrl.bumpIdle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wybierz kontrakt',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18 * widget.scale,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: contracts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final c = contracts[i];
                  final id = c['id'];
                  final cid = id is int ? id : int.tryParse(id.toString());

                  final title = (c['contractPosition'] ?? '—').toString();
                  final type = (c['contractType'] ?? '').toString();
                  final label = type.isEmpty ? title : '$title  •  $type';

                  return _bigButton(
                    text: label,
                    icon: Icons.play_arrow_rounded,
                    bg: shiftStartGreen,
                    onTap: cid == null
                        ? null
                        : () async {
                      inputCtrl.bumpIdle();
                      await sessionCtrl.startShiftWithContract(cid);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final hasBreak = a.isOnBreak;

    // aktywna zmiana, brak przerwy → STOP SHIFT + START BREAK
    if (!hasBreak) {
      return Column(
        children: [
          _bigButton(
            text: 'ZAKOŃCZ ZMIANĘ',
            icon: Icons.stop_rounded,
            bg: shiftStopRed,
            onTap: () => sessionCtrl.stopShift(),
          ),
          const SizedBox(height: 12),
          _bigButton(
            text: 'ROZPOCZNIJ PRZERWĘ',
            icon: Icons.pause_rounded,
            bg: breakStartGreen,
            onTap: () => sessionCtrl.startBreak(),
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
          onTap: () => sessionCtrl.stopShift(),
        ),
        const SizedBox(height: 12),
        _bigButton(
          text: 'ZAKOŃCZ PRZERWĘ',
          icon: Icons.play_arrow_rounded,
          bg: breakStopRed,
          fg: Colors.black,
          onTap: () => sessionCtrl.stopBreak(),
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
      height: 78 * widget.scale,
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: foreground,
          disabledBackgroundColor: bg.withOpacity(0.35),
          disabledForegroundColor: foreground.withOpacity(0.6),
          padding: EdgeInsets.symmetric(horizontal: 18 * widget.scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 34 * widget.scale),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 22 * widget.scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
