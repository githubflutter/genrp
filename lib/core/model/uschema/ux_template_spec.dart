class UxTemplateType {
  static const int checkboxForm = 1;
  static const int collection = 2;
  static const int detail = 3;
  static const int form = 4;

  static const Set<int> known = <int>{checkboxForm, collection, detail, form};

  static String nameOf(int id) {
    return switch (id) {
      checkboxForm => 'checkboxForm',
      collection => 'collection',
      detail => 'detail',
      form => 'form',
      _ => 'unknown',
    };
  }
}

class UxTemplateMode {
  static const int list = 1;
  static const int grid = 2;
  static const int table = 3;

  static const Set<int> known = <int>{list, grid, table};

  static String labelOf(int id) {
    return switch (id) {
      list => 'List',
      grid => 'Grid',
      table => 'Table',
      _ => 'Unknown',
    };
  }
}

class UxSelectionMode {
  static const int single = 1;
  static const int multi = 2;
}

class UxFieldBindingSpec {
  const UxFieldBindingSpec({
    required this.src,
    required this.fieldId,
    required this.path,
    this.slot,
  });

  final int src;
  final int fieldId;
  final String path;
  final int? slot;

  factory UxFieldBindingSpec.fromJson(Map<String, dynamic> json) {
    return UxFieldBindingSpec(
      src: (json['src'] as num?)?.toInt() ?? 0,
      fieldId:
          (json['fieldId'] as num?)?.toInt() ??
          (json['f'] as num?)?.toInt() ??
          0,
      path: json['path']?.toString() ?? '',
      slot: (json['slot'] as num?)?.toInt(),
    );
  }
}

class UxActionCenterSpec {
  const UxActionCenterSpec({
    required this.id,
    required this.label,
    required this.actionIds,
    this.props = const <String, dynamic>{},
  });

  final String id;
  final String label;
  final List<int> actionIds;
  final Map<String, dynamic> props;

  factory UxActionCenterSpec.fromJson(String id, Map<String, dynamic> json) {
    final actionIds = List<Object?>.from(
      json['actionIds'] as List? ?? const [],
    ).whereType<num>().map((value) => value.toInt()).toList(growable: false);
    final props = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) {
        return key == 'label' || key == 'actionIds';
      });
    return UxActionCenterSpec(
      id: id,
      label: json['label']?.toString() ?? id,
      actionIds: actionIds,
      props: props,
    );
  }
}

class UxNodeSpec {
  const UxNodeSpec({
    required this.widgetId,
    required this.a,
    required this.d,
    required this.e,
    required this.t,
    required this.hostId,
    required this.bodyId,
    required this.typeId,
    required this.type,
    required this.n,
    required this.s,
    required this.text,
    required this.label,
    required this.bind,
    required this.src,
    required this.fieldId,
    required this.actionId,
    required this.prefix,
    required this.suffix,
    required this.style,
    required this.height,
    required this.props,
    required this.children,
  });

  final int widgetId;
  final bool a;
  final int d;
  final int e;
  final int t;
  final int hostId;
  final int bodyId;
  final int? typeId;
  final String type;
  final String n;
  final String s;
  final String text;
  final String label;
  final String bind;
  final int? src;
  final int? fieldId;
  final int actionId;
  final String prefix;
  final String suffix;
  final String style;
  final double? height;
  final Map<String, dynamic> props;
  final List<UxNodeSpec> children;

  factory UxNodeSpec.fromJson(
    Map<String, dynamic> json, {
    int hostId = 0,
    int bodyId = 0,
    Map<int, String> typesById = const <int, String>{},
  }) {
    final scopedHostId = (json['hostId'] as num?)?.toInt() ?? hostId;
    final scopedBodyId = (json['bodyId'] as num?)?.toInt() ?? bodyId;
    final children = List<Object?>.from(json['children'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => UxNodeSpec.fromJson(
            Map<String, dynamic>.from(item),
            hostId: scopedHostId,
            bodyId: scopedBodyId,
            typesById: typesById,
          ),
        )
        .toList(growable: false);
    final props = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) {
        return key == 'widgetId' ||
            key == 'i' ||
            key == 'a' ||
            key == 'd' ||
            key == 'e' ||
            key == 't' ||
            key == 'hostId' ||
            key == 'bodyId' ||
            key == 'typeId' ||
            key == 'type' ||
            key == 'text' ||
            key == 'label' ||
            key == 'n' ||
            key == 's' ||
            key == 'bind' ||
            key == 'src' ||
            key == 'fieldId' ||
            key == 'f' ||
            key == 'actionId' ||
            key == 'prefix' ||
            key == 'suffix' ||
            key == 'style' ||
            key == 'height' ||
            key == 'children';
      });

    final typeId = (json['typeId'] as num?)?.toInt();
    return UxNodeSpec(
      widgetId:
          (json['widgetId'] as num?)?.toInt() ??
          (json['i'] as num?)?.toInt() ??
          0,
      a: json['a'] as bool? ?? true,
      d: (json['d'] as num?)?.toInt() ?? 0,
      e: (json['e'] as num?)?.toInt() ?? 0,
      t: (json['t'] as num?)?.toInt() ?? 0,
      hostId: scopedHostId,
      bodyId: scopedBodyId,
      typeId: typeId,
      type:
          (typeId == null ? null : typesById[typeId]) ??
          json['type']?.toString() ??
          'text',
      n: json['n']?.toString() ?? '',
      s: json['s']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      bind: json['bind']?.toString() ?? '',
      src: (json['src'] as num?)?.toInt(),
      fieldId:
          (json['fieldId'] as num?)?.toInt() ?? (json['f'] as num?)?.toInt(),
      actionId: (json['actionId'] as num?)?.toInt() ?? 0,
      prefix: json['prefix']?.toString() ?? '',
      suffix: json['suffix']?.toString() ?? '',
      style: json['style']?.toString() ?? '',
      height: (json['height'] as num?)?.toDouble(),
      props: props,
      children: children,
    );
  }
}

class UxTemplateSpec {
  const UxTemplateSpec({
    required this.bodyName,
    required this.bodyId,
    required this.hostId,
    required this.templateTypeId,
    required this.modeIds,
    required this.templateVersion,
    required this.title,
    required this.root,
    required this.checkbox,
    required this.actionCenters,
    required this.props,
  });

  final String bodyName;
  final int bodyId;
  final int hostId;
  final int templateTypeId;
  final List<int> modeIds;
  final int templateVersion;
  final String title;
  final UxNodeSpec root;
  final UxNodeSpec? checkbox;
  final Map<String, UxActionCenterSpec> actionCenters;
  final Map<String, dynamic> props;

  String get templateType => UxTemplateType.nameOf(templateTypeId);

  String get modeStateKey => 'mode.$hostId.$bodyId';

  String get selectionStateKey => 'selection.$hostId.$bodyId';

  String get selectionSetStateKey => 'selections.$hostId.$bodyId';

  int get selectionModeId =>
      (props['sm'] as num?)?.toInt() ?? UxSelectionMode.single;

  bool get isMultiSelection => selectionModeId == UxSelectionMode.multi;

  bool supportsMode(int modeId) => modeIds.contains(modeId);

  static bool isModeSupportedByType(int templateTypeId, int modeId) {
    return switch (templateTypeId) {
      UxTemplateType.collection => UxTemplateMode.known.contains(modeId),
      _ => false,
    };
  }

  factory UxTemplateSpec.fromJson(
    Map<String, dynamic> json, {
    String bodyName = '',
    Map<int, String> typesById = const <int, String>{},
  }) {
    final bodyId =
        (json['bodyId'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0;
    final hostId = (json['hostId'] as num?)?.toInt() ?? 0;
    final templateTypeId = (json['t'] as num?)?.toInt() ?? 0;
    final modeIds = List<Object?>.from(
      json['m'] as List? ?? const [],
    ).whereType<num>().map((value) => value.toInt()).toList(growable: false);
    final checkboxSpec = json['checkbox'] is Map
        ? UxNodeSpec.fromJson(
            Map<String, dynamic>.from(json['checkbox'] as Map),
            hostId: hostId,
            bodyId: bodyId,
            typesById: typesById,
          )
        : null;
    final actionCentersRaw = Map<String, dynamic>.from(
      json['actionCenters'] as Map? ?? const {},
    );
    final actionCenters = actionCentersRaw.map(
      (key, value) => MapEntry(
        key,
        UxActionCenterSpec.fromJson(
          key,
          value is Map
              ? Map<String, dynamic>.from(value)
              : const <String, dynamic>{},
        ),
      ),
    );
    final props = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) {
        return key == 'bodyId' ||
            key == 'hostId' ||
            key == 't' ||
            key == 'm' ||
            key == 'templateVersion' ||
            key == 'title' ||
            key == 'checkbox' ||
            key == 'actionCenters';
      });
    return UxTemplateSpec(
      bodyName: bodyName,
      bodyId: bodyId,
      hostId: hostId,
      templateTypeId: templateTypeId,
      modeIds: modeIds,
      templateVersion: (json['templateVersion'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? '',
      root: UxNodeSpec.fromJson(
        json,
        hostId: hostId,
        bodyId: bodyId,
        typesById: typesById,
      ),
      checkbox: checkboxSpec,
      actionCenters: actionCenters,
      props: props,
    );
  }
}
