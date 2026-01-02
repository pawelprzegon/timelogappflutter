import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.timeText,
    required this.scale,
  });

  final String timeText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.push('/admin'),
          borderRadius: BorderRadius.circular(12 * scale),
          child: Padding(
            padding: EdgeInsets.all(6 * scale),
            child: Icon(Icons.timelapse, size: 48 * scale),
          ),
        ),
        const Spacer(),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 36 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
