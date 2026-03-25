import 'package:flutter/widgets.dart';
import 'package:genrp/core/agent/autopilot.dart';

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

class UxZone {
  UxZone._();

  static const String app = 'app';
  static const String content = 'content';
  static const String header = 'header';
  static const String collection = 'collection';
  static const String detail = 'detail';
  static const String feedback = 'feedback';
  static const String footer = 'footer';
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

  static const Map<int, String> templates = <int, String>{1: 'tworkspace', 2: 'tsheet', 3: 'treport', 4: 'tdboard', 5: 'twizard', 6: 'tform'};

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

  static String uwidgetId({required int pid, required int tid, required int uwid}) => '$pid.$tid.$uwid';

  static const int _optionalScale = 1000 * 1000 * 1000;
  static const int _routeScale = _optionalScale * 1000;
  static const int _appScale = _routeScale * 100000;

  static int appCode(int appId) => appId * _appScale;

  static int routeCode(int appId, int routeId, {String? optionalId}) {
    final oid = _parseOid(optionalId);
    return appCode(appId) + (routeId * _optionalScale) + oid;
  }

  static int templateCode({
    required int appId,
    required int routeId,
    required int templateId,
    String? optionalId,
  }) {
    return routeCode(appId, routeId, optionalId: optionalId) + (templateId * 1000);
  }

  static int uwidgetCode({
    required int appId,
    required int routeId,
    required int templateId,
    required int uwidgetId,
    String? optionalId,
  }) {
    return templateCode(
          appId: appId,
          routeId: routeId,
          templateId: templateId,
          optionalId: optionalId,
        ) +
        uwidgetId;
  }

  static int _parseOid(String? optionalId) {
    if (optionalId == null) return 0;
    final parsed = int.tryParse(optionalId);
    if (parsed != null) return parsed % 1000;
    return optionalId.hashCode % 1000;
  }

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

  static UwFieldMode fromCode(int? code, {UwFieldMode fallback = UwFieldMode.text}) {
    return byCode[code] ?? fallback;
  }

  static UwFieldMode fromJsonValue(Object? raw, {UwFieldMode fallback = UwFieldMode.text}) {
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
  const UwStateBindingSpec({required this.key, this.source = UwStateSource.chrome, this.uwidget});

  final String key;
  final UwStateSource source;
  final String? uwidget;

  factory UwStateBindingSpec.fromLegacy({required String? key, required int sourceCode, required String? uwidget}) {
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

  Map<String, dynamic> toJson() => <String, dynamic>{'key': key, 'source': source.name, 'uwidget': uwidget};
}

extension UwStateAccess on Autopilot {
  dynamic readUwState(UwStateBindingSpec binding) {
    switch (binding.source) {
      case UwStateSource.chrome:
        return stateSet.chrome<dynamic>(binding.key);
      case UwStateSource.data:
        return data[binding.key];
      case UwStateSource.template:
        final route = currentRoute;
        if (route != null && binding.uwidget != null) {
          final tid = int.tryParse(binding.uwidget!) ?? 0;
          final code = UxRegister.templateCode(
            appId: route.app.i,
            routeId: route.id,
            templateId: tid,
            optionalId: route.optionalId,
          );
          return stateSet.getTemplate<dynamic>(code, binding.key);
        }
        return null;
    }
  }

  void writeUwState(UwStateBindingSpec binding, dynamic value, {bool notify = true}) {
    switch (binding.source) {
      case UwStateSource.chrome:
        setChrome(binding.key, value, notify: notify);
      case UwStateSource.data:
        data.set(binding.key, value, notify: notify);
      case UwStateSource.template:
        if (binding.uwidget != null) {
          final tid = int.tryParse(binding.uwidget!) ?? 0;
          state.setTemplateState(tid, binding.key, value, notify: notify);
        }
    }
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
  const UxRootTemplateHost({required this.i, required this.autopilot, required this.child, this.initialState = const <String, dynamic>{}, super.key});

  final int i;
  final Autopilot autopilot;
  final Widget child;
  final Map<String, dynamic> initialState;

  @override
  State<UxRootTemplateHost> createState() => _UxRootTemplateHostState();
}

class _UxRootTemplateHostState extends State<UxRootTemplateHost> {
  String? _routeScope;

  void _mount() {
    _routeScope = widget.autopilot.currentRoute?.scopeKey;
    widget.autopilot.state.mountRootTemplate(templateI: widget.i, initialState: widget.initialState, notify: false);
  }

  @override
  void initState() {
    super.initState();
    _mount();
  }

  @override
  void didUpdateWidget(covariant UxRootTemplateHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextRouteScope = widget.autopilot.currentRoute?.scopeKey;
    final needsRemount = oldWidget.autopilot != widget.autopilot || oldWidget.i != widget.i || nextRouteScope != _routeScope;
    if (!needsRemount) return;

    final route = oldWidget.autopilot.currentRoute;
    if (route != null) {
      oldWidget.autopilot.state.clearRootTemplate(
        route.app.i,
        route.id,
        oldWidget.i,
        optionalId: route.optionalId,
        notify: false,
      );
    }
    _mount();
  }

  @override
  void dispose() {
    final route = widget.autopilot.currentRoute;
    if (route != null) {
      widget.autopilot.state.clearRootTemplate(
        route.app.i,
        route.id,
        widget.i,
        optionalId: route.optionalId,
        notify: false,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class UxTemplateHost extends StatefulWidget {
  const UxTemplateHost({required this.i, required this.autopilot, required this.builder, this.initialState = const <String, dynamic>{}, super.key});

  final int i;
  final Autopilot autopilot;
  final Widget Function(BuildContext context, String uwidget) builder;
  final Map<String, dynamic> initialState;

  @override
  State<UxTemplateHost> createState() => _UxTemplateHostState();
}

class _UxTemplateHostState extends State<UxTemplateHost> {
  @override
  void initState() {
    super.initState();
    widget.autopilot.state.mountTemplate(templateId: widget.i, initialState: widget.initialState, notify: false);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.i.toString());
}
