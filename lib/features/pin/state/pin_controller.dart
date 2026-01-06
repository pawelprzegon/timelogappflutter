import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../session/state/session_controller.dart';
import '../../session/model/auth_input.dart';


const int kPinLength = 6;

class PinState {
  final String pin;
  final bool isSubmitting;
  final String? error;

  const PinState({
    required this.pin,
    required this.isSubmitting,
    required this.error,
  });

  PinState copyWith({
    String? pin,
    bool? isSubmitting,
    String? error,
  }) {
    return PinState(
      pin: pin ?? this.pin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }

  static const initial = PinState(pin: '', isSubmitting: false, error: null);
}


final pinControllerProvider =
StateNotifierProvider<PinController, PinState>((ref) {
  return PinController(ref);
});

class PinController extends StateNotifier<PinState> {
  PinController(this._ref) : super(PinState.initial);

  final Ref _ref;

  void addDigit(int digit) {
    if (state.isSubmitting) return;
    if (state.pin.length >= kPinLength) return;

    final next = '${state.pin}$digit';
    state = state.copyWith(pin: next, error: null);

    if (next.length == kPinLength) {
      submit();
    }
  }

  void backspace() {
    if (state.isSubmitting) return;
    if (state.pin.isEmpty) return;

    state = state.copyWith(
      pin: state.pin.substring(0, state.pin.length - 1),
      error: null,
    );
  }

  void clear() {
    if (state.isSubmitting) return;
    state = state.copyWith(pin: '', error: null);
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;
    if (state.pin.length != kPinLength) return;

    final pinInt = int.tryParse(state.pin);
    if (pinInt == null) {
      state = PinState.initial.copyWith(error: 'Nieprawidłowy PIN');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      await _ref.read(sessionControllerProvider.notifier)
          .openFromAuth(AuthInput.pin(pinInt));
      if (!mounted) return;
      state = PinState.initial;
    } catch (_) {
      if (!mounted) return;
      state = PinState.initial.copyWith(error: 'Błąd połączenia z serwerem');
    } finally {
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false);
    }
  }
}
