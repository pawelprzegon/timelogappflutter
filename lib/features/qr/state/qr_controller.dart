import 'package:flutter_riverpod/flutter_riverpod.dart';

class QrState {
  final bool cameraActive;

  const QrState({required this.cameraActive});

  static const initial = QrState(cameraActive: false);

  QrState copyWith({bool? cameraActive}) =>
      QrState(cameraActive: cameraActive ?? this.cameraActive);
}

final qrControllerProvider = StateNotifierProvider<QrController, QrState>((ref) {
  return QrController();
});

class QrController extends StateNotifier<QrState> {
  QrController() : super(QrState.initial);

  void startCamera() {
    if (state.cameraActive) return;
    state = state.copyWith(cameraActive: true);
  }

  void stopCamera() {
    if (!state.cameraActive) return;
    state = state.copyWith(cameraActive: false);
  }
}
