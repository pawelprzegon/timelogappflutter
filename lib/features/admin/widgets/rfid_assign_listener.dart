import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelogappflutter/features/admin/state/user_model.dart';
import 'package:timelogappflutter/features/logging/logger.dart';

import '../../device/data/device_providers.dart';
import '../../rfid/data/rfid_reader_provider.dart';
import 'admin_rfid_writer_screen.dart';


class RfidAssignListener extends ConsumerWidget {
  const RfidAssignListener({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(rfidUidStreamProvider, (prev, next) async {
      final uid = next.valueOrNull;
      if (uid == null || uid.trim().isEmpty) return;

      final userId = ref.read(selectedUserIdProvider);
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Najpierw wybierz użytkownika')),
        );
        return;
      }

      try {
        final api = ref.read(deviceApiProvider);
        final UserListModel response = await api.assignNfcTag(userId: userId, nfcUid: uid.trim());


        // 🔥 to wymusi ponowne pobranie listy userów
        ref.invalidate(deviceUsersProvider);

        final label = '${response.label}';
        final nfc = (response.NFCTagID?.trim().isNotEmpty ?? false)
            ? response.NFCTagID!.trim()
            : uid.trim();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Przypisano kartę: $nfc → $label')),
        );
      } catch (e) {
        if (!context.mounted) return;
        talker.error(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd przypisania: $e')),
        );
      }
    });

    return const SizedBox.shrink();
  }
}
