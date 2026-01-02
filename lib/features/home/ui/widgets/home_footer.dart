import 'package:flutter/material.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({
    super.key,
    required this.weatherText,
    required this.deviceText,
  });

  final String weatherText;
  final String deviceText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(weatherText, style: const TextStyle(color: Color(0xFF94A3B8))),
        const Spacer(),
        Text(deviceText, style: const TextStyle(color: Color(0xFF94A3B8))),
      ],
    );
  }
}
