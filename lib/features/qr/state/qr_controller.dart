import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/state/pane_controller.dart';

class QrController {
  Timer? _t;

  void openQr(Ref ref) {
    _t?.cancel();
    ref.read(paneProvider.notifier).state = Pane.qr;

    _t = Timer(const Duration(seconds: 5), () {
      // wróć do PIN
      ref.read(paneProvider.notifier).state = Pane.pin;
    });
  }

  void closeQr(Ref ref) {
    _t?.cancel();
    ref.read(paneProvider.notifier).state = Pane.pin;
  }

  void dispose() => _t?.cancel();
}
