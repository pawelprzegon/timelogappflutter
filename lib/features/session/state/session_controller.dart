import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../../home/state/input_coordinator.dart';
import '../model/active_session.dart';
import '../model/auth_input.dart';
import 'session_event.dart';
import 'session_state.dart';

final sessionControllerProvider =
StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(ref);
});

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref) : super(SessionState.closed);

  final Ref _ref;
  DeviceApi get _api => _ref.read(deviceApiProvider);

  Future<void> openFromAuth(AuthInput auth) async {
    if (state.isBusy) return;

    state = state.copyWith(isBusy: true, error: null, event: null);

    try {
      final user = await _api.getUser(
        pin: auth.pin,
        qrCode: auth.qrCode,
        nfcTag: auth.nfcTag,
      );

      if (!mounted) return;

      if (user == null || user.isEmpty) {
        state = SessionState.closed.copyWith(
          error: 'Nie znaleziono użytkownika',
          event: SessionEvent.error('Nie znaleziono użytkownika'),
        );
        return;
      }

      final res = await _api.getActiveWithStatus(
        pin: auth.pin,
        qrCode: auth.qrCode,
        nfcTag: auth.nfcTag,
      );

      if (!mounted) return;

      ActiveSession? active;
      if (res.status == 200 && res.body != null && res.body!.isNotEmpty) {
        active = ActiveSession.fromJson(res.body!);
      } else {
        active = null;
      }

      state = state.copyWith(
        isOpen: true,
        isBusy: false,
        error: null,
        auth: auth,
        user: user,
        active: active,
        event: null,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isOpen: false,
        isBusy: false,
        error: 'Błąd połączenia z serwerem',
        event: SessionEvent.error('Błąd połączenia z serwerem'),
      );
    }
  }

  void close() => state = SessionState.closed;

  Future<void> refresh() async {
    final auth = state.auth;
    if (auth == null) return;

    state = state.copyWith(isBusy: true, error: null, event: null);

    final res = await _api.getActiveWithStatus(
      pin: auth.pin,
      qrCode: auth.qrCode,
      nfcTag: auth.nfcTag,
    );

    if (!mounted) return;

    ActiveSession? active;
    if (res.status == 200 && res.body != null && res.body!.isNotEmpty) {
      active = ActiveSession.fromJson(res.body!);
    } else {
      active = null;
    }

    state = state.copyWith(isBusy: false, active: active, error: null, event: null);
  }

  int? get _userId {
    final u = state.user;
    if (u == null) return null;
    final v = u['id'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  Future<void> startShiftWithContract(int contractId) async {
    final userId = _userId;
    if (userId == null) {
      state = state.copyWith(error: 'Brak userId', event: SessionEvent.error('Brak userId'));
      return;
    }

    state = state.copyWith(isBusy: true, error: null, event: null);
    try {
      await _api.startShift(userId: userId, contractId: contractId);
      await refresh();
      if (!mounted) return;
      state = state.copyWith(event: SessionEvent.success('Zmiana rozpoczęta'));
      backToPin();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        error: 'Nie udało się rozpocząć zmiany',
        event: SessionEvent.error('Nie udało się rozpocząć zmiany'),
      );
    }
  }

  Future<void> stopShift() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null, event: null);
    try {
      await _api.stopShift(userId: a.userId);
      await refresh();
      if (!mounted) return;
      state = state.copyWith(event: SessionEvent.success('Zmiana zakończona'));
      backToPin();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        error: 'Nie udało się zakończyć zmiany',
        event: SessionEvent.error('Nie udało się zakończyć zmiany'),
      );
    }
  }

  Future<void> startBreak() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null, event: null);
    try {
      await _api.startBreak(userId: a.userId);
      await refresh();
      if (!mounted) return;
      state = state.copyWith(event: SessionEvent.success('Przerwa rozpoczęta'));
      backToPin();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        error: 'Nie udało się rozpocząć przerwy',
        event: SessionEvent.error('Nie udało się rozpocząć przerwy'),
      );
    }
  }

  Future<void> stopBreak() async {
    final a = state.active;
    if (a == null) return;

    state = state.copyWith(isBusy: true, error: null, event: null);
    try {
      await _api.stopBreak(userId: a.userId);
      await refresh();
      if (!mounted) return;
      state = state.copyWith(event: SessionEvent.success('Przerwa zakończona'));
      backToPin();
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        error: 'Nie udało się zakończyć przerwy',
        event: SessionEvent.error('Nie udało się zakończyć przerwy'),
      );
    }
  }

  void backToPin() {
    _ref.read(inputCoordinatorProvider.notifier).showPin();
    close();
  }
}
