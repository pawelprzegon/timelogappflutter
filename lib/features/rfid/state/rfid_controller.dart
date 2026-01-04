import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../../session/model/auth_input.dart';
import '../../session/state/session_controller.dart';
import 'rfid_gate_provider.dart';

class RfidState {
  final bool isSubmitting;
  const RfidState({required this.isSubmitting});
  static const initial = RfidState(isSubmitting: false);
  RfidState copyWith({bool? isSubmitting}) =>
      RfidState(isSubmitting: isSubmitting ?? this.isSubmitting);
}

final rfidControllerProvider =
StateNotifierProvider<RfidController, RfidState>((ref) {
  return RfidController(ref);
});

class RfidController extends StateNotifier<RfidState> {
  RfidController(this._ref) : super(RfidState.initial);

  final Ref _ref;

  String? _lastUid;
  DateTime? _lastAt;

  Future<void> handleUid(String uid) async {
    final allowed = _ref.read(rfidGateProvider);
    if (!allowed) return;

    final now = DateTime.now();
    if (_lastUid == uid && _lastAt != null) {
      if (now.difference(_lastAt!).inMilliseconds < 1500) return;
    }
    _lastUid = uid;
    _lastAt = now;

    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);

    try {
      final DeviceApi api = _ref.read(deviceApiProvider);
      final res = await api.getActiveWithStatus(nfcTag: uid);

      if (res.status == 200 && res.body != null) {
        _ref.read(sessionControllerProvider.notifier).openFromActive(
          auth: AuthInput.nfc(uid),
          body: res.body!,
        );
      }
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}


