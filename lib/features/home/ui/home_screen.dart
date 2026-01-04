import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/responsive.dart';
import '../../admin/state/admin_controller.dart';
import '../../qr/ui/qr_pane.dart';
import '../../rfid/state/rfid_bootstrap.dart';
import '../../rfid/ui/rfid_listener.dart';
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

    final clock = ref.watch(clockProvider);
    final timeText = clock.when(
      data: (dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      loading: () => '--:--',
      error: (_, __) => '--:--',
    );
    final session = ref.watch(sessionControllerProvider);

    // Placeholder: docelowo te widgety będą osobnymi “pane” dla RFID/QR/PIN
    Widget modePane() {
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
        // opcjonalnie:
        // ref.read(pinControllerProvider.notifier).clear();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Stack(
          children: [
            // 2) UI pod spodem blokujemy gdy modal otwarty
            AbsorbPointer(
              absorbing: session.isOpen,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                  child: Padding(
                    padding: EdgeInsets.all(14 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HomeHeader(timeText: timeText, scale: scale),
                        SizedBox(height: 14 * scale),

                        ModeToggle(isEnabled: !offline && !session.isOpen),
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

            // 3) Overlay modala
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
    );
  }
}
