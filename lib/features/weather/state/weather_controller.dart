import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/location/location_service.dart';
import '../data/dio_provider.dart';

class WeatherData {
  final double tempC;
  final double feelsLikeC;
  final String description;
  final String icon; // np. "10d"
  final int humidity; // %
  final double windSpeed; // m/s

  const WeatherData({
    required this.tempC,
    required this.feelsLikeC,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });


  @override
  String toString() {
    return 'WeatherData(tempC: $tempC, feelsLikeC: $feelsLikeC, desc: $description, icon: $icon, humidity: $humidity, wind: $windSpeed)';
  }
}

String openWeatherIconUrl(String icon, {int scale = 1}) {
  // Jeśli skala to 1, używamy standardowego formatu bez "@1x"
  if (scale <= 1) {
    return 'https://openweathermap.org/img/wn/$icon.png';
  }
  // Dla skali 2 lub większej używamy formatu @2x, @4x itd.
  print(icon);
  return 'https://openweathermap.org/img/wn/$icon@${scale}x.png';
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String description;
  final String icon;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.icon,
  });
}

class WeatherState {
  final bool weatherStatus;
  final DateTime? lastCheck;
  final bool isChecking;
  final String? error;
  final WeatherData? data;
  final List<DailyForecast> daily;

  const WeatherState({
    required this.weatherStatus,
    required this.lastCheck,
    required this.isChecking,
    required this.error,
    required this.data,
    required this.daily,
  });

  WeatherState copyWith({
    bool? weatherStatus,
    DateTime? lastCheck,
    bool? isChecking,
    String? error,
    WeatherData? data,
    List<DailyForecast>? daily,
  }) {
    return WeatherState(
      weatherStatus: weatherStatus ?? this.weatherStatus,
      lastCheck: lastCheck ?? this.lastCheck,
      isChecking: isChecking ?? this.isChecking,
      error: error ?? this.error,
      data: data ?? this.data,
      daily: daily ?? this.daily,
    );
  }

  static const initial = WeatherState(
    weatherStatus: false,
    lastCheck: null,
    isChecking: false,
    error: null,
    data: null,
    daily: [],
  );
}

final weatherControllerProvider =
StateNotifierProvider<WeatherStateController, WeatherState>((ref) {
  return WeatherStateController(ref);
});

class WeatherStateController extends StateNotifier<WeatherState> {
  WeatherStateController(this._ref, {Dio? dio})
      : _dio = dio ?? _ref.read(openWeatherDioProvider),
        super(WeatherState.initial);

  final Ref _ref;
  final Dio _dio;
  final String _openWeatherApiKey = Env.openWeatherApiKey;

  Future<void> refresh() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, error: null);

    try {
      final pos = await LocationService.getCurrentPosition();
      final lat = pos.latitude;
      final lon = pos.longitude;

      final res = await _dio.get(
        '/onecall',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'exclude': 'minutely,hourly',
          'appid': _openWeatherApiKey,
          'units': 'metric',
          'lang': 'pl',
        },
      );

      final code = res.statusCode ?? 0;
      final ok = code >= 200 && code < 300;

      if (!ok) {
        state = state.copyWith(
          weatherStatus: false,
          isChecking: false,
          lastCheck: DateTime.now(),
          error: 'HTTP $code',
          data: null,
          daily: []
        );
        return;
      }

      final json = res.data as Map<String, dynamic>;
      final current = (json['current'] as Map<String, dynamic>?) ?? const {};
      final weatherList = (current['weather'] as List?) ?? const [];
      final weather0 = weatherList.isNotEmpty
          ? (weatherList.first as Map<String, dynamic>)
          : const <String, dynamic>{};

      final weatherData = WeatherData(
        tempC: ((current['temp'] as num?) ?? 0).toDouble(),
        feelsLikeC: ((current['feels_like'] as num?) ?? 0).toDouble(),
        description: (weather0['description'] as String?) ?? '—',
        icon: (weather0['icon'] as String?) ?? '01d',
        humidity: ((current['humidity'] as num?) ?? 0).toInt(),
        windSpeed: ((current['wind_speed'] as num?) ?? 0).toDouble(),
      );

      final dailyList = (json['daily'] as List?) ?? const [];

      final List<DailyForecast> forecast = dailyList.take(5).map((dayJson) {
        final dayWeather = (dayJson['weather'] as List).first;
        return DailyForecast(
          date: DateTime.fromMillisecondsSinceEpoch((dayJson['dt'] as int) * 1000),
          tempMax: (dayJson['temp']['max'] as num).toDouble(),
          tempMin: (dayJson['temp']['min'] as num).toDouble(),
          description: dayWeather['description'] as String,
          icon: dayWeather['icon'] as String,
        );
      }).toList();


      state = state.copyWith(
        weatherStatus: true,
        lastCheck: DateTime.now(),
        isChecking: false,
        error: null,
        data: weatherData,
        daily: forecast,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        weatherStatus: false,
        isChecking: false,
        lastCheck: DateTime.now(),
        error: e.message ?? 'Dio error',
        data: null,
        daily: [],
      );
    } catch (e) {
      state = state.copyWith(
        weatherStatus: false,
        isChecking: false,
        lastCheck: DateTime.now(),
        error: e.toString(),
        data: null,
        daily: [],
      );
    }
  }
}
