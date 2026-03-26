import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';
import 'package:genrp/core/agent/node_meta.dart';

enum UxLayer {
  app(0),
  route(1),
  template(2),
  uwidget(3),
  field(4);

  const UxLayer(this.code);

  final int code;

  static UxLayer fromCode(int? code, {UxLayer fallback = UxLayer.uwidget}) {
    for (final value in UxLayer.values) {
      if (value.code == code) return value;
    }
    return fallback;
  }
}

class UxRegister {
  UxRegister._();

  static const Map<int, String> apps = <int, String>{
    0: 'aicodex',
    1: 'aistudio',
    2: 'aibook',
    3: 'aiwork',
  };

  static const Map<int, String> appShells = <int, String>{
    1: 'appshell',
    2: 'appshellLandscape',
    3: 'appshellPortrait',
  };

  static const Map<int, String> templates = <int, String>{
    1: 'tworkspace',
    2: 'tsheet',
    3: 'treport',
    4: 'tdboard',
    5: 'twizard',
    6: 'tform',
  };

  static const Map<int, String> uwidgets = <int, String>{
    1: 'list',
    2: 'grid',
    3: 'datatable',
    4: 'toolbar',
    5: 'form',
    6: 'plist',
    7: 'card',
    8: 'item',
    9: 'empty',
    10: 'choose',
    11: 'alert',
    12: 'collection',
    13: 'tab',
    14: 'field',
  };

  static String templateId({required int pid, required int tid}) => '$pid.$tid';

  static String uwidgetId({
    required int pid,
    required int tid,
    required int uwid,
  }) => '$pid.$tid.$uwid';

  static int localNodeCode(String name) {
    _initByName();
    final tid = _templatesByName[name];
    if (tid != null) return tid * 1000;
    final uwid = _uwidgetsByName[name];
    if (uwid != null) return uwid;
    throw ArgumentError.value(name, 'name', 'Unknown UX node name');
  }

  static void _initByName() {
    if (_templatesByName.isNotEmpty) return;
    for (final entry in templates.entries) {
      _templatesByName[entry.value] = entry.key;
    }
    for (final entry in uwidgets.entries) {
      _uwidgetsByName[entry.value] = entry.key;
    }
  }

  static final Map<String, int> _templatesByName = <String, int>{};
  static final Map<String, int> _uwidgetsByName = <String, int>{};
}

enum UwFieldMode {
  text(1),
  number(2),
  combo(3),
  select(4),
  date(5),
  datetime(6),
  dates(7),
  datetimes(8),
  daterange(9),
  datetimerange(10),
  bool_(11),
  json(12),
  link(13),
  tag(14),
  filter(15),
  file(16),
  color(17),
  checklist(18);

  const UwFieldMode(this.code);

  final int code;

  static const Map<int, UwFieldMode> byCode = <int, UwFieldMode>{
    1: text,
    2: number,
    3: combo,
    4: select,
    5: date,
    6: datetime,
    7: dates,
    8: datetimes,
    9: daterange,
    10: datetimerange,
    11: bool_,
    12: json,
    13: link,
    14: tag,
    15: filter,
    16: file,
    17: color,
    18: checklist,
  };

  static const Map<String, UwFieldMode> _byName = <String, UwFieldMode>{
    'text': text,
    'number': number,
    'combo': combo,
    'select': select,
    'date': date,
    'datetime': datetime,
    'dates': dates,
    'datetimes': datetimes,
    'daterange': daterange,
    'datetimerange': datetimerange,
    'bool_': bool_,
    'bool': bool_,
    'json': json,
    'link': link,
    'tag': tag,
    'filter': filter,
    'file': file,
    'color': color,
    'checklist': checklist,
  };

  static UwFieldMode fromCode(
    int? code, {
    UwFieldMode fallback = UwFieldMode.text,
  }) {
    return byCode[code] ?? fallback;
  }

  static UwFieldMode fromJsonValue(
    Object? raw, {
    UwFieldMode fallback = UwFieldMode.text,
  }) {
    if (raw is int) return fromCode(raw, fallback: fallback);
    if (raw is String) {
      return _byName[raw.trim().toLowerCase()] ?? fallback;
    }
    return fallback;
  }
}

enum FilterOp { contains, startsWith, endsWith, except }

enum UwStateSource { chrome, data, template }

class UwStateBindingSpec {
  const UwStateBindingSpec({
    required this.key,
    this.source = UwStateSource.chrome,
    this.uwidget,
  });

  final String key;
  final UwStateSource source;
  final String? uwidget;

  factory UwStateBindingSpec.fromLegacy({
    required String? key,
    required int sourceCode,
    required String? uwidget,
  }) {
    if (key == null || key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'Binding key must not be empty');
    }
    return UwStateBindingSpec(
      key: key,
      source: switch (sourceCode) {
        1 => UwStateSource.data,
        3 => UwStateSource.template,
        _ => UwStateSource.chrome,
      },
      uwidget: uwidget,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'key': key,
    'source': source.name,
    'uwidget': uwidget,
  };
}

abstract interface class UwBindable {
  UwStateBindingSpec? get stateBinding;
}

mixin UwStateBindable implements UwBindable {
  String? get stateKey;
  int get stateSrc;
  String? get stateScope;

  @override
  UwStateBindingSpec? get stateBinding {
    final key = stateKey;
    if (key == null || key.isEmpty) return null;
    return UwStateBindingSpec.fromLegacy(
      key: key,
      sourceCode: stateSrc,
      uwidget: stateScope,
    );
  }
}

extension UwStateAccess on Autopilot {
  dynamic readUwState(UwStateBindingSpec binding, {BuildContext? context}) {
    switch (binding.source) {
      case UwStateSource.chrome:
        return stateSet.app<dynamic>(binding.key);
      case UwStateSource.data:
        return data[binding.key];
      case UwStateSource.template:
        if (context != null) {
          final runtimeid = UxRuntimeContext.maybeOf(context);
          if (runtimeid != null) {
            return stateSet.rt<dynamic>(runtimeid, binding.key);
          }
        }
        return null;
    }
  }

  void writeUwState(
    UwStateBindingSpec binding,
    dynamic value, {
    BuildContext? context,
    bool notify = true,
  }) {
    switch (binding.source) {
      case UwStateSource.chrome:
        stateSet.setapp(binding.key, value);
        if (notify) publishChange();
      case UwStateSource.data:
        data.set(binding.key, value, notify: notify);
      case UwStateSource.template:
        if (context != null) {
          final runtimeid = UxRuntimeContext.maybeOf(context);
          if (runtimeid != null) {
            state.setrt(runtimeid, binding.key, value, notify: notify);
          }
        }
    }
  }

  dynamic readBindable(UwBindable bindable, {BuildContext? context}) {
    final binding = bindable.stateBinding;
    if (binding == null) return null;
    return readUwState(binding, context: context);
  }

  void writeBindable(
    UwBindable bindable,
    dynamic value, {
    BuildContext? context,
    bool notify = true,
  }) {
    final binding = bindable.stateBinding;
    if (binding == null) return;
    writeUwState(binding, value, context: context, notify: notify);
  }
}

mixin Ux {
  int get i;
  bool get a => true;
  int get d => 0;
  int get e => 0;
  String get n;
  int get l => -1;

  Map<String, dynamic> get m => const <String, dynamic>{};

  int get style => (m['style'] as num?)?.toInt() ?? 0;

  int get t => UxRegister.localNodeCode(n);

  String get path => '$n.$i';
}

class UxRootTemplateHost extends StatefulWidget {
  const UxRootTemplateHost({
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
  State<UxRootTemplateHost> createState() => _UxRootTemplateHostState();
}

class _UxRootTemplateHostState extends State<UxRootTemplateHost> {
  late int _runtimeid;

  @override
  void initState() {
    super.initState();
    final route = widget.autopilot.currentRoute;
    final meta = NodeMeta(
      routeid: route?.id ?? 0,
      routetitle: route?.meta.title ?? 'Unknown Route',
      specid: widget.i,
      spectype: 1, // root templates are typically tworkspace or similar
    );
    _runtimeid = widget.autopilot.state.registerrt(
      meta: meta,
      initial: widget.initialState,
      notify: false,
    );
  }

  @override
  void dispose() {
    widget.autopilot.state.clearrt(_runtimeid, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class UxRuntimeContext extends InheritedWidget {
  const UxRuntimeContext({
    required this.runtimeid,
    required super.child,
    super.key,
  });

  final int runtimeid;

  static int? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UxRuntimeContext>()
        ?.runtimeid;
  }

  @override
  bool updateShouldNotify(UxRuntimeContext oldWidget) {
    return runtimeid != oldWidget.runtimeid;
  }
}

class UxTemplateHost extends StatefulWidget {
  const UxTemplateHost({
    required this.i,
    required this.autopilot,
    required this.builder,
    this.initialState = const <String, dynamic>{},
    super.key,
  });

  final int i;
  final Autopilot autopilot;
  final Widget Function(BuildContext context, int runtimeid) builder;
  final Map<String, dynamic> initialState;

  @override
  State<UxTemplateHost> createState() => _UxTemplateHostState();
}

class _UxTemplateHostState extends State<UxTemplateHost> {
  late int _runtimeid;

  @override
  void initState() {
    super.initState();
    final route = widget.autopilot.currentRoute;
    final meta = NodeMeta(
      routeid: route?.id ?? 0,
      routetitle: route?.meta.title ?? 'Unknown Route',
      specid: widget.i,
      spectype: 0,
    );
    _runtimeid = widget.autopilot.state.registerrt(
      meta: meta,
      initial: widget.initialState,
      notify: false,
    );
  }

  @override
  void dispose() {
    widget.autopilot.state.clearrt(_runtimeid, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UxRuntimeContext(
      runtimeid: _runtimeid,
      child: widget.builder(context, _runtimeid),
    );
  }
}
