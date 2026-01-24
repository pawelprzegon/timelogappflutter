import 'package:shared_preferences/shared_preferences.dart';

class DevicePrefs {
  static const _kToken = 'device_token';
  static const _kOfflineMessage = 'offline_message';
  static const _kAdminPassword = 'admin_panel_password';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<void> setToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final v = value.trim().replaceAll(RegExp(r'\s+'), '');
    await prefs.setString(_kToken, v);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
  }

  static Future<String?> getOfflineMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kOfflineMessage);
  }

  static Future<void> setOfflineMessage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final v = value.trim();
    if (v.isEmpty) {
      await prefs.remove(_kOfflineMessage);
    } else {
      await prefs.setString(_kOfflineMessage, v);
    }
  }

  static Future<String?> getAdminPassword() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAdminPassword);
  }

  static Future<void> setAdminPassword(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAdminPassword, v);
  }

}