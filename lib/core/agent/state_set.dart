import 'package:genrp/core/agent/node_meta.dart';

class StateSet {
  final Map<String, dynamic> _app = <String, dynamic>{};
  final Map<int, Map<String, dynamic>> _rstate = <int, Map<String, dynamic>>{};
  final Map<int, NodeMeta> _rtindex = <int, NodeMeta>{};
  final Map<int, List<int>> _rtchildren = <int, List<int>>{};

  int _lastruntimeid = 0;

  int newid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    if (now > _lastruntimeid) {
      _lastruntimeid = now;
    } else {
      _lastruntimeid++;
    }
    return _lastruntimeid;
  }

  // --- App State ---

  T? app<T>(String key) {
    if (!_app.containsKey(key)) return null;
    return _app[key] as T;
  }

  void setapp(String key, dynamic value) {
    if (value == null) {
      _app.remove(key);
    } else {
      _app[key] = value;
    }
  }

  void patchapp(Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setapp(entry.key, entry.value);
    }
  }

  // --- Chrome (System/Shell) ---
  // Keeping chrome for backwards compatibility if needed, but routing it to app.
  T? chrome<T>(String key) => app<T>(key);
  T? get<T>(String key) => app<T>(key);
  void setChrome(String key, dynamic value) => setapp(key, value);
  void set(String key, dynamic value) => setapp(key, value);
  void patchChrome(Map<String, dynamic> values) => patchapp(values);
  void patch(Map<String, dynamic> values) => patchapp(values);

  // --- Runtime State ---

  int registerrt({
    int? parentruntimeid,
    required NodeMeta meta,
    Map<String, dynamic> initial = const <String, dynamic>{},
  }) {
    final rid = newid();
    _rtindex[rid] = meta;
    if (initial.isNotEmpty) {
      _rstate[rid] = Map<String, dynamic>.from(initial);
    }

    if (parentruntimeid != null) {
      final children = _rtchildren.putIfAbsent(parentruntimeid, () => <int>[]);
      children.add(rid);
    }
    return rid;
  }

  T? rt<T>(int runtimeid, String key) {
    final state = _rstate[runtimeid];
    if (state == null) return null;
    return state[key] as T?;
  }

  void setrt(int runtimeid, String key, dynamic value) {
    if (value == null) {
      final state = _rstate[runtimeid];
      if (state != null) {
        state.remove(key);
        if (state.isEmpty) {
          _rstate.remove(runtimeid);
        }
      }
    } else {
      final state = _rstate.putIfAbsent(runtimeid, () => <String, dynamic>{});
      state[key] = value;
    }
  }

  void patchrt(int runtimeid, Map<String, dynamic> values) {
    for (final entry in values.entries) {
      setrt(runtimeid, entry.key, entry.value);
    }
  }

  // --- Lifecycle ---

  void clearrt(int runtimeid) {
    final children = _rtchildren[runtimeid];
    if (children != null) {
      for (final childid in List<int>.from(children)) {
        clearrt(childid);
      }
      _rtchildren.remove(runtimeid);
    }
    _rstate.remove(runtimeid);
    _rtindex.remove(runtimeid);

    // Remove self from parent's children list
    for (final entry in _rtchildren.entries) {
      if (entry.value.contains(runtimeid)) {
        entry.value.remove(runtimeid);
      }
    }
  }

  void clearallrt() {
    _rstate.clear();
    _rtindex.clear();
    _rtchildren.clear();
  }

  void clearChrome() => _app.clear();

  void clearall() {
    _app.clear();
    clearallrt();
  }

  void clear() => clearall();

  Map<String, dynamic> snapshot() {
    Map<String, dynamic> deepSnapshot(Map<int, Map<String, dynamic>> store) {
      return Map<String, dynamic>.unmodifiable(store.map((int key, Map<String, dynamic> value) => MapEntry(key.toString(), Map<String, dynamic>.unmodifiable(value))));
    }

    return <String, dynamic>{
      'app': Map<String, dynamic>.unmodifiable(_app),
      'rstate': deepSnapshot(_rstate),
    };
  }
}
