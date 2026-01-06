import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockState {
  final bool enabled;
  final bool isBusy;
  final String? error;

  const WakelockState({
    required this.enabled,
    required this.isBusy,
    required this.error,
  });

  static const initial = WakelockState(enabled: true, isBusy: false, error: null);

  WakelockState copyWith({bool? enabled, bool? isBusy, String? error}) {
    return WakelockState(
      enabled: enabled ?? this.enabled,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}

final wakelockControllerProvider =
StateNotifierProvider<WakelockController, WakelockState>((ref) {
  return WakelockController();
});

class WakelockController extends StateNotifier<WakelockState> {
  WakelockController() : super(WakelockState.initial);

  Future<void> setEnabled(bool value) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, error: null);

    try {
      if (value) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
      state = state.copyWith(enabled: value, isBusy: false, error: null);
    } catch (e) {
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }

  Future<void> toggle() => setEnabled(!state.enabled);
}
