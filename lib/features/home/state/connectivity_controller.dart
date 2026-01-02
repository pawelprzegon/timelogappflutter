import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/dio_provider.dart';

class ConnectivityState {
  final bool isOnline;
  final bool isChecking;
  final DateTime? lastCheck;

  const ConnectivityState({
    required this.isOnline,
    required this.isChecking,
    required this.lastCheck,
  });

  ConnectivityState copyWith({
    bool? isOnline,
    bool? isChecking,
    DateTime? lastCheck,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      isChecking: isChecking ?? this.isChecking,
      lastCheck: lastCheck ?? this.lastCheck,
    );
  }

  static const initial =
  ConnectivityState(isOnline: true, isChecking: false, lastCheck: null);
}

class ConnectivityController extends StateNotifier<ConnectivityState> {
  ConnectivityController(this._dio) : super(ConnectivityState.initial) {
    // Startujemy od razu: pierwszy check natychmiast
    _scheduleNext(Duration.zero);
  }

  final Dio _dio;
  Timer? _timer;

  static const Duration _fast = Duration(seconds: 2);
  static const Duration _normal = Duration(seconds: 15);

  void _scheduleNext(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _check);
  }

  Future<void> _check() async {
    if (!mounted) return;

    // Zapamiętujemy poprzedni stan online/offline
    final wasOnline = state.isOnline;

    state = state.copyWith(isChecking: true);

    bool ok = false;
    try {
      final res = await _dio.get('/internal/health');
      final code = res.statusCode ?? 0;
      ok = code >= 200 && code < 300;
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;

    state = state.copyWith(
      isOnline: ok,
      isChecking: false,
      lastCheck: DateTime.now(),
    );

    // ✅ Logika interwałów:
    // - jeśli offline -> jedziemy szybko (2s)
    // - jeśli online -> normalnie (15s)
    // - jeśli właśnie spadliśmy z online na offline -> też szybko
    final nextDelay = ok ? _normal : _fast;

    // Dodatkowo: gdy dopiero “wróciliśmy” do online, od razu przechodzimy na normalny
    // (czyli nie trzymamy 2s, jeśli już jest ok)
    _scheduleNext(nextDelay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

final connectivityProvider =
StateNotifierProvider<ConnectivityController, ConnectivityState>((ref) {
  final dio = ref.watch(dioProvider);
  return ConnectivityController(dio);
});
