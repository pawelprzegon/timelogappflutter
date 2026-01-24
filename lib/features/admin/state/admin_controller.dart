import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/prefs.dart';

class AdminState {
  final String token;
  final String offlineMessage;
  final String adminPanelPassword;
  final bool isLoading;

  const AdminState({
    required this.token,
    required this.offlineMessage,
    required this.adminPanelPassword,
    required this.isLoading,
  });

  AdminState copyWith({
    String? token,
    String? offlineMessage,
    String? adminPanelPassword,
    bool? isLoading,
  }) {
    return AdminState(
      token: token ?? this.token,
      offlineMessage: offlineMessage ?? this.offlineMessage,
      adminPanelPassword: adminPanelPassword?? this.adminPanelPassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const empty = AdminState(token: '', offlineMessage: '', adminPanelPassword: '', isLoading: true);
}

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(AdminState.empty) {
    _load();
  }

  Future<void> _load() async {
    final t = await DevicePrefs.getToken() ?? '';
    final m = await DevicePrefs.getOfflineMessage() ?? '';
    final p = await DevicePrefs.getAdminPassword() ?? '';
    state = state.copyWith(token: t, offlineMessage: m, adminPanelPassword: p, isLoading: false);
  }

  void setTokenLocal(String v) {
    state = state.copyWith(token: v);
  }

  void setOfflineLocal(String v) {
    state = state.copyWith(offlineMessage: v);
  }

  void setAdminPasswordLocal(String v) {
    state = state.copyWith(adminPanelPassword: v);
  }

  Future<void> saveToken() async {
    // ignore: avoid_print
    final v = state.token.trim();
    if (v.isEmpty) return;
    await DevicePrefs.setToken(v);
  }

  Future<void> saveOfflineMessage() async {
    await DevicePrefs.setOfflineMessage(state.offlineMessage);
  }

  Future<void> saveAdminPassword() async {
    await DevicePrefs.setAdminPassword(state.adminPanelPassword.trim());
  }
}

final adminControllerProvider =
StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});
