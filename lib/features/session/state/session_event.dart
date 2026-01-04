enum SessionEventKind { success, error }

class SessionEvent {
  final SessionEventKind kind;
  final String message;
  final int id;

  const SessionEvent({
    required this.kind,
    required this.message,
    required this.id,
  });

  static SessionEvent success(String msg) => SessionEvent(
    kind: SessionEventKind.success,
    message: msg,
    id: DateTime.now().millisecondsSinceEpoch,
  );

  static SessionEvent error(String msg) => SessionEvent(
    kind: SessionEventKind.error,
    message: msg,
    id: DateTime.now().millisecondsSinceEpoch,
  );
}
