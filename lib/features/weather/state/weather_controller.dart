

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/dio_provider.dart';

class WeatherState {
  final bool weatherStatus;
  final DateTime? lastCheck;
  final bool isChecking;
  final String? error;

  const WeatherState({
    required this.weatherStatus,
    required this.lastCheck,
    required this.isChecking,
    required this.error,
  });

  WeatherState copyWith({
    bool? weatherStatus,
    DateTime? lastCheck,
    bool? isChecking,
    String? error,
  }) {
    return WeatherState(
        weatherStatus: weatherStatus ?? this.weatherStatus,
        lastCheck: lastCheck ?? this.lastCheck,
        isChecking: isChecking ?? this.isChecking,
        error: error ?? this.error
    );
  }
  
  static const initial = WeatherState(weatherStatus: false, lastCheck: null, isChecking: false, error: null);
}

final HealthControllerProvider = StateNotifierProvider<WeatherStateController, WeatherState>((ref) {
  return WeatherStateController(ref);
});


class WeatherStateController extends StateNotifier<WeatherState> {
  WeatherStateController(this._ref, {Dio? dio})
      : _dio = dio ?? _ref.read(dioProvider),
        super(WeatherState.initial);

  final Ref _ref;
  final Dio _dio;

  Future<void> refresh() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, error: null);

    try {
      final res = await _dio.get('/internal/health/');

      final code = res.statusCode ?? 0;
      final ok = code >= 200 && code < 300;

      print("Health: " + res.toString());

      state = state.copyWith(
        weatherStatus: ok,
        lastCheck: DateTime.now(),
        isChecking: false,
        error: null,
      );
    } on DioException catch (e) {
      // jeśli wpadnie tu, to raczej weatherStatus = false
      state = state.copyWith(
        weatherStatus: false,
        isChecking: false,
        error: e.message ?? 'Dio error',
      );
    } catch (e) {
      state = state.copyWith(
        weatherStatus: false,
        isChecking: false,
        error: e.toString(),
      );
    }
  }
}

