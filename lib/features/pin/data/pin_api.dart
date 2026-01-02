import 'package:dio/dio.dart';

class PinApi {
  PinApi(this._dio);

  final Dio _dio;

  /// Uwaga: endpoint dopasujemy do Twojego backendu.
  /// Na razie daję sensowny placeholder.

  Future<void> loginWithPin(String pin) async {
    // przykład payloadu
    final res = await _dio.post(
      '/api/device/pin',
      data: {'pin': pin},
    );

    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
  }
}