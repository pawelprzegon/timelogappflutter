import 'package:flutter_riverpod/flutter_riverpod.dart';

final secondTickerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
        (_) => DateTime.now(),
  );
});
