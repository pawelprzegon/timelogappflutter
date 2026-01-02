import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../model/active_session.dart';
import '../model/auth_input.dart';

class SessionState {
  final bool isOpen;
  final bool isBusy;
  final String? error;
  final AuthInput? auth;
  final ActiveSession? active;

  const SessionState({
    required this.isOpen,
    required this.isBusy,
    required this.error,
    required this.auth,
    required this.active,
  });

  SessionState copyWith({
    bool? isOpen,
    bool? isBusy,
    String? error,
    AuthInput? auth,
    ActiveSession? active,
  }) {
    return SessionState(
      isOpen: isOpen ?? this.isOpen,
      isBusy: isBusy ?? this.isBusy,
      error: error,
      auth: auth ?? this.auth,
      active: active ?? this.active,
    );
  }

  static const closed = SessionState(
    isOpen: false,
    isBusy: false,
    error: null,
    auth: null,
    active: null,
  );
}

final sessionControllerProvider =
StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref) : super(SessionState.closed);

  final Ref _ref;

  DeviceApi get _api => _ref.read(deviceApiProvider);

  void openFromActive({required AuthInput auth, required Map<String, dynamic> body}) {
    final active = ActiveSession.fromJson(body);
    state = state.copyWith(isOpen: true, isBusy: false, error: null, auth: auth, active: active);
  }

  void close() {
    state = SessionState.closed;
  }

  Future<void> refresh() async {
    final auth = state.auth;
    if (auth == null) return;

    state = state.copyWith(isBusy: true, error: null);

    final res = await _api.getActiveWithStatus(
      pin: auth.pin,
      qrCode: auth.qrCode,
      nfcTag: auth.nfcTag,
    );

    if (!mounted) return;

    if (res.status == 200 && res.body != null) {
      state = state.copyWith(isBusy: false, active: ActiveSession.fromJson(res.body!));
    } else if (res.status == 204) {
      // brak aktywności → zamykamy modal
      state = SessionState.closed;
    } else {
      state = state.copyWith(
        isBusy: false,
        error: res.body?['message']?.toString() ?? 'Błąd (${res.status})',
      );
    }
  }

  Future<void> startShift() async {
    final a = state.active;
    if (a == null) return;

    final contractId = a.contract?.id;
    if (contractId == null) {
      state = state.copyWith(error: 'Brak contractId');
      return;
    }

    state = state.copyWith(isBusy: true, error: null);
    try {
      await _api.startShift(userId: a.userId, contractId: contractId);
      await refresh();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isBusy: false, error: 'Nie udało się rozpocząć zmiany');
    }
  }

  Future<void> stopShift() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null);
    try {
      await _api.stopShift(userId: a.userId);
      await refresh();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isBusy: false, error: 'Nie udało się zakończyć zmiany');
    }
  }

  Future<void> startBreak() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null);
    try {
      await _api.startBreak(userId: a.userId);
      await refresh();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isBusy: false, error: 'Nie udało się rozpocząć przerwy');
    }
  }

  Future<void> stopBreak() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null);
    try {
      await _api.stopBreak(userId: a.userId);
      await refresh();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isBusy: false, error: 'Nie udało się zakończyć przerwy');
    }
  }
}
