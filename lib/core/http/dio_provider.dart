import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../../features/admin/state/admin_controller.dart';

final dioProvider = Provider<Dio>((ref) {
  final token = ref
      .watch(adminControllerProvider)
      .token
      .trim();

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onError: (e, handler) {
        // Na razie tylko log w konsoli
        // później podłączymy to pod AppLogger/overlay
        // ignore: avoid_print
        print('HTTP error: ${e.type} ${e.response?.statusCode} ${e.requestOptions.uri}');
        handler.next(e);
      },
    ),
  );

  return dio;
});