import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/state/connectivity_controller.dart';
import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';
import '../../home/state/pane_controller.dart';

bool canAcceptRfid(Ref ref) {
  final pane = ref.read(paneProvider);
  final pin = ref.read(pinControllerProvider);
  final session = ref.read(sessionControllerProvider);
  final conn = ref.read(connectivityProvider);

  return conn.isOnline &&
      !session.isOpen &&
      pane == Pane.pin &&
      pin.isEmpty;
}
