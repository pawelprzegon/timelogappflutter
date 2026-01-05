import 'package:flutter/services.dart';

class SystemUi {
  static Future<void> hide() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}