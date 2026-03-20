import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/ux/ux_register.dart';

mixin Template implements Ux {
  // tid -> 1:Tcrud, 2:Tsheet, 3:Treport, 4:Tdboard, 5:Twizard, 6:Tform
  // n -> tcrud, tsheet, treport, tdboard, twizard, tform
  // Template is the workflow layer and owns template-scoped lifecycle.
  int get tid;

  @override
  int get s;

  @override
  int get i;

  @override
  String get n;

  @override
  Map<String, dynamic> get m => const <String, dynamic>{};
}

class UxTemplateHost extends StatefulWidget {
  // Template-scoped runtime host. Keep this with Template so lifecycle
  // ownership stays next to the consuming layer.
  const UxTemplateHost({required this.i, required this.autopilot, required this.builder, this.initialState = const <String, dynamic>{}, super.key});

  final int i;
  final Autopilot autopilot;
  final Widget Function(BuildContext context, String scope) builder;
  final Map<String, dynamic> initialState;

  @override
  State<UxTemplateHost> createState() => _UxTemplateHostState();
}

class _UxTemplateHostState extends State<UxTemplateHost> {
  late String _scope;
  String? _routeScope;
  int? _paperI;

  void _mount() {
    _routeScope = widget.autopilot.currentRoute?.scopeKey;
    _paperI = widget.autopilot.currentPaperI;
    _scope = widget.autopilot.mountCurrentTemplate(templateI: widget.i, initialState: widget.initialState, notify: false);
  }

  @override
  void initState() {
    super.initState();
    _mount();
  }

  @override
  void didUpdateWidget(covariant UxTemplateHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextRouteScope = widget.autopilot.currentRoute?.scopeKey;
    final nextPaperI = widget.autopilot.currentPaperI;
    final needsRemount = oldWidget.autopilot != widget.autopilot || oldWidget.i != widget.i || nextRouteScope != _routeScope || nextPaperI != _paperI;
    if (!needsRemount) return;

    oldWidget.autopilot.clearTemplateScope(_scope, notify: false);
    _mount();
  }

  @override
  void dispose() {
    widget.autopilot.clearTemplateScope(_scope, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _scope);
}
