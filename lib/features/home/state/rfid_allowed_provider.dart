import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mode_controller.dart';
import 'connectivity_controller.dart';
import 'input_coordinator.dart';
import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';

final rfidAllowedProvider = Provider<bool>((ref) {
  final online = ref.watch(connectivityProvider).isOnline;
  if (!online) return false;

  final mode = ref.watch(modeProvider);
  if (mode != Mode.pin) return false;

  final pin = ref.watch(pinControllerProvider).pin;
  if (pin.isNotEmpty) return false;

  final sessionOpen = ref.watch(sessionControllerProvider).isOpen;
  if (sessionOpen) return false;

  // To blokuje RFID podczas QR (kamera on / timer).
  final cameraActive = ref.watch(inputCoordinatorProvider).cameraActive;
  if (cameraActive) return false;

  return true;
});
