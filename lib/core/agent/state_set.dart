/// UX state container with chrome/body/template partitions.
class StateSet {
  StateSet();

  static const Set<String> _legacyTemplateFields = <String>{
    'mode',
    'selection',
    'selections',
  };

  final Map<String, dynamic> _chrome = <String, dynamic>{};
  final Map<String, Map<String, dynamic>> _bodies =
      <String, Map<String, dynamic>>{};
  final Map<String, Map<String, dynamic>> _templates =
      <String, Map<String, dynamic>>{};

  T? get<T>(String key) {
    final access = _resolveAccess(key);
    final store = _storeFor(access, create: false);
    if (store == null || !store.containsKey(access.field)) return null;
    return store[access.field] as T;
  }

  void set(String key, dynamic value) {
    if (key == 'currentBody') {
      _switchBody(value);
      return;
    }

    final access = _resolveAccess(key);
    final store = _storeFor(access, create: true)!;
    if (value == null) {
      store.remove(access.field);
      _trimEmpty(access);
      return;
    }
    store[access.field] = value;
  }

  void patch(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      set(entry.key, entry.value);
    }
  }

  void clearBodyScope(String scopeKey) {
    _bodies.remove(scopeKey);
  }

  void clearTemplateScope(String scopeKey) {
    _templates.remove(scopeKey);
  }

  void clearBodyScopesForBody(String bodyKey) {
    _bodies.removeWhere((scopeKey, _) => _matchesBodyScope(scopeKey, bodyKey));
  }

  void clearTemplateScopesForBody(String bodyKey) {
    _templates.removeWhere(
      (scopeKey, _) => _matchesTemplateScope(scopeKey, bodyKey),
    );
  }

  Map<String, dynamic> snapshot() => <String, dynamic>{
    'chrome': Map<String, dynamic>.unmodifiable(_chrome),
    'bodies': Map<String, Map<String, dynamic>>.unmodifiable(
      _bodies.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.unmodifiable(value)),
      ),
    ),
    'templates': Map<String, Map<String, dynamic>>.unmodifiable(
      _templates.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.unmodifiable(value)),
      ),
    ),
  };

  void clear() {
    _chrome.clear();
    _bodies.clear();
    _templates.clear();
  }

  void _switchBody(dynamic nextBody) {
    final currentBody = _chrome['currentBody'];
    if (currentBody == nextBody) return;

    if (currentBody != null) {
      final previousBodyKey = currentBody.toString();
      clearBodyScopesForBody(previousBodyKey);
      clearTemplateScopesForBody(previousBodyKey);
    }

    if (nextBody == null) {
      _chrome.remove('currentBody');
      return;
    }
    _chrome['currentBody'] = nextBody;
  }

  Map<String, dynamic>? _storeFor(_StateAccess access, {required bool create}) {
    switch (access.partition) {
      case _StatePartition.chrome:
        return _chrome;
      case _StatePartition.body:
        final scopeKey = access.scopeKey!;
        if (create) {
          return _bodies.putIfAbsent(scopeKey, () => <String, dynamic>{});
        }
        return _bodies[scopeKey];
      case _StatePartition.template:
        final scopeKey = access.scopeKey!;
        if (create) {
          return _templates.putIfAbsent(scopeKey, () => <String, dynamic>{});
        }
        return _templates[scopeKey];
    }
  }

  void _trimEmpty(_StateAccess access) {
    final scopeKey = access.scopeKey;
    if (scopeKey == null) return;
    switch (access.partition) {
      case _StatePartition.chrome:
        return;
      case _StatePartition.body:
        if (_bodies[scopeKey]?.isEmpty ?? false) {
          _bodies.remove(scopeKey);
        }
        return;
      case _StatePartition.template:
        if (_templates[scopeKey]?.isEmpty ?? false) {
          _templates.remove(scopeKey);
        }
        return;
    }
  }

  _StateAccess _resolveAccess(String key) {
    final parts = key.split('.');
    if (parts.length >= 3 && parts.first == 'body') {
      return _StateAccess(
        partition: _StatePartition.body,
        scopeKey: parts.sublist(1, parts.length - 1).join('.'),
        field: parts.last,
      );
    }
    if (parts.length >= 3 && parts.first == 'template') {
      return _StateAccess(
        partition: _StatePartition.template,
        scopeKey: parts.sublist(1, parts.length - 1).join('.'),
        field: parts.last,
      );
    }
    if (parts.length >= 3 && _legacyTemplateFields.contains(parts.first)) {
      return _StateAccess(
        partition: _StatePartition.template,
        scopeKey: parts.sublist(1).join('.'),
        field: parts.first,
      );
    }
    return _StateAccess(
      partition: _StatePartition.chrome,
      scopeKey: null,
      field: key,
    );
  }

  bool _matchesBodyScope(String scopeKey, String bodyKey) {
    if (scopeKey == bodyKey) return true;
    final parts = scopeKey.split('.');
    return parts.isNotEmpty && parts.last == bodyKey;
  }

  bool _matchesTemplateScope(String scopeKey, String bodyKey) {
    if (scopeKey == bodyKey) return true;
    final parts = scopeKey.split('.');
    if (parts.isEmpty) return false;
    if (parts.last == bodyKey) return true;
    return parts.length >= 2 && parts[1] == bodyKey;
  }
}

enum _StatePartition { chrome, body, template }

class _StateAccess {
  const _StateAccess({
    required this.partition,
    required this.scopeKey,
    required this.field,
  });

  final _StatePartition partition;
  final String? scopeKey;
  final String field;
}
