import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Mode {rfid, qr, pin}

final modeProvider = StateProvider<Mode>((ref) => Mode.rfid);