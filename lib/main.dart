import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> enableImmersiveSticky() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ fullscreen (jeśli robisz)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ✅ ekran nie gaśnie
  await WakelockPlus.enable();

  runApp(
    const ProviderScope(
      child: TimeLogApp(),
    ),
  );
}
