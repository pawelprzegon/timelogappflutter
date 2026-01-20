import 'package:dio/dio.dart';
import '../../admin/state/user_model.dart';
import '../../logging/logger.dart';

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

  bool get hasToken =>
      _deviceToken
          .trim()
          .isNotEmpty;

  Map<String, dynamic> _tokenOnlyQuery() {
    if (!hasToken) {
      throw StateError('Brak tokena urządzenia – zapisz go w panelu Admina.');
    }
    return <String, dynamic>{'token': _deviceToken};
  }

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
    } else if (qrCode != null && qrCode
        .trim()
        .isNotEmpty) {
      qp['qrCode'] = qrCode.trim();
    } else if (nfcTag != null && nfcTag
        .trim()
        .isNotEmpty) {
      qp['nfcTag'] = nfcTag.trim();
    } else {
      throw ArgumentError('Musisz podać PIN, QR lub NFC tag.');
    }

    return qp;
  }

  /// GET /api/device/active?pin|qrCode|nfcTag&token=...
  /// GET /api/device/active?pin|qrCode|nfcTag&token=...
  Future<DeviceResult> getActiveWithStatus({
    int? pin,
    String? qrCode,
    String? nfcTag,
  }) async {
    final sw = Stopwatch()..start();

    Map<String, dynamic>? safeQp;
    try {
      final qp = _buildQuery(pin: pin, qrCode: qrCode, nfcTag: nfcTag);

      // DEBUG: pokaż query bez pełnego tokena
      safeQp = Map<String, dynamic>.from(qp);
      safeQp['token'] = _maskToken((safeQp['token'] ?? '').toString());

      // ignore: avoid_print
      print('[DeviceApi] GET $_basePath/active qp=$safeQp');

      final res = await _dio.get(
        '$_basePath/active',
        queryParameters: qp,
        options: Options(validateStatus: (_) => true),
      );

      final code = res.statusCode ?? 0;

      // ignore: avoid_print
      print('[DeviceApi] <- $code (${sw.elapsedMilliseconds}ms)');

      if (code == 200) {
        if (res.data is Map<String, dynamic>) {
          return DeviceResult(200, res.data as Map<String, dynamic>);
        }
        return const DeviceResult(200, <String, dynamic>{});
      }

      if (code == 204) return const DeviceResult(204, null);

      // Inne kody
      if (res.data is Map<String, dynamic>) {
        return DeviceResult(code, res.data as Map<String, dynamic>);
      }
      return DeviceResult(code, null);
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;

      // ignore: avoid_print
      print('[DeviceApi][DIO] GET $_basePath/active qp=$safeQp '
          '-> $code (${sw.elapsedMilliseconds}ms) '
          'type=${e.type} msg=${e.message}');

      if (e.response?.data is Map<String, dynamic>) {
        return DeviceResult(code == 0 ? 500 : code, e.response!.data as Map<String, dynamic>);
      }
      return DeviceResult(code == 0 ? 500 : code, null);
    } catch (e) {
      // ignore: avoid_print
      print('[DeviceApi][ERR] GET $_basePath/active qp=$safeQp '
          '-> 500 (${sw.elapsedMilliseconds}ms) err=$e');

      return const DeviceResult(500, null);
    } finally {
      sw.stop();
    }
  }

  /// GET /api/device/user?...
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
      message: 'Serwer zwrócił błąd: $code',
    );
  }

  // POST /api/device/shiftStart?token=...
  Future<Map<String, dynamic>> startShift({
    required int userId,
    required int contractId,
  }) async {
    if (!hasToken) throw StateError(
        'Brak tokena urządzenia – zapisz go w panelu Admina.');

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
    if (!hasToken) throw StateError(
        'Brak tokena urządzenia – zapisz go w panelu Admina.');

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
    throw DioException(requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse);
  }

  Future<Map<String, dynamic>> startBreak({required int userId}) async {
    if (!hasToken) throw StateError(
        'Brak tokena urządzenia – zapisz go w panelu Admina.');

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
    throw DioException(requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse);
  }

  Future<Map<String, dynamic>> stopBreak({required int userId}) async {
    if (!hasToken) throw StateError(
        'Brak tokena urządzenia – zapisz go w panelu Admina.');

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
    throw DioException(requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse);
  }


  /// GET /api/device/user-list?token=...
  Future<List<UserListModel>> getUserList() async {
    final sw = Stopwatch()..start();

    final qp = _tokenOnlyQuery();
    final safeQp = Map<String, dynamic>.from(qp)
      ..['token'] = _maskToken(_deviceToken);

    talker.info('[DeviceApi] GET $_basePath/user-list qp=$safeQp');

    final res = await _dio.get(
      '$_basePath/user-list',
      queryParameters: qp,
      options: Options(validateStatus: (_) => true),
    );

    final code = res.statusCode ?? 0;
    talker.info('[DeviceApi] <- $code (${sw.elapsedMilliseconds}ms)');

    if (code == 204) return const [];

    if (code >= 200 && code < 300 && res.data is List) {
      final raw = res.data as List;
      return raw
          .map((e) => UserListModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      message: 'Serwer zwrócił błąd: $code',
    );
  }
}