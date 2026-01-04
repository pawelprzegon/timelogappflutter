import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/ticker.dart';
import '../../model/active_session.dart';

class SessionActiveCard extends ConsumerWidget {
  const SessionActiveCard({super.key, required this.active, required this.scale});
  final ActiveSession? active;
  final double scale;

  String _two(int n) => n.toString().padLeft(2, '0');

  String formatClock(DateTime dt) {
    final l = dt.toLocal();
    return '${_two(l.hour)}:${_two(l.minute)}:${_two(l.second)}';
  }

  String formatDuration(Duration d) {
    final s = d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final ss = s % 60;
    if (h > 0) return '${_two(h)}:${_two(m)}:${_two(ss)}';
    return '${_two(m)}:${_two(ss)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = active;

    // ✅ rebuild co 1s
    final now = ref.watch(secondTickerProvider).maybeWhen(
      data: (v) => v,
      orElse: () => DateTime.now(),
    );

    final shiftStart = a?.start;
    final shiftDur = (shiftStart == null) ? null : now.difference(shiftStart);

    final breakStart = a?.workbreak?.start;
    final breakDur = (breakStart == null) ? null : now.difference(breakStart);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: a == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sesja', style: TextStyle(color: Colors.white70, fontSize: 15 * scale)),
            SizedBox(height: 10 * scale),
            Text(
              'Brak aktywnej zmiany',
              style: TextStyle(color: Colors.white, fontSize: 22 * scale, fontWeight: FontWeight.w800),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sesja', style: TextStyle(color: Colors.white70, fontSize: 15 * scale)),
            SizedBox(height: 10 * scale),
            Text(
              'Aktywna zmiana',
              style: TextStyle(color: Colors.white, fontSize: 22 * scale, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 12 * scale),

            // ✅ Nowe: czasy
            Wrap(
              spacing: 10 * scale,
              runSpacing: 10 * scale,
              children: [
                Row(
                  spacing: 10.0 * scale,
                  children: [
                    _pill('Stanowisko: ${a.contract?.contractPosition ?? '—'}', scale),
                    _pill('Typ: ${a.contract?.contractType ?? '—'}', scale),
                  ],
                ),

                Row(
                  spacing: 10.0 * scale,
                  children: [
                    if (shiftStart != null) _pill('Start: ${formatClock(shiftStart)}', scale),
                    if (shiftDur != null) _pill('Trwa: ${formatDuration(shiftDur)}', scale),
                  ],
                ),
                Row(
                  spacing: 10.0 * scale,
                  children: [
                    _pill('Przerwa: ${breakStart == null ? 'brak' : 'trwa'}', scale),
                    if (breakStart != null) _pill('Od: ${formatClock(breakStart)}', scale),
                    if (breakDur != null) _pill('Trwa: ${formatDuration(breakDur)}', scale),
                  ],
                )

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, double scale) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 15 * scale, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
