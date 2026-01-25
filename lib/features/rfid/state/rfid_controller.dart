import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/extensions/string_extension.dart';
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
    final cleanUid = uid.trim();
    if (cleanUid.isEmpty) return;

    // anty-spam
    final now = DateTime.now();
    if (_lastUid == cleanUid && _lastAt != null) {
      if (now.difference(_lastAt!).inMilliseconds < 1500) return;
    }
    _lastUid = cleanUid;
    _lastAt = now;

    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);

    try {
      // Jedna ścieżka dla PIN/QR/NFC:
      await _ref
          .read(sessionControllerProvider.notifier)
          .openFromAuth(AuthInput.nfc(cleanUid));
    } finally {
      if (mounted) state = state.copyWith(isSubmitting: false);
    }
  }
}
