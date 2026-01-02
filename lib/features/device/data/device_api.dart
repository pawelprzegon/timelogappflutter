import 'package:dio/dio.dart';

String _maskToken(String t) {
  final v = t.trim();
  if (v.isEmpty) return '<EMPTY>';
  if (v.length <= 8) return v;
  return '${v.substring(0, 4)}...${v.substring(v.length - 4)}';
}

class DeviceResult {
  final int status;
  final Map<String, dynamic>? body;

  const DeviceResult(this.status, this.body);
}

class DeviceApi {
  DeviceApi(this._dio, this._deviceToken);

  final Dio _dio;
  final String _deviceToken;

  static const _basePath = '/api/device';

  bool get hasToken => _deviceToken.trim().isNotEmpty;

  Map<String, dynamic> _buildQuery({
    int? pin,
    String? qrCode,
    String? nfcTag,
  }) {
    if (!hasToken) {
      throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');
    }

    final qp = <String, dynamic>{'token': _deviceToken};

    if (pin != null) {
      qp['pin'] = pin;
    } else if (qrCode != null && qrCode.trim().isNotEmpty) {
      qp['qrCode'] = qrCode.trim();
    } else if (nfcTag != null && nfcTag.trim().isNotEmpty) {
      qp['nfcTag'] = nfcTag.trim();
    } else {
      throw ArgumentError('Musisz podać PIN, QR lub NFC tag.');
    }

    return qp;
  }

  /// GET /api/device/active?pin|qrCode|nfcTag&token=...
  Future<DeviceResult> getActiveWithStatus({
    int? pin,
    String? qrCode,
    String? nfcTag,
  }) async {
    try {
      // ignore: avoid_print
      print('DeviceApi.getActiveWithStatus: rawToken="${_maskToken(_deviceToken)}"');
      final qp = _buildQuery(pin: pin, qrCode: qrCode, nfcTag: nfcTag);

      // DEBUG: pokaż query bez pełnego tokena
      final safe = Map<String, dynamic>.from(qp);
      final tok = (safe['token'] ?? '').toString();
      safe['token'] = _maskToken(tok);
      // ignore: avoid_print
      print('GET /api/device/active query=$safe');

      final res = await _dio.get(
        '$_basePath/active',
        queryParameters: qp,
        options: Options(validateStatus: (code) => true),
      );


      final code = res.statusCode ?? 0;

      // 200 może mieć pusty body
      if (code == 200) {
        if (res.data == null) return const DeviceResult(200, <String, dynamic>{});
        if (res.data is Map<String, dynamic>) return DeviceResult(200, res.data as Map<String, dynamic>);
        return const DeviceResult(200, <String, dynamic>{});
      }

      // 204 -> traktuj jak OK bez treści (jeśli backend tak zwróci)
      if (code == 204) return const DeviceResult(204, null);

      // Inne kody
      if (res.data is Map<String, dynamic>) return DeviceResult(code, res.data as Map<String, dynamic>);
      return DeviceResult(code, null);
    } catch (_) {
      return const DeviceResult(500, null);
    }
  }

  /// GET /api/device/user?... (jeśli będziesz potrzebował)
  Future<Map<String, dynamic>?> getUser({
    int? pin,
    String? qrCode,
    String? nfcTag,
  }) async {
    final res = await _dio.get(
      '$_basePath/user',
      queryParameters: _buildQuery(pin: pin, qrCode: qrCode, nfcTag: nfcTag),
      options: Options(validateStatus: (c) => true),
    );

    final code = res.statusCode ?? 0;
    if (code == 204) return null;
    if (code >= 200 && code < 300 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
    );
  }

  // POST /api/device/shiftStart?token=...
  Future<Map<String, dynamic>> startShift({
    required int userId,
    required int contractId,
  }) async {
    if (!hasToken) throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');

    final res = await _dio.post(
      '$_basePath/shiftStart',
      queryParameters: {'token': _deviceToken},
      data: {'userId': userId, 'contractId': contractId},
      options: Options(validateStatus: (c) => true),
    );

    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
    );
  }

  Future<Map<String, dynamic>> stopShift({required int userId}) async {
    if (!hasToken) throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');

    final res = await _dio.post(
      '$_basePath/shiftStop',
      queryParameters: {'token': _deviceToken},
      data: {'userId': userId},
      options: Options(validateStatus: (c) => true),
    );

    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw DioException(requestOptions: res.requestOptions, response: res, type: DioExceptionType.badResponse);
  }

  Future<Map<String, dynamic>> startBreak({required int userId}) async {
    if (!hasToken) throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');

    final res = await _dio.post(
      '$_basePath/workbreakStart',
      queryParameters: {'token': _deviceToken},
      data: {'userId': userId},
      options: Options(validateStatus: (c) => true),
    );

    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw DioException(requestOptions: res.requestOptions, response: res, type: DioExceptionType.badResponse);
  }

  Future<Map<String, dynamic>> stopBreak({required int userId}) async {
    if (!hasToken) throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');

    final res = await _dio.post(
      '$_basePath/workbreakStop',
      queryParameters: {'token': _deviceToken},
      data: {'userId': userId},
      options: Options(validateStatus: (c) => true),
    );

    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300 && res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    throw DioException(requestOptions: res.requestOptions, response: res, type: DioExceptionType.badResponse);
  }


// analogicznie stopShift/startBreak/stopBreak dodamy jak będziemy podłączać UI akcji
}
