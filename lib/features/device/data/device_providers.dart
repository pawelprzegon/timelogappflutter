import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/http/dio_provider.dart';
import '../../admin/state/admin_controller.dart';
import 'device_api.dart';

final deviceTokenProvider = Provider<String>((ref) {
  return ref.watch(adminControllerProvider).token.trim();
});

final deviceApiProvider = Provider<DeviceApi>((ref) {
  final dio = ref.watch(dioProvider);
  final token = ref.watch(deviceTokenProvider);
  return DeviceApi(dio, token);
});
