import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../qr/state/qr_controller.dart';
import '../../session/model/auth_input.dart';
import '../../session/state/session_controller.dart';
import 'mode_controller.dart';

class InputCoordinatorState {
  final bool cameraActive;
  final DateTime? qrUntil;

  const InputCoordinatorState({
    required this.cameraActive,
    required this.qrUntil,
  });

  static const initial =
  InputCoordinatorState(cameraActive: false, qrUntil: null);

  // ✅ do gate’a
  bool get isQrActive => cameraActive;

  int get secondsLeft {
    final until = qrUntil;
    if (until == null) return 0;

    final ms = until.difference(DateTime.now()).inMilliseconds;
    if (ms <= 0) return 0;

    return (ms / 1000).ceil();
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

  // anty-spam dla QR
  String? _lastQr;
  DateTime? _lastQrAt;

  void showPin() {
    _cancelTimer();
    _ref.read(qrControllerProvider.notifier).stopCamera();
    _ref.read(modeProvider.notifier).state = Mode.pin;

    state = state.copyWith(cameraActive: false, qrUntil: null);
  }

  void showQr({Duration timeout = _defaultQrTimeout}) {
    _cancelTimer();

    // Jeśli modal jest otwarty / jesteśmy busy – nie włączamy kamery
    final session = _ref.read(sessionControllerProvider);
    if (session.isOpen || session.isBusy) return;

    _ref.read(modeProvider.notifier).state = Mode.qr;
    _ref.read(qrControllerProvider.notifier).startCamera();

    final until = DateTime.now().add(timeout);
    state = state.copyWith(cameraActive: true, qrUntil: until);

    _qrTimer = Timer(timeout, () {
      if (!mounted) return;
      showPin();
    });
  }

  void onQrScanned(String code) {
    // 1) blokada gdy modal otwarty / busy
    final session = _ref.read(sessionControllerProvider);
    if (session.isOpen || session.isBusy) return;

    // 2) anty-spam
    final now = DateTime.now();
    if (_lastQr == code && _lastQrAt != null) {
      if (now.difference(_lastQrAt!).inMilliseconds < 1500) return;
    }
    _lastQr = code;
    _lastQrAt = now;

    // 3) gasimy kamerę i wracamy do PIN natychmiast
    showPin();

    // 4) uruchamiamy flow: getUser + getActiveWithStatus
    _ref.read(sessionControllerProvider.notifier).openFromAuth(AuthInput.qr(code));
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
