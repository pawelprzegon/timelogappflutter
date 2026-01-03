import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Mode {qr, pin}

final modeProvider = StateProvider<Mode>((ref) => Mode.pin);