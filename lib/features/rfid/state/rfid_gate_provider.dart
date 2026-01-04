import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/state/mode_controller.dart';
import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';
import '../../home/state/input_coordinator.dart';

final rfidGateProvider = Provider<bool>((ref) {
  final mode = ref.watch(modeProvider);
  final pin = ref.watch(pinControllerProvider);
  final session = ref.watch(sessionControllerProvider);
  final input = ref.watch(inputCoordinatorProvider);

  final isPinPane = mode == Mode.pin;
  final pinEmpty = pin.pin.isEmpty;
  final sessionClosed = !session.isOpen;
  final qrInactive = !input.isQrActive;

  return isPinPane && pinEmpty && sessionClosed && qrInactive;
});
