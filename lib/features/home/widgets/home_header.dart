import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/hold_to_open_controller.dart';

String _formatDate(DateTime dt) {
  const days = ['pon', 'wt', 'śr', 'czw', 'pt', 'sob', 'nd'];
  const months = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];

  final d = dt.toLocal();
  final dow = days[(d.weekday - 1).clamp(0, 6)];
  final mon = months[d.month - 1];
  return '$dow, ${d.day} $mon ${d.year}';
}

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
        HoldToOpenAdminButton(),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(DateTime.now()),
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 36 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
