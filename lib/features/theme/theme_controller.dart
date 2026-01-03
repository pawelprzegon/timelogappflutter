import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seedColorProvider = StateProvider<Color>((ref) => Colors.teal);

final appThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(seedColorProvider);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );
});
