import 'package:flutter/material.dart';

Future<int?> showContractPicker(
    BuildContext context,
    Map<String, dynamic>? user, {
      Duration timeout = const Duration(seconds: 5),
      VoidCallback? onTimeout,
      VoidCallback? onActivity,
    }) async {
  final contracts = (user?['contracts'] as List?)?.cast<Map>() ?? const [];
  if (contracts.isEmpty) return null;

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFF0B1220),
    // ważne: NIE używaj useRootNavigator:true tutaj
    builder: (ctx) => _ContractPickerSheet(
      contracts: contracts,
      timeout: timeout,
      onTimeout: onTimeout,
      onActivity: onActivity,
    ),
  );
}

class _ContractPickerSheet extends StatefulWidget {
  const _ContractPickerSheet({
    required this.contracts,
    required this.timeout,
    required this.onTimeout,
    required this.onActivity,
  });

  final List<Map> contracts;
  final Duration timeout;
  final VoidCallback? onTimeout;
  final VoidCallback? onActivity;

  @override
  State<_ContractPickerSheet> createState() => _ContractPickerSheetState();
}

class _ContractPickerSheetState extends State<_ContractPickerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.timeout);

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleTimeout();
      }
    });

    _restartPickerTimer(); // start od razu
  }

  void _restartPickerTimer() {
    if (_closed) return;
    _ctrl.stop();
    _ctrl.value = 0.0;      // 0 -> 1 w "timeout"
    _ctrl.forward();
  }

  void _bumpActivity() {
    if (_closed) return;
    widget.onActivity?.call(); // np. bumpIdle
    _restartPickerTimer();     // reset licznika pickera
  }

  void _closeWithResult(int? contractId) {
    if (_closed) return;
    _closed = true;

    // zamykamy sheet bez ryzyka pop() w trakcie locka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop<int?>(contractId);
    });
  }

  void _handleTimeout() {
    if (_closed) return;
    _closed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 1) zamknij contract_picker
      Navigator.of(context).pop<int?>(null);

      // 2) zamknij session_modal i wróć do PIN
      widget.onTimeout?.call();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.5;

    return SafeArea(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _bumpActivity(),
        onPointerMove: (_) => _bumpActivity(),
        child: SizedBox(
          height: h,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Wybierz kontrakt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _closeWithResult(null),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => LinearProgressIndicator(
                    // 1.0 -> 0.0 (pełny pasek do zera)
                    value: (1.0 - _ctrl.value).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...widget.contracts.map((c) {
                        final id = c['id'];
                        final title = (c['contractPosition'] ?? '—').toString();
                        final type = (c['contractType'] ?? '').toString();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: SizedBox(
                            height: 62,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                final cid = id is int ? id : int.tryParse(id.toString());
                                _closeWithResult(cid);
                              },
                              child: Text(
                                '$title  •  $type',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
