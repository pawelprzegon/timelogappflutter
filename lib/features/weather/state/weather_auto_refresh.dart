import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'weather_controller.dart';

/// Jedna zmienna: co ile odświeżać pogodę
final weatherRefreshIntervalProvider = Provider<Duration>((ref) {
  return const Duration(minutes: 10); // <- ustaw X minut
});

/// Provider, który uruchamia od razu refresh + potem co X minut.
/// autoDispose = timer znika, gdy nikt nie używa (np. ekran zamknięty)
final weatherAutoRefreshProvider = Provider.autoDispose<void>((ref) {
  // odpal od razu po zbudowaniu
  Future.microtask(() {
    ref.read(weatherControllerProvider.notifier).refresh();
  });

  final interval = ref.watch(weatherRefreshIntervalProvider);

  final timer = Timer.periodic(interval, (_) {
    ref.read(weatherControllerProvider.notifier).refresh();
  });

  ref.onDispose(timer.cancel);
});
