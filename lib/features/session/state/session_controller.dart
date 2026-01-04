import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../device/data/device_api.dart';
import '../../device/data/device_providers.dart';
import '../model/active_session.dart';
import '../model/auth_input.dart';

enum SessionEventKind { success, error }

class SessionEvent {
  final SessionEventKind kind;
  final String message;
  final int id; // żeby event się “różnił” nawet przy tym samym tekście

  const SessionEvent({
    required this.kind,
    required this.message,
    required this.id,
  });

  static SessionEvent success(String msg) =>
      SessionEvent(kind: SessionEventKind.success, message: msg, id: DateTime.now().millisecondsSinceEpoch);

  static SessionEvent error(String msg) =>
      SessionEvent(kind: SessionEventKind.error, message: msg, id: DateTime.now().millisecondsSinceEpoch);
}

class SessionState {
  final bool isOpen;
  final bool isBusy;
  final String? error;

  // NOWE:
  final AuthInput? auth;
  final Map<String, dynamic>? user; // na razie Map – później zrobimy model
  final ActiveSession? active;

  // NOWE: eventy do snackbarów
  final SessionEvent? event;

  const SessionState({
    required this.isOpen,
    required this.isBusy,
    required this.error,
    required this.auth,
    required this.user,
    required this.active,
    required this.event,
  });

  SessionState copyWith({
    bool? isOpen,
    bool? isBusy,
    String? error,
    AuthInput? auth,
    Map<String, dynamic>? user,
    ActiveSession? active,
    SessionEvent? event,
  }) {
    return SessionState(
      isOpen: isOpen ?? this.isOpen,
      isBusy: isBusy ?? this.isBusy,
      error: error,
      auth: auth ?? this.auth,
      user: user ?? this.user,
      active: active,
      event: event,
    );
  }

  static const closed = SessionState(
    isOpen: false,
    isBusy: false,
    error: null,
    auth: null,
    user: null,
    active: null,
    event: null,
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

  /// GŁÓWNE WEJŚCIE: PIN/QR/RFID → zawsze 2 requesty:
  /// 1) getUser
  /// 2) getActiveWithStatus
  Future<void> openFromAuth(AuthInput auth) async {
    if (state.isBusy) return;

    state = state.copyWith(
      isBusy: true,
      error: null,
      event: null,
    );

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
        // 204 albo 200 + {} → traktujemy jako "brak aktywnej zmiany"
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

  void close() {
    state = SessionState.closed;
  }

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

    // UWAGA: nie zamykamy modala – tylko aktualizujemy stan
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
      state = state.copyWith(
        error: 'Brak userId',
        event: SessionEvent.error('Brak userId'),
      );
      return;
    }

    state = state.copyWith(isBusy: true, error: null, event: null);
    try {
      await _api.startShift(userId: userId, contractId: contractId);
      await refresh();
      if (!mounted) return;
      state = state.copyWith(event: SessionEvent.success('Zmiana rozpoczęta'));
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
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isBusy: false,
        error: 'Nie udało się zakończyć przerwy',
        event: SessionEvent.error('Nie udało się zakończyć przerwy'),
      );
    }
  }
}
