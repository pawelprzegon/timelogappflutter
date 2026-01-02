import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/prefs.dart';

class AdminState {
  final String token;
  final String offlineMessage;
  final bool isLoading;

  const AdminState({
    required this.token,
    required this.offlineMessage,
    required this.isLoading,
  });

  AdminState copyWith({
    String? token,
    String? offlineMessage,
    bool? isLoading,
  }) {
    return AdminState(
      token: token ?? this.token,
      offlineMessage: offlineMessage ?? this.offlineMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = AdminState(token: '', offlineMessage: '', isLoading: true);
}

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(AdminState.empty) {
    _load();
  }

  Future<void> _load() async {
    final t = await DevicePrefs.getToken() ?? '';
    final m = await DevicePrefs.getOfflineMessage() ?? '';
    state = state.copyWith(token: t, offlineMessage: m, isLoading: false);
  }

  void setTokenLocal(String v) {
    state = state.copyWith(token: v);
  }

  void setOfflineLocal(String v) {
    state = state.copyWith(offlineMessage: v);
  }

  Future<void> saveToken() async {
    // ignore: avoid_print
    print('Saved token len=${state.token.trim().length}');
    final v = state.token.trim();
    if (v.isEmpty) return;
    await DevicePrefs.setToken(v);
  }

  Future<void> saveOfflineMessage() async {
    await DevicePrefs.setOfflineMessage(state.offlineMessage);
  }
}

final adminControllerProvider =
StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});
