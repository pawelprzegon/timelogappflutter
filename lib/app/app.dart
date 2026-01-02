import 'package:flutter/material.dart';
import 'router.dart';

class TimeLogApp extends StatelessWidget {
  const TimeLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TimeLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: router,
    );
  }
}