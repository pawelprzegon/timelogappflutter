import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clockProvider = StreamProvider.autoDispose<DateTime>((ref) {
  Stream<DateTime> tick () async* {
    yield DateTime.now();
    yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }
  return tick();
});