import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../../session/state/session_controller.dart';
import '../../session/model/auth_input.dart';

String _maskToken(String t) {
  final v = t.trim();
  if (v.isEmpty) return '<EMPTY>';
  if (v.length <= 8) return v;
  return '${v.substring(0, 4)}...${v.substring(v.length - 4)}';
}

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

  static const _unset = Object();

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
      submit(); // celowo bez await — UI nie ma się “zawieszać”
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

    // 1) “Zamrażamy” PIN na czas requestu
    final pinStr = state.pin;
    final pinInt = int.tryParse(pinStr);
    if (pinInt == null) {
      state = PinState.initial.copyWith(error: 'Nieprawidłowy PIN');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // 2) Bierzemy zawsze aktualne API + token
      final DeviceApi api = _ref.read(deviceApiProvider);

      // DEBUG: pokaż token (zamaskowany)
      final t = _ref.read(deviceTokenProvider);
      // ignore: avoid_print
      print('PIN submit: tokenLen=${t.length} token="${_maskToken(t)}" pin=$pinInt');

      final DeviceResult res = await api.getActiveWithStatus(pin: pinInt);

      // Jeżeli notifier został disposed w trakcie await — wychodzimy.
      if (!mounted) return;

      // ignore: avoid_print
      print('PIN submit result: status=${res.status} body=${res.body}');

      if (res.status == 200 && res.body != null && res.body!.isNotEmpty) {
        _ref.read(sessionControllerProvider.notifier).openFromActive(
          auth: AuthInput.pin(pinInt),
          body: res.body!,
        );
        state = PinState.initial;
        return;
      }

      if (res.status == 204) {
        state = PinState.initial;
        return;
      }

      final msg = res.body?['message']?.toString();

      if (res.status == 401) {
        final hasToken = _ref.read(deviceTokenProvider).trim().isNotEmpty;
        state = PinState.initial.copyWith(
          error: msg ??
              (hasToken
                  ? 'Token urządzenia jest niepoprawny lub urządzenie nie jest zarejestrowane.'
                  : 'Brak tokena urządzenia – zapisz go w panelu Admina.'),
        );
        return;
      }

      if (res.status == 400) {
        state = PinState.initial.copyWith(
          error: msg ?? 'Błędne dane (PIN/QR/NFC).',
        );
        return;
      }

      state = PinState.initial.copyWith(
        error: msg ?? 'Błąd serwera (${res.status})',
      );
    } catch (_) {
      if (!mounted) return;
      state = PinState.initial.copyWith(
        error: 'Błąd połączenia z serwerem',
      );
    } finally {
      // 3) Gwarantujemy, że isSubmitting wróci do false
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false);
    }
  }
}
