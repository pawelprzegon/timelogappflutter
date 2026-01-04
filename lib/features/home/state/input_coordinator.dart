import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../qr/state/qr_controller.dart';
import 'mode_controller.dart';

class InputCoordinatorState {
  final bool cameraActive;
  final DateTime? qrUntil;

  const InputCoordinatorState({
    required this.cameraActive,
    required this.qrUntil,
  });

  static const initial = InputCoordinatorState(cameraActive: false, qrUntil: null);

  int get secondsLeft {
    final until = qrUntil;
    if (until == null) return 0;
    final s = until.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  bool get isQrActive {
    final until = qrUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  InputCoordinatorState copyWith({
    bool? cameraActive,
    DateTime? qrUntil,
  }) {
    return InputCoordinatorState(
      cameraActive: cameraActive ?? this.cameraActive,
      qrUntil: qrUntil,
    );
  }
}

final inputCoordinatorProvider =
StateNotifierProvider<InputCoordinator, InputCoordinatorState>((ref) {
  return InputCoordinator(ref);
});

class InputCoordinator extends StateNotifier<InputCoordinatorState> {
  InputCoordinator(this._ref) : super(InputCoordinatorState.initial);

  final Ref _ref;
  Timer? _qrTimer;

  static const Duration _defaultQrTimeout = Duration(seconds: 5);

  /// Wejście w PIN: wyłącz kamerę, anuluj timer, ustaw tryb PIN.
  void showPin() {
    _cancelTimer();
    _ref.read(qrControllerProvider.notifier).stopCamera();
    _ref.read(modeProvider.notifier).state = Mode.pin;

    state = state.copyWith(cameraActive: false, qrUntil: null);
  }

  /// Wejście w QR: ustaw tryb QR, włącz kamerę, załóż timer auto-powrotu.
  void showQr({Duration timeout = _defaultQrTimeout}) {
    _cancelTimer();

    _ref.read(modeProvider.notifier).state = Mode.qr;
    _ref.read(qrControllerProvider.notifier).startCamera();

    final until = DateTime.now().add(timeout);
    state = state.copyWith(cameraActive: true, qrUntil: until);

    _qrTimer = Timer(timeout, () {
      // Timer odpala się “asynchronicznie”, więc upewniamy się, że notifier żyje.
      if (!mounted) return;
      showPin();
    });
  }

  void _cancelTimer() {
    _qrTimer?.cancel();
    _qrTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
