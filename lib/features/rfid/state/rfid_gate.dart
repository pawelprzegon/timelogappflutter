import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/state/connectivity_controller.dart';
import '../../home/state/mode_controller.dart'; // u Ciebie Mode { qr, pin }
import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';

/// Jedno miejsce, które mówi: “czy teraz wolno przyjąć RFID”.
final canAcceptRfidProvider = Provider<bool>((ref) {
  final online = ref.watch(connectivityProvider).isOnline;
  final mode = ref.watch(modeProvider);
  final pin = ref.watch(pinControllerProvider).pin;
  final pinSubmitting = ref.watch(pinControllerProvider).isSubmitting;
  final sessionOpen = ref.watch(sessionControllerProvider).isOpen;

  return online &&
      mode == Mode.pin &&
      pin.isEmpty &&
      !pinSubmitting &&
      !sessionOpen;
});
