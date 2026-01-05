import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/responsive.dart';
import '../../admin/state/admin_controller.dart';
import '../../qr/ui/qr_pane.dart';
import '../../rfid/state/rfid_bootstrap.dart';
import '../state/clock_controller.dart';
import '../state/connectivity_controller.dart';
import '../state/input_coordinator.dart';
import '../state/mode_controller.dart';

import 'widgets/home_header.dart';
import 'widgets/home_footer.dart';
import 'widgets/mode_toggle.dart';
import 'widgets/offline_banner.dart';

import '../../session/state/session_controller.dart';
import '../../session/ui/session_modal.dart';
import '../../pin/ui/pin_pane.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = Responsive.scale(context);
    final conn = ref.watch(connectivityProvider);
    final admin = ref.watch(adminControllerProvider);
    final mode = ref.watch(modeProvider);
    ref.watch(rfidBootstrapProvider);

    final offline = !conn.isOnline;
    final tokenMissing = !admin.isLoading && admin.token.trim().isEmpty;

    final clock = ref.watch(clockProvider);
    final timeText = clock.when(
      data: (dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      loading: () => '--:--',
      error: (_, __) => '--:--',
    );

    final session = ref.watch(sessionControllerProvider);

    Widget modePane() {
      if (tokenMissing) {
        return const Center(
          child: Text(
            'Brak tokena urządzenia.\nPrzejdź do Admin i wklej token.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        );
      }

      if (offline) {
        return const Center(
          child: Text(
            'OFFLINE — ukrywamy RFID/QR/PIN',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        );
      }

      return switch (mode) {
        Mode.qr => const QrPane(),
        Mode.pin => const PinPane(),
      };
    }

    ref.listen(sessionControllerProvider, (prev, next) {
      final wasOpen = prev?.isOpen ?? false;
      final isOpen = next.isOpen;

      if (!wasOpen && isOpen) {
        ref.read(inputCoordinatorProvider.notifier).showPin();
      }
    });

    // blokujemy cały UI jeśli:
    // - sesja otwarta (modal)
    // - brakuje tokena (wymuszenie konfiguracji)
    final blockUi = session.isOpen || tokenMissing;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => ref.read(inputCoordinatorProvider.notifier).bumpIdle(),
        onPointerMove: (_) => ref.read(inputCoordinatorProvider.notifier).bumpIdle(),
        child: SafeArea(
          child: Stack(
            children: [
              // 1) GŁÓWNY UI (zawsze renderujemy)
              AbsorbPointer(
                absorbing: blockUi,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Responsive.maxContentWidth(context),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HomeHeader(timeText: timeText, scale: scale),
                          SizedBox(height: 14 * scale),

                          ModeToggle(isEnabled: !offline && !session.isOpen && !tokenMissing),
                          SizedBox(height: 10 * scale),

                          if (offline) ...[
                            OfflineBanner(customText: admin.offlineMessage),
                            SizedBox(height: 10 * scale),
                          ],

                          Expanded(child: modePane()),

                          const HomeFooter(
                            weatherText: 'Pogoda...',
                            deviceText: 'Urządzenie...',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2) OVERLAY: BRAK TOKENA
              if (tokenMissing) ...[
                const Positioned.fill(
                  child: ModalBarrier(dismissible: false, color: Colors.black54),
                ),
                Positioned.fill(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 44),
                              const SizedBox(height: 12),
                              const Text(
                                'Brak tokena urządzenia',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Aby uruchomić kiosk, wejdź do panelu Admin i wklej token.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => context.push('/admin'),
                                    icon: const Icon(Icons.admin_panel_settings),
                                    label: const Text('Otwórz Admin'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // 3) OVERLAY: SESJA
              if (session.isOpen) ...[
                const Positioned.fill(
                  child: ModalBarrier(dismissible: false, color: Colors.black54),
                ),
                const Positioned.fill(
                  child: SessionModal(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
