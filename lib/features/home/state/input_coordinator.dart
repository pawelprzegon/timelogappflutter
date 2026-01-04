import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../qr/state/qr_controller.dart';
import 'mode_controller.dart';
import '../../session/state/session_controller.dart';

import '../../pin/state/pin_controller.dart';
import '../../session/state/session_controller.dart';
import '../../rfid/state/rfid_controller.dart'; // ścieżkę dopasuj do swojego układu


class InputCoordinatorState {
  final bool cameraActive;
  final DateTime? qrEndsAt;

  const InputCoordinatorState({
    required this.cameraActive,
    required this.qrEndsAt,
  });

  static const initial = InputCoordinatorState(cameraActive: false, qrEndsAt: null);

  int get secondsLeft {
    final until = qrEndsAt;
    if (until == null) return 0;
    final s = until.difference(DateTime.now()).inSeconds;
    return s < 0 ? 0 : s;
  }

  bool get isQrActive => cameraActive && secondsLeft > 0;

  InputCoordinatorState copyWith({
    bool? cameraActive,
    DateTime? qrEndsAt,
  }) {
    return InputCoordinatorState(
      cameraActive: cameraActive ?? this.cameraActive,
      qrEndsAt: qrEndsAt,
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

  bool get _sessionOpen => _ref.read(sessionControllerProvider).isOpen;

  void showPin() {
    _cancelTimer();
    _ref.read(qrControllerProvider.notifier).stopCamera();
    _ref.read(modeProvider.notifier).state = Mode.pin;

    state = state.copyWith(cameraActive: false, qrEndsAt: null);
  }

  void showQr({Duration timeout = _defaultQrTimeout}) {
    // Jeśli modal otwarty → nie włączamy kamery
    if (_sessionOpen) return;

    _cancelTimer();

    _ref.read(modeProvider.notifier).state = Mode.qr;
    _ref.read(qrControllerProvider.notifier).startCamera();

    final until = DateTime.now().add(timeout);
    state = state.copyWith(cameraActive: true, qrEndsAt: until);

    _qrTimer = Timer(timeout, () {
      if (!mounted) return;
      showPin();
    });
  }

  Future<void> onRfidScanned(String uid) async {
    // 1) Sprawdź gate
    final mode = _ref.read(modeProvider);
    final pin = _ref.read(pinControllerProvider).pin;
    final sessionOpen = _ref.read(sessionControllerProvider).isOpen;

    final isPinPane = mode == Mode.pin;
    final pinEmpty = pin.isEmpty;
    final qrInactive = !state.cameraActive; // albo !state.isQrActive jeśli dodasz getter
    final allowed = isPinPane && pinEmpty && !sessionOpen && qrInactive;

    if (!allowed) {
      // ignore: avoid_print
      print('RFID ignored (gate) uid=$uid mode=$mode pinEmpty=$pinEmpty sessionOpen=$sessionOpen cameraActive=${state.cameraActive}');
      return;
    }

    // 2) Jeśli wolno → odpal kontroler RFID
    await _ref.read(rfidControllerProvider.notifier).handleUid(uid);
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
