import 'dart:async';
import 'package:flutter/widgets.dart';
import 'system_ui.dart';

class ImmersiveGuard extends StatefulWidget {
  const ImmersiveGuard({super.key, required this.child});
  final Widget child;

  @override
  State<ImmersiveGuard> createState() => _ImmersiveGuardState();
}

class _ImmersiveGuardState extends State<ImmersiveGuard> with WidgetsBindingObserver {
  Timer? _debounce;

  void _rehide() {
    // debounce, żeby nie walić setEnabledSystemUIMode 100x/s
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      SystemUi.hide();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // na start
    SystemUi.hide();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _rehide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _rehide(),
      onPointerMove: (_) => _rehide(),
      onPointerUp: (_) => _rehide(),
      child: widget.child,
    );
  }
}
