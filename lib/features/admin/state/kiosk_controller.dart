import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/kiosk/kiosk_service.dart';

class KioskState {
  final bool pinned;
  final bool isBusy;
  final String? error;

  const KioskState({
    required this.pinned,
    required this.isBusy,
    required this.error,
  });

  static const initial = KioskState(pinned: false, isBusy: false, error: null);

  KioskState copyWith({bool? pinned, bool? isBusy, String? error}) {
    return KioskState(
      pinned: pinned ?? this.pinned,
      isBusy: isBusy ?? this.isBusy,
      error: error,
    );
  }
}

final kioskControllerProvider =
StateNotifierProvider<KioskController, KioskState>((ref) {
  return KioskController();
});

class KioskController extends StateNotifier<KioskState> {
  KioskController() : super(KioskState.initial);

  Future<void> setPinned(bool value) async {
    if (state.isBusy) return;
    state = state.copyWith(isBusy: true, error: null);

    try {
      if (value) {
        await KioskService.pin();
      } else {
        await KioskService.unpin();
      }

      state = state.copyWith(pinned: value, isBusy: false, error: null);
    } catch (e) {
      // cofamy zmianę w UI
      state = state.copyWith(isBusy: false, error: e.toString());
    }
  }
}
