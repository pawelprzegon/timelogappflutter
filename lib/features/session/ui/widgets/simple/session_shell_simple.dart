import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../home/state/input_coordinator.dart';
import '../../../state/session_controller.dart';
import '../../../state/session_state.dart';
import 'session_user_card.dart';
import '../common/session_active_card.dart';
import '../common/session_actions.dart';
import '../common/session_error_banner.dart';
import '../common/session_busy_overlay.dart';

class SessionShellSimple extends ConsumerStatefulWidget {
  const SessionShellSimple({super.key, required this.session});
  final SessionState session;

  @override
  ConsumerState<SessionShellSimple> createState() => _SessionShellSimpleState();
}

class _SessionShellSimpleState extends ConsumerState<SessionShellSimple>
    with SingleTickerProviderStateMixin {
  static const _autoCloseDuration = Duration(seconds: 5);

  late final AnimationController _autoCloseCtrl;

  @override
  void didUpdateWidget(covariant SessionShellSimple oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.session.uiBump != oldWidget.session.uiBump) {
      _restartAutoClose();
    }
  }

  // TODO: PREPARATION FOR AUTOSTART
  // @override
  // void didUpdateWidget(covariant SessionShellSimple oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  //   // 1. Logika restartu paska (już masz)
  //   if (widget.session.uiBump != oldWidget.session.uiBump) {
  //     _restartAutoClose();
  //   }
  //
  //   // 2. Logika automatycznego startu i powrotu
  //   final session = widget.session;
  //   final user = session.user;
  //
  //   if (user != null &&
  //       user['active'] == true &&
  //       user['contracts']?.length == 1) {
  //
  //     // Wykonujemy akcję po zakończeniu bieżącego renderowania (post frame callback)
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       final cid = user['contracts'][0]['id'];
  //       ref.read(sessionControllerProvider.notifier).startShiftWithContract(cid);
  //
  //       // Powrót (zamknięcie)
  //       _closeModal();
  //     });
  //   }
  // }


  @override
  void initState() {
    super.initState();

    _autoCloseCtrl = AnimationController(
      vsync: this,
      duration: _autoCloseDuration,
      value: 1.0, // start pełny pasek
    );

    _autoCloseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // ✅ czas minął → zamykamy modal i wracamy do PIN
        _closeModal();
      }
    });

    // start od razu po otwarciu modala
    _restartAutoClose();
  }

  @override
  void dispose() {
    _autoCloseCtrl.dispose();
    super.dispose();
  }

  void _closeModal() {
    // UWAGA: guard, bo może przyjść już po zamknięciu
    // (np. w trakcie rebuildów)
    ref.read(sessionControllerProvider.notifier).close();
    ref.read(inputCoordinatorProvider.notifier).showPin();
  }

  void _restartAutoClose() {
    _autoCloseCtrl.stop();
    _autoCloseCtrl.value = 1.0;
    _autoCloseCtrl.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    final mq = MediaQuery.of(context);
    final shortest = mq.size.shortestSide;
    final scale = (shortest / 400.0).clamp(0.95, 1.30);

    // ✅ “kolor systemu” (jak ustawiasz primary z admina → pasek będzie taki sam)
    final barColor = Theme.of(context).colorScheme.primary;

    final outerPad = 22.0 * scale;
    final barH = 10.0 * scale;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restartAutoClose(),
      onPointerMove: (_) => _restartAutoClose(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.all(outerPad),
            child: Stack(
              clipBehavior: Clip.none, // ✅ pozwala wyjść X poza kartę
              children: [
                Material(
                  color: const Color(0xFF0B1220),
                  borderRadius: BorderRadius.circular(26),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          // ✅ zostawiamy miejsce na pasek na dole
                          padding: EdgeInsets.fromLTRB(
                            18 * scale,
                            18 * scale,
                            18 * scale,
                            (18 * scale) + barH + (8 * scale),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (session.error != null) ...[
                                SessionErrorBanner(text: session.error!),
                                SizedBox(height: 12 * scale),
                              ],
                              SessionUserCard(user: session.user, scale: scale),
                              // SizedBox(height: 14 * scale),
                              // SessionActiveCard(active: session.active, scale: scale),
                              SizedBox(height: 16 * scale),
                              SessionActions(
                                active: session.active,
                                user: session.user,
                                scale: scale,
                              ),
                            ],
                          ),
                        ),

                        // ✅ Pasek auto-zamykania (kurczy się do zera)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(26),
                              bottomRight: Radius.circular(26),
                            ),
                            child: Container(
                              height: barH,
                              color: Colors.white.withValues(alpha: 0.06),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedBuilder(
                                  animation: _autoCloseCtrl,
                                  builder: (context, _) {
                                    return FractionallySizedBox(
                                      widthFactor: _autoCloseCtrl.value.clamp(0.0, 1.0),
                                      child: Container(color: barColor),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Floating close (na zewnątrz)
                Positioned(
                  top: -14 * scale,
                  right: -14 * scale,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: session.isBusy ? null : _closeModal,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1A2B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12 * scale),
                          child: Icon(
                            Icons.close_rounded,
                            color: session.isBusy
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.white,
                            size: 30 * scale,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (session.isBusy) const Positioned.fill(child: SessionBusyOverlay()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
