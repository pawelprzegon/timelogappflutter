import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../../session/model/auth_input.dart';
import '../../session/state/session_controller.dart';

class RfidState {
  final bool isConnected;
  final bool isSubmitting;
  const RfidState({required this.isConnected, required this.isSubmitting});

  static const initial = RfidState(isConnected: false, isSubmitting: false);

  RfidState copyWith({
    bool? isConnected,
    bool? isSubmitting
  }) =>
      RfidState(
          isConnected: isConnected ?? this.isConnected,
          isSubmitting: isSubmitting ?? this.isSubmitting
      );
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

  void setConnected(bool v) {
    if (!mounted) return;
    if (state.isConnected == v) return;
    state = state.copyWith(isConnected: v);
  }

  Future<void> handleUid(String uid) async {
    // anty-spam
    final now = DateTime.now();
    if (_lastUid == uid && _lastAt != null) {
      if (now.difference(_lastAt!).inMilliseconds < 1500) return;
    }
    _lastUid = uid;
    _lastAt = now;

    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);

    try {
      // ignore: avoid_print
      print('RFID -> API uid=$uid');

      final api = _ref.read(deviceApiProvider);
      final res = await api.getActiveWithStatus(nfcTag: uid);

      // ignore: avoid_print
      print('RFID API result status=${res.status} body=${res.body}');

      if (res.status == 200 && res.body != null) {
        await _ref.read(sessionControllerProvider.notifier).openFromAuth(
          AuthInput.nfc(uid),
        );
      }
    } finally {
      if (mounted) state = state.copyWith(isSubmitting: false);
    }
  }

}
