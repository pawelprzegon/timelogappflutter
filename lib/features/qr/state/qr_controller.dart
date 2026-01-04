import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final mobileScannerControllerProvider = Provider<MobileScannerController>((ref) {
  final c = MobileScannerController(
    facing: CameraFacing.front, // ✅ przednia kamera
    autoStart: false,           // ✅ wyłączamy autoStart
  );

  ref.onDispose(() => c.dispose());
  return c;
});

class QrState {
  final bool cameraActive;
  final String? error;

  const QrState({
    required this.cameraActive,
    required this.error,
  });

  static const initial = QrState(cameraActive: false, error: null);

  QrState copyWith({
    bool? cameraActive,
    String? error,
  }) {
    return QrState(
      cameraActive: cameraActive ?? this.cameraActive,
      error: error,
    );
  }
}

final qrControllerProvider =
StateNotifierProvider<QrController, QrState>((ref) {
  return QrController();
});

class QrController extends StateNotifier<QrState> {
  QrController() : super(QrState.initial);

  final MobileScannerController scanner =
  MobileScannerController(facing: CameraFacing.front);

  Future<void> startCamera() async {
    if (state.cameraActive) return;
    try {
      await scanner.start();
      if (!mounted) return;
      state = state.copyWith(cameraActive: true, error: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(cameraActive: false, error: e.toString());
    }
  }

  Future<void> stopCamera() async {
    if (!state.cameraActive) return;
    try {
      await scanner.stop();
    } finally {
      if (!mounted) return;
      state = state.copyWith(cameraActive: false, error: null);
    }
  }

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }
}
