import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/mode_controller.dart';

class ModeToggle extends ConsumerWidget {
  const ModeToggle({
    super.key,
    required this.isEnabled,
  });

  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(modeProvider);

    int toIndex(Mode m) => switch (m) {
      Mode.rfid => 0,
      Mode.qr => 1,
      Mode.pin => 2,
    };

    Mode fromIndex(int i) => switch (i) {
      0 => Mode.rfid,
      1 => Mode.qr,
      _ => Mode.pin,
    };

    return AbsorbPointer(
      absorbing: !isEnabled,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.55,
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('RFID'), icon: Icon(Icons.nfc)),
            ButtonSegment(value: 1, label: Text('QR'), icon: Icon(Icons.qr_code)),
            ButtonSegment(value: 2, label: Text('PIN'), icon: Icon(Icons.dialpad)),
          ],
          selected: {toIndex(mode)},
          onSelectionChanged: (sel) {
            final idx = sel.first;
            ref.read(modeProvider.notifier).state = fromIndex(idx);
          },
        ),
      ),
    );
  }
}
