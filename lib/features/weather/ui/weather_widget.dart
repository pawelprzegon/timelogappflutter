import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/weather_auto_refresh.dart';
import '../state/weather_controller.dart';

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // START: od razu + cyklicznie
    ref.watch(weatherAutoRefreshProvider);

    final s = ref.watch(weatherControllerProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: s.isChecking
              ? const _Loading()
              : (s.data == null || s.weatherStatus == false)
              ? _Error(message: s.error)
              : _Content(data: s.data!, lastCheck: s.lastCheck, theme: theme),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: ValueKey('loading'),
      children: [
        SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
        SizedBox(width: 12),
        Text('Pobieram pogodę…'),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      key: const ValueKey('error'),
      children: [
        Icon(Icons.cloud_off, color: theme.colorScheme.error),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message ?? 'Nie udało się pobrać pogody',
            style: TextStyle(color: theme.colorScheme.error),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.data,
    required this.lastCheck,
    required this.theme,
  });

  final WeatherData data;
  final DateTime? lastCheck;
  final ThemeData theme;

  String _fmtTime(DateTime? dt) {
    if (dt == null) return '—';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final temp = data.tempC.round();
    final feels = data.feelsLikeC.round();

    return Row(
      key: const ValueKey('content'),
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Image.network(
              openWeatherIconUrl(data.icon, scale: 2),
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$temp°C', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(_cap(data.description), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                'Odcz.: $feels°C • ${_fmtTime(lastCheck)}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
