enum UxShellSurfacePosition { left, right, top, bottom }

enum UxShellSurfaceRole { appBar, navigation, status, utility }

enum UxShellNavVariant { mini, normal }

enum UxShellTitleSource { none, routeTitle, custom }

enum UxShellTitleAlign { left, center }

enum UxShellAction {
  navigationStyleSwitch,
  floatingIslandSwitch,
  themeSwitch,
}

enum UxShellItemKind { nav, action, status, text }

class UxAppShellSpec {
  const UxAppShellSpec({this.surfaces = const <UxShellSurfaceSpec>[]});

  factory UxAppShellSpec.fromJson(Map<String, dynamic> json) {
    return UxAppShellSpec(
      surfaces: (json['surfaces'] as List<dynamic>?)
              ?.map(
                (dynamic value) => UxShellSurfaceSpec.fromJson(
                  (value as Map<Object?, Object?>).map(
                    (Object? key, Object? value) =>
                        MapEntry(key.toString(), value),
                  ),
                ),
              )
              .toList(growable: false) ??
          const <UxShellSurfaceSpec>[],
    );
  }

  final List<UxShellSurfaceSpec> surfaces;

  UxShellSurfaceSpec? surfaceOf({
    required UxShellSurfacePosition position,
    UxShellSurfaceRole? role,
  }) {
    for (final UxShellSurfaceSpec surface in surfaces) {
      if (surface.position != position) continue;
      if (role != null && surface.role != role) continue;
      return surface;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surfaces': surfaces
          .map((UxShellSurfaceSpec surface) => surface.toJson())
          .toList(growable: false),
    };
  }
}

class UxShellSurfaceSpec {
  const UxShellSurfaceSpec({
    required this.position,
    required this.role,
    this.visible = true,
    this.navVariant = UxShellNavVariant.normal,
    this.titleSource = UxShellTitleSource.none,
    this.titleText,
    this.titleAlign = UxShellTitleAlign.left,
    this.leadingItems = const <UxShellItemSpec>[],
    this.mainItems = const <UxShellItemSpec>[],
    this.trailingItems = const <UxShellItemSpec>[],
    this.secondaryItems = const <UxShellItemSpec>[],
  });

  factory UxShellSurfaceSpec.fromJson(Map<String, dynamic> json) {
    return UxShellSurfaceSpec(
      position: _surfacePositionFromJsonValue(json['position']),
      role: _surfaceRoleFromJsonValue(json['role']),
      visible: json['visible'] as bool? ?? true,
      navVariant: _navVariantFromJsonValue(json['navVariant']),
      titleSource: _titleSourceFromJsonValue(json['titleSource']),
      titleText: json['titleText'] as String?,
      titleAlign: _titleAlignFromJsonValue(json['titleAlign']),
      leadingItems: _itemsFromJsonValue(json['leadingItems']),
      mainItems: _itemsFromJsonValue(json['mainItems']),
      trailingItems: _itemsFromJsonValue(json['trailingItems']),
      secondaryItems: _itemsFromJsonValue(json['secondaryItems']),
    );
  }

  final UxShellSurfacePosition position;
  final UxShellSurfaceRole role;
  final bool visible;

  // Used for left/right navigation surfaces.
  final UxShellNavVariant navVariant;

  // Used mainly for app bars.
  final UxShellTitleSource titleSource;
  final String? titleText;
  final UxShellTitleAlign titleAlign;

  // Leading/main/trailing support app bar and navigation surfaces, while
  // secondaryItems covers cases like the lower status row in bottom nav.
  final List<UxShellItemSpec> leadingItems;
  final List<UxShellItemSpec> mainItems;
  final List<UxShellItemSpec> trailingItems;
  final List<UxShellItemSpec> secondaryItems;

  bool get usesBottomNavigationLayout =>
      role == UxShellSurfaceRole.navigation &&
      position == UxShellSurfacePosition.bottom;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'position': position.name,
      'role': role.name,
      'visible': visible,
      'navVariant': navVariant.name,
      'titleSource': titleSource.name,
      'titleText': titleText,
      'titleAlign': titleAlign.name,
      'leadingItems': leadingItems
          .map((UxShellItemSpec item) => item.toJson())
          .toList(growable: false),
      'mainItems': mainItems
          .map((UxShellItemSpec item) => item.toJson())
          .toList(growable: false),
      'trailingItems': trailingItems
          .map((UxShellItemSpec item) => item.toJson())
          .toList(growable: false),
      'secondaryItems': secondaryItems
          .map((UxShellItemSpec item) => item.toJson())
          .toList(growable: false),
    };
  }
}

class UxShellItemSpec {
  const UxShellItemSpec({
    required this.kind,
    this.label,
    this.iconCodePoint,
    this.routePath,
    this.shellAction,
    this.enabled = true,
    this.visible = true,
    this.valueText,
  });

  factory UxShellItemSpec.fromJson(Map<String, dynamic> json) {
    return UxShellItemSpec(
      kind: _itemKindFromJsonValue(json['kind']),
      label: json['label'] as String?,
      iconCodePoint: json['iconCodePoint'] as int?,
      routePath: json['routePath'] as String?,
      shellAction: _shellActionFromJsonValue(json['shellAction']),
      enabled: json['enabled'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      valueText: json['valueText'] as String?,
    );
  }

  final UxShellItemKind kind;
  final String? label;
  final int? iconCodePoint;
  final String? routePath;
  final UxShellAction? shellAction;
  final bool enabled;
  final bool visible;
  final String? valueText;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kind': kind.name,
      'label': label,
      'iconCodePoint': iconCodePoint,
      'routePath': routePath,
      'shellAction': shellAction?.name,
      'enabled': enabled,
      'visible': visible,
      'valueText': valueText,
    };
  }
}

List<UxShellItemSpec> _itemsFromJsonValue(Object? raw) {
  return (raw as List<dynamic>?)
          ?.map(
            (dynamic value) => UxShellItemSpec.fromJson(
              (value as Map<Object?, Object?>).map(
                (Object? key, Object? value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList(growable: false) ??
      const <UxShellItemSpec>[];
}

UxShellSurfacePosition _surfacePositionFromJsonValue(Object? raw) {
  if (raw is UxShellSurfacePosition) return raw;
  if (raw is String) {
    for (final UxShellSurfacePosition value in UxShellSurfacePosition.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellSurfacePosition.left;
}

UxShellSurfaceRole _surfaceRoleFromJsonValue(Object? raw) {
  if (raw is UxShellSurfaceRole) return raw;
  if (raw is String) {
    for (final UxShellSurfaceRole value in UxShellSurfaceRole.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellSurfaceRole.navigation;
}

UxShellNavVariant _navVariantFromJsonValue(Object? raw) {
  if (raw is UxShellNavVariant) return raw;
  if (raw is String) {
    for (final UxShellNavVariant value in UxShellNavVariant.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellNavVariant.normal;
}

UxShellTitleSource _titleSourceFromJsonValue(Object? raw) {
  if (raw is UxShellTitleSource) return raw;
  if (raw is String) {
    for (final UxShellTitleSource value in UxShellTitleSource.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellTitleSource.none;
}

UxShellTitleAlign _titleAlignFromJsonValue(Object? raw) {
  if (raw is UxShellTitleAlign) return raw;
  if (raw is String) {
    for (final UxShellTitleAlign value in UxShellTitleAlign.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellTitleAlign.left;
}

UxShellAction? _shellActionFromJsonValue(Object? raw) {
  if (raw is UxShellAction) return raw;
  if (raw is String) {
    for (final UxShellAction value in UxShellAction.values) {
      if (value.name == raw) return value;
    }
  }
  return null;
}

UxShellItemKind _itemKindFromJsonValue(Object? raw) {
  if (raw is UxShellItemKind) return raw;
  if (raw is String) {
    for (final UxShellItemKind value in UxShellItemKind.values) {
      if (value.name == raw) return value;
    }
  }
  return UxShellItemKind.text;
}
