import 'package:flutter/material.dart';

class SessionBusyOverlay extends StatelessWidget {
  const SessionBusyOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      ignoring: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0x66000000)),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
