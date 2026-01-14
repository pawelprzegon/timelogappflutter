import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Definiujemy Notifier, który zarządza prostą prawdą/fałszem
class SessionUiNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Startujemy od widoku Simple (false)

  void toggle() {
    state = !state; // Przełączamy stan na przeciwny
  }
}

// Udostępniamy go w aplikacji
final sessionUiProvider = NotifierProvider<SessionUiNotifier, bool>(() {
  return SessionUiNotifier();
});

class SessionUiToggle extends ConsumerWidget {
  const SessionUiToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nasłuchujemy, czy widok jest Detailed
    final isDetailed = ref.watch(sessionUiProvider);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Szczegółowe informacje pracownika',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Switch(
          value: isDetailed,
          onChanged: (value) {
            ref.read(sessionUiProvider.notifier).toggle();
          },
        ),
      ],
    );
  }
}
