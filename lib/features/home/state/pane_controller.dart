import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Pane { pin, qr }

final paneProvider = StateProvider<Pane>((ref) => Pane.pin);
