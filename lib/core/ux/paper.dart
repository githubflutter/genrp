import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/ux_register.dart';

mixin Paper implements Ux {
  // pid -> 0:Pzero, 1:Pone, 2:Ptwo, 3:Pthree, 4:Pfour
  // n -> paperzero, paperone, papertwo, paperthree, paperfour
  // Paper is the route-facing UX host and owns paper-scoped lifecycle.
  abstract final int pid;

  @override
  abstract final int s;

  @override
  abstract final int i;

  @override
  abstract final String n;

  @override
  Map<String, dynamic> get m => const <String, dynamic>{};
}

class UxPaperHost extends StatefulWidget {
  // Paper-scoped runtime host. Keep this with Paper so lifecycle ownership is
  // obvious at the page layer.
  const UxPaperHost({required this.i, required this.autopilot, required this.child, this.initialState = const <String, dynamic>{}, super.key});

  final int i;
  final Autopilot autopilot;
  final Widget child;
  final Map<String, dynamic> initialState;

  @override
  State<UxPaperHost> createState() => _UxPaperHostState();
}

class _UxPaperHostState extends State<UxPaperHost> {
  late String _scope;
  String? _routeScope;

  void _mount() {
    _routeScope = widget.autopilot.currentRoute?.scopeKey;
    _scope = widget.autopilot.mountPaper(paperI: widget.i, initialState: widget.initialState, notify: false);
  }

  @override
  void initState() {
    super.initState();
    _mount();
  }

  @override
  void didUpdateWidget(covariant UxPaperHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextRouteScope = widget.autopilot.currentRoute?.scopeKey;
    final needsRemount = oldWidget.autopilot != widget.autopilot || oldWidget.i != widget.i || nextRouteScope != _routeScope;
    if (!needsRemount) return;

    oldWidget.autopilot.clearPaperScope(_scope, notify: false);
    _mount();
  }

  @override
  void dispose() {
    widget.autopilot.clearPaperScope(_scope, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
