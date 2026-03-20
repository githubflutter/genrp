import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';

class UxRegister {
  UxRegister._();

  static const int _tierBase = 1000;
  static const int _paperScale = _tierBase * _tierBase;

  static const Map<int, String> papers = <int, String>{
    0: 'paperzero',
    1: 'paperone',
    2: 'papertwo',
    3: 'paperthree',
    4: 'paperfour',
  };

  static const Map<int, String> templates = <int, String>{
    1: 'tcrud',
    2: 'tsheet',
    3: 'treport',
    4: 'tdboard',
    5: 'twizard',
    6: 'tform',
  };

  static const Map<int, String> views = <int, String>{
    1: 'list',
    2: 'grid',
    3: 'datatable',
    4: 'toolbar',
    5: 'from',
    6: 'plist',
    7: 'card',
    8: 'item',
    9: 'empty',
    10: 'choose',
    11: 'alert',
    12: 'collection',
    13: 'tab',
  };

  static String paperId(int pid) => '$pid';

  static String templateId({required int pid, required int tid}) => '$pid.$tid';

  static String viewId({
    required int pid,
    required int tid,
    required int vid,
  }) => '$pid.$tid.$vid';

  // Packed structural code rule:
  // pid, tid, and vid each use 3 digits.
  // paper    -> pid * 1,000,000
  // template -> pid * 1,000,000 + tid * 1,000
  // view     -> pid * 1,000,000 + tid * 1,000 + vid
  static int paperCode(int pid) {
    _validateTier('pid', pid);
    return pid * _paperScale;
  }

  static int templateCode({required int pid, required int tid}) {
    _validateTier('pid', pid);
    _validateTier('tid', tid);
    return pid * _paperScale + tid * _tierBase;
  }

  static int viewCode({required int pid, required int tid, required int vid}) {
    _validateTier('pid', pid);
    _validateTier('tid', tid);
    _validateTier('vid', vid);
    return pid * _paperScale + tid * _tierBase + vid;
  }

  static ({int pid, int tid, int vid}) decodeCode(int code) {
    if (code < 0) {
      throw RangeError.value(code, 'code', 'UX code must be non-negative');
    }
    final pid = code ~/ _paperScale;
    final remainder = code % _paperScale;
    final tid = remainder ~/ _tierBase;
    final vid = remainder % _tierBase;
    return (pid: pid, tid: tid, vid: vid);
  }

  static void _validateTier(String name, int value) {
    if (value < 0 || value >= _tierBase) {
      throw RangeError.value(
        value,
        name,
        'UX tier values must be between 0 and 999',
      );
    }
  }
}

mixin Ux {
  int get i;
  String get n;
  int get s;

  // Shared experimental metadata bag for UX nodes.
  Map<String, dynamic> get m;
}

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
  const UxPaperHost({
    required this.i,
    required this.autopilot,
    required this.child,
    this.initialState = const <String, dynamic>{},
    super.key,
  });

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
    _scope = widget.autopilot.mountPaper(
      paperI: widget.i,
      initialState: widget.initialState,
      notify: false,
    );
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
    final needsRemount =
        oldWidget.autopilot != widget.autopilot ||
        oldWidget.i != widget.i ||
        nextRouteScope != _routeScope;
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
  const UxTemplateHost({
    required this.i,
    required this.autopilot,
    required this.builder,
    this.initialState = const <String, dynamic>{},
    super.key,
  });

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
    _scope = widget.autopilot.mountCurrentTemplate(
      templateI: widget.i,
      initialState: widget.initialState,
      notify: false,
    );
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
    final needsRemount =
        oldWidget.autopilot != widget.autopilot ||
        oldWidget.i != widget.i ||
        nextRouteScope != _routeScope ||
        nextPaperI != _paperI;
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

mixin Uwidget implements Ux {
  // vid -> 1:list, 2:grid, 3:datatable, 4:toolbar,
  // 5:from, 6:plist, 7:card, 8:item, 9:empty,
  // 10:choose, 11:alert, 12:collection, 13:tab
  // n -> same as the mapped view name above
  // Uwidget means Ultra Widget.
  // It is a reusable primitive layer and does not get a shared runtime host by
  // default.
  int get vid;

  @override
  int get s;

  @override
  int get i;

  @override
  String get n;

  @override
  Map<String, dynamic> get m => const <String, dynamic>{};
}
