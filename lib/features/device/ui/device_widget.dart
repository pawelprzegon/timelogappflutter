import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rfid/state/rfid_controller.dart';

class DeviceCard extends ConsumerWidget {
  const DeviceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfid = ref.watch(rfidControllerProvider);

    return Card(
      elevation: 1,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                rfid.isConnected ? 'RFID: podłączony' : 'RFID: odłączony', // Skróciłem tekst, by zyskać miejsce
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              rfid.isConnected ? Icons.nfc : Icons.error_outlined,
              size: 18,
              color: rfid.isConnected ? Colors.tealAccent : Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}