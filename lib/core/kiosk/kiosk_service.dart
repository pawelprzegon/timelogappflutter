import 'package:kiosk_mode/kiosk_mode.dart';

class KioskService {
  static Future<void> pin() => startKioskMode();
  static Future<void> unpin() => stopKioskMode();
}
