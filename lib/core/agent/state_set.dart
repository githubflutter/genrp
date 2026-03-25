class StateSet {
  final Map<String, dynamic> _chrome = <String, dynamic>{};
  final Map<int, Map<String, dynamic>> _apps = <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _routes = <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _templates = <int, Map<String, dynamic>>{};
  final Map<int, Map<String, dynamic>> _uwidgets = <int, Map<String, dynamic>>{};

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

  T? getApp<T>(int appId, String key) => _getScoped(_apps, appId, key);

  void setApp(int appId, String key, dynamic value) => _setScoped(_apps, appId, key, value);

  void patchApp(int appId, Map<String, dynamic> values) => _patchScoped(_apps, appId, values);

  void clearApp(int appId) => _apps.remove(appId);

  // --- Route State ---

  T? getRoute<T>(int routeKey, String key) => _getScoped(_routes, routeKey, key);

  void setRoute(int routeKey, String key, dynamic value) => _setScoped(_routes, routeKey, key, value);

  void patchRoute(int routeKey, Map<String, dynamic> values) => _patchScoped(_routes, routeKey, values);

  void clearRoute(int routeKey) => _routes.remove(routeKey);

  // --- Template State ---

  T? getTemplate<T>(int templateKey, String key) => 
      _getScoped(_templates, templateKey, key);

  void setTemplate(int templateKey, String key, dynamic value) => 
      _setScoped(_templates, templateKey, key, value);

  void patchTemplate(int templateKey, Map<String, dynamic> values) => 
      _patchScoped(_templates, templateKey, values);

  void clearTemplate(int templateKey) => _templates.remove(templateKey);

  // --- UWidget State ---

  T? getUWidget<T>(int uwidgetKey, String key) => 
      _getScoped(_uwidgets, uwidgetKey, key);

  void setUWidget(int uwidgetKey, String key, dynamic value) => 
      _setScoped(_uwidgets, uwidgetKey, key, value);

  void patchUWidget(int uwidgetKey, Map<String, dynamic> values) => 
      _patchScoped(_uwidgets, uwidgetKey, values);

  void clearUWidget(int uwidgetKey) => _uwidgets.remove(uwidgetKey);

  // --- Lifecycle ---

  void clearChrome() => _chrome.clear();

  void clear() {
    _chrome.clear();
    _apps.clear();
    _routes.clear();
    _templates.clear();
    _uwidgets.clear();
  }

  Map<String, dynamic> snapshot() {
    Map<String, dynamic> deepSnapshot(Map<int, Map<String, dynamic>> store) {
      return Map<String, dynamic>.unmodifiable(
        store.map(
          (int key, Map<String, dynamic> value) =>
              MapEntry(key.toString(), Map<String, dynamic>.unmodifiable(value)),
        ),
      );
    }

    return <String, dynamic>{
      'chrome': Map<String, dynamic>.unmodifiable(_chrome),
      'apps': deepSnapshot(_apps),
      'routes': deepSnapshot(_routes),
      'templates': deepSnapshot(_templates),
      'uwidgets': deepSnapshot(_uwidgets),
    };
  }
}
