import 'package:flutter/material.dart';

Future<int?> showContractPicker(BuildContext context, Map<String, dynamic>? user) async {
  final contracts = (user?['contracts'] as List?)?.cast<Map>() ?? const [];
  if (contracts.isEmpty) return null;

  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    backgroundColor: const Color(0xFF0B1220),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wybierz kontrakt',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...contracts.map((c) {
              final id = c['id'];
              final title = (c['contractPosition'] ?? '—').toString();
              final type = (c['contractType'] ?? '').toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  height: 62,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(id is int ? id : int.tryParse(id.toString())),
                    child: Text(
                      '$title  •  $type',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
