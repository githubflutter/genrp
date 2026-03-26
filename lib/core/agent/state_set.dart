class StateSet {
  final Map<String, dynamic> _chrome = <String, dynamic>{};
  final Map<int, Map<String, dynamic>> _app = <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _node = <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _child = <int, Map<String, dynamic>>{};

  // --- Chrome (System/Shell) ---

  T? chrome<T>(String key) => _chrome.containsKey(key) ? _chrome[key] as T : null;

  T? get<T>(String key) => chrome<T>(key);

  void setChrome(String key, dynamic value) {
    if (value == null) {
      _chrome.remove(key);
      return;
    }
    _chrome[key] = value;
  }

  void set(String key, dynamic value) => setChrome(key, value);

  void patchChrome(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setChrome(entry.key, entry.value);
    }
  }

  void patch(Map<String, dynamic> values) => patchChrome(values);

  // --- Scoped Accessors (Generic Core) ---

  T? _getScoped<T>(Map<int, Map<String, dynamic>> store, int code, String key) {
    final s = store[code];
    if (s == null || !s.containsKey(key)) return null;
    return s[key] as T;
  }

  void _setScoped(Map<int, Map<String, dynamic>> store, int code, String key, dynamic value) {
    if (value == null) {
      final s = store[code];
      if (s != null) {
        s.remove(key);
        if (s.isEmpty) store.remove(code);
      }
      return;
    }
    final s = store.putIfAbsent(code, () => <String, dynamic>{});
    s[key] = value;
  }

  void _patchScoped(Map<int, Map<String, dynamic>> store, int code, Map<String, dynamic> values) {
    for (final entry in values.entries) {
      _setScoped(store, code, entry.key, entry.value);
    }
  }

  // --- App State ---

  T? getApp<T>(int appId, String key) => _getScoped(_app, appId, key);

  void setApp(int appId, String key, dynamic value) => _setScoped(_app, appId, key, value);

  void patchApp(int appId, Map<String, dynamic> values) => _patchScoped(_app, appId, values);

  void clearApp(int appId) => _app.remove(appId);

  // --- Route State ---

  T? getRoute<T>(int routeKey, String key) => _getScoped(_node, routeKey, key);

  void setRoute(int routeKey, String key, dynamic value) => _setScoped(_node, routeKey, key, value);

  void patchRoute(int routeKey, Map<String, dynamic> values) => _patchScoped(_node, routeKey, values);

  void clearRoute(int routeKey) {
    // On route change, clear node-level state and children for safety.
    _node.clear();
    _child.clear();
  }

  // --- Template State ---

  T? getTemplate<T>(int templateKey, String key) => _getScoped(_node, templateKey, key);

  void setTemplate(int templateKey, String key, dynamic value) => _setScoped(_node, templateKey, key, value);

  void patchTemplate(int templateKey, Map<String, dynamic> values) => _patchScoped(_node, templateKey, values);

  void clearTemplate(int templateKey) {
    _node.remove(templateKey);
    _removeChildrenForZone(templateKey);
  }

  // --- UWidget State ---

  T? getUWidget<T>(int uwidgetKey, String key) => _getScoped(_child, uwidgetKey, key);

  void setUWidget(int uwidgetKey, String key, dynamic value) => _setScoped(_child, uwidgetKey, key, value);

  void patchUWidget(int uwidgetKey, Map<String, dynamic> values) => _patchScoped(_child, uwidgetKey, values);

  void clearUWidget(int uwidgetKey) => _child.remove(uwidgetKey);

  // --- Lifecycle ---

  void clearChrome() => _chrome.clear();

  void clear() {
    _chrome.clear();
    _app.clear();
    _node.clear();
    _child.clear();
  }

  Map<String, dynamic> snapshot() {
    Map<String, dynamic> deepSnapshot(Map<int, Map<String, dynamic>> store) {
      return Map<String, dynamic>.unmodifiable(store.map((int key, Map<String, dynamic> value) => MapEntry(key.toString(), Map<String, dynamic>.unmodifiable(value))));
    }

    return <String, dynamic>{'chrome': Map<String, dynamic>.unmodifiable(_chrome), 'app': deepSnapshot(_app), 'node': deepSnapshot(_node), 'child': deepSnapshot(_child)};
  }
}

extension on StateSet {
  void _removeChildrenForZone(int zone) {
    final toRemove = <int>[];
    for (final k in _child.keys) {
      if (k ~/ 10000 == zone) toRemove.add(k);
    }
    for (final k in toRemove) {
      _child.remove(k);
    }
  }
}
