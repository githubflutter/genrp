class UxStateSet {
  final Map<String, dynamic> _chrome = <String, dynamic>{};
  final Map<String, Map<String, dynamic>> _papers =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> _templates =
      <String, Map<String, dynamic>>{};

  T? chrome<T>(String key) =>
      _chrome.containsKey(key) ? _chrome[key] as T : null;

  void setChrome(String key, dynamic value) {
    if (value == null) {
      _chrome.remove(key);
      return;
    }
    _chrome[key] = value;
  }

  void patchChrome(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setChrome(entry.key, entry.value);
    }
  }

  T? getPaper<T>(String scope, String key) {
    final store = _papers[scope];
    if (store == null || !store.containsKey(key)) return null;
    return store[key] as T;
  }

  void setPaper(String scope, String key, dynamic value) {
    final store = _papers.putIfAbsent(scope, () => <String, dynamic>{});
    if (value == null) {
      store.remove(key);
      if (store.isEmpty) {
        _papers.remove(scope);
      }
      return;
    }
    store[key] = value;
  }

  void patchPaper(String scope, Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setPaper(scope, entry.key, entry.value);
    }
  }

  T? getTemplate<T>(String scope, String key) {
    final store = _templates[scope];
    if (store == null || !store.containsKey(key)) return null;
    return store[key] as T;
  }

  void setTemplate(String scope, String key, dynamic value) {
    final store = _templates.putIfAbsent(scope, () => <String, dynamic>{});
    if (value == null) {
      store.remove(key);
      if (store.isEmpty) {
        _templates.remove(scope);
      }
      return;
    }
    store[key] = value;
  }

  void patchTemplate(String scope, Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setTemplate(scope, entry.key, entry.value);
    }
  }

  void clearPaper(String scope) {
    _papers.remove(scope);
  }

  void clearTemplate(String scope) {
    _templates.remove(scope);
  }

  void clearChrome() {
    _chrome.clear();
  }

  void clear() {
    _chrome.clear();
    _papers.clear();
    _templates.clear();
  }

  Map<String, dynamic> snapshot() => <String, dynamic>{
    'chrome': Map<String, dynamic>.unmodifiable(_chrome),
    'papers': Map<String, Map<String, dynamic>>.unmodifiable(
      _papers.map(
        (String key, Map<String, dynamic> value) =>
            MapEntry(key, Map<String, dynamic>.unmodifiable(value)),
      ),
    ),
    'templates': Map<String, Map<String, dynamic>>.unmodifiable(
      _templates.map(
        (String key, Map<String, dynamic> value) =>
            MapEntry(key, Map<String, dynamic>.unmodifiable(value)),
      ),
    ),
  };
}
