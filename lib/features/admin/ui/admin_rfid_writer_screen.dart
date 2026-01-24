import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rfid/data/rfid_reader_provider.dart';
import '../widgets/admin_rfid_writer_screen.dart';
import '../widgets/rfid_assign_listener.dart';

class RfidWriterScreen extends ConsumerWidget {
  const RfidWriterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedUserIdProvider);
    final lastUid = ref.watch(rfidUidStreamProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('RFID Writer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listener musi być w drzewie tego ekranu
            const RfidAssignListener(),

            const Text('Wybierz użytkownika:'),
            const SizedBox(height: 8),

            PickUserDropdown(
              value: selectedId,
              onChanged: (v) => ref.read(selectedUserIdProvider.notifier).state = v,
            ),

            const SizedBox(height: 16),
            Text('Ostatnio odczytany UID: ${lastUid ?? "-"}'),
            const SizedBox(height: 8),
            const Text('Przyłóż kartę do czytnika, aby przypisać do wybranego użytkownika.'),
          ],
        ),
      ),
    );
  }
}
