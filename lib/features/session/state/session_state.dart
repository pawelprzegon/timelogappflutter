import '../model/active_session.dart';
import '../model/auth_input.dart';
import 'session_event.dart';

class SessionState {
  final bool isOpen;
  final bool isBusy;
  final String? error;

  final AuthInput? auth;
  final Map<String, dynamic>? user; // później model
  final ActiveSession? active;

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
