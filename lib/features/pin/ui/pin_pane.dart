import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/pin_controller.dart';

class PinPane extends ConsumerWidget {
  const PinPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pinControllerProvider);
    final ctrl = ref.read(pinControllerProvider.notifier);

    final disabled = state.isSubmitting;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PinDots(filled: state.pin.length, total: kPinLength),
        const SizedBox(height: 36),

        if (state.isSubmitting) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          const Text('Logowanie...', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
        ] else ...[
          if (state.error != null) ...[
            Text(
              state.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          _Keypad(
            onDigit: ctrl.addDigit,
            onBackspace: ctrl.backspace,
            onClear: ctrl.clear,
            disabled: disabled,
          ),
        ],
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final on = i < filled;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? Colors.white : Colors.white.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.disabled,
  });

  final void Function(int) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    // 3 kolumny jak klasyczna klawiatura
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [
          _row([1, 2, 3]),
          const SizedBox(height: 10),
          _row([4, 5, 6]),
          const SizedBox(height: 10),
          _row([7, 8, 9]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.close,
                  label: 'CLR',
                  onPressed: disabled ? null : onClear,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _digitBtn(0)),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  icon: Icons.backspace_outlined,
                  label: 'DEL',
                  onPressed: disabled ? null : onBackspace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<int> digits) {
    return Row(
      children: [
        for (var i = 0; i < digits.length; i++) ...[
          Expanded(child: _digitBtn(digits[i])),
          if (i != digits.length - 1) const SizedBox(width: 10),
        ]
      ],
    );
  }

  Widget _digitBtn(int digit) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: disabled ? null : () => onDigit(digit),
        child: Text(
          '$digit',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
