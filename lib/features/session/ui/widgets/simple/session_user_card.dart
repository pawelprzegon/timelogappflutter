import 'package:flutter/material.dart';

class SessionUserCard extends StatelessWidget {
  const SessionUserCard({super.key, required this.user, required this.scale});
  final Map<String, dynamic>? user;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final u = user ?? const {};
    final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Użytkownik', style: TextStyle(color: Colors.white70, fontSize: 15 * scale)),
            SizedBox(height: 8 * scale),
            Text(
              name.isEmpty ? '—' : name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8 * scale),

          ],
        ),
      ),
    );
  }
}

