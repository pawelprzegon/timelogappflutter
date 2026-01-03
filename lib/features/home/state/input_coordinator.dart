import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';
import 'connectivity_controller.dart';
import 'pane_controller.dart';

class InputState {
  final bool cameraActive;
  final DateTime? qrEndsAt;

  const InputState({
    required this.cameraActive,
    required this.qrEndsAt,
  });

  static const initial = InputState(cameraActive: false, qrEndsAt: null);

  InputState copyWith({
    bool? cameraActive,
    DateTime? qrEndsAt,
  }) {
    return InputState(
      cameraActive: cameraActive ?? this.cameraActive,
      qrEndsAt: qrEndsAt,
    );
  }
}

final inputCoordinatorProvider =
StateNotifierProvider<InputCoordinator, InputState>((ref) {
  return InputCoordinator(ref);
});

class InputCoordinator extends StateNotifier<InputState> {
  InputCoordinator(this._ref) : super(InputState.initial);

  final Ref _ref;
  Timer? _qrTimer;

  void activatePin() {
    _qrTimer?.cancel();
    state = state.copyWith(cameraActive: false, qrEndsAt: null);
    _ref.read(paneProvider.notifier).state = Pane.pin;
  }

  void activateQr({Duration duration = const Duration(seconds: 5)}) {
    _qrTimer?.cancel();

    // UX/bezpieczeństwo: gdy przechodzimy na QR, czyścimy ewentualnie wpisany PIN.
    // Dzięki temu po powrocie do PIN pole jest puste, a RFID może działać.
    _ref.read(pinControllerProvider.notifier).clear();

    final endsAt = DateTime.now().add(duration);

    state = state.copyWith(cameraActive: true, qrEndsAt: endsAt);
    _ref.read(paneProvider.notifier).state = Pane.qr;

    _qrTimer = Timer(duration, () {
      // Timer może odpalić po dispose — dlatego nie dotykamy już ref tutaj,
      // tylko robimy bezpieczny powrót przez state + paneProvider.
      // (StateNotifier sam się dispose'uje, timer w dispose anulujemy.)
      activatePin();
    });
  }

  /// Jedno miejsce prawdy: czy wolno przyjąć RFID *teraz*.
  bool canAcceptRfid() {
    final conn = _ref.read(connectivityProvider);
    if (!conn.isOnline) return false;

    final session = _ref.read(sessionControllerProvider);
    if (session.isOpen) return false;

    if (state.cameraActive) return false;

    final pane = _ref.read(paneProvider);
    if (pane != Pane.pin) return false;

    final pin = _ref.read(pinControllerProvider);
    if (!pin.isEmpty) return false; // ktoś już wpisuje PIN

    return true;
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }
}
