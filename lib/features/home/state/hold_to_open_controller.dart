import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timelogappflutter/features/home/widgets/admin_password_dialog.dart';

class HoldToOpenAdminButton extends StatefulWidget {
  const HoldToOpenAdminButton({
    super.key,
    this.holdDuration = const Duration(milliseconds: 1500),
  });

  final Duration holdDuration;

  @override
  State<HoldToOpenAdminButton> createState() => _HoldToOpenAdminButtonState();
}

class _HoldToOpenAdminButtonState extends State<HoldToOpenAdminButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  bool _holding = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.holdDuration)
      ..addStatusListener((s) async {
        if (s != AnimationStatus.completed) return;
        if (_busy) return;

        _busy = true;
        _holding = false;

        if (!mounted) return;

        final ok = await showAdminPasswordDialog(context);
        if (!mounted) return;

        if (ok) {
          context.push('/admin');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Błędne hasło')),
          );
        }

        _reset();
        _busy = false;
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_busy) return;
    setState(() => _holding = true);
    _ctrl.forward(from: 0);
  }

  void _cancel() {
    if (_busy) return;
    _reset();
  }

  void _reset() {
    _ctrl.stop();
    _ctrl.value = 0;
    if (mounted) setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double scale = 1.5;

    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _cancel(),
      onLongPressCancel: _cancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final p = _ctrl.value.clamp(0.0, 1.0);
          final showProgress = _holding && p > 0;

          return Stack(
            alignment: Alignment.center,
            children: [
              const AbsorbPointer(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Center(
                    child: _Logo(),
                  ),
                ),
              ),

              if (showProgress) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: p,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  child: IgnorePointer(
                    child: Text(
                      '${(p * 100).round()}%',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/timelog.png', height: 56);
  }
}