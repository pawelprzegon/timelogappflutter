import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/theme/theme_controller.dart';
import 'router.dart';
import '../core/kiosk/immersive_guard.dart';

class TimeLogApp extends ConsumerWidget {
  const TimeLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return ImmersiveGuard(
      child: MaterialApp.router(
        title: 'TimeLog',
        debugShowCheckedModeBanner: false,
        theme: theme,
        routerConfig: router,
      ),
    );
  }
}
