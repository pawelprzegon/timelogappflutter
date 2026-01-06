import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart'; // Dodaj to
import '../../features/logging/state/talker_provider.dart';
import '../config/env.dart';


final dioProvider = Provider<Dio>((ref) {
  // Pobieramy instancję talkera z Twojego providera
  final talker = ref.watch(talkerProvider);

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 5), // 2s to czasem mało dla wolnego LTE
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Dodajemy profesjonalny logger dla Dio
  dio.interceptors.add(
    TalkerDioLogger(
      talker: talker,
      settings: TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseData: true,
        printRequestData: true,
        printResponseHeaders: false,
        // Filtry przyjmują obiekt RequestOptions lub Response
        requestFilter: (options) {
          // Zwróć false, aby ukryć log
          return !options.path.contains('/internal/health');
        },
        responseFilter: (response) {
          // Zwróć false, aby ukryć log
          return !response.requestOptions.path.contains('/internal/health');
        },
        // Możesz dodać filtry, żeby nie logować np. tokenów (bezpieczeństwo)
      ),
    ),
  );

  return dio;
});