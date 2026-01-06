import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final openWeatherDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/3.0',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});