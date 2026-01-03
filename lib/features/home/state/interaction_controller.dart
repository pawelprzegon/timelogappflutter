import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'interaction_state.dart';

final interactionProvider = StateProvider<InteractionState>((ref) {
  return InteractionState.idle;
});

//Co to jest StateProvider?
// Najprostszy provider — trzyma jedną wartość i pozwala ją zmieniać przez .state.
//
// odczyt: ref.watch(interactionProvider)
//
// zapis: ref.read(interactionProvider.notifier).state = InteractionState.pinEntry