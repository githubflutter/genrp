/// Minimal state container for agents.
class StateSet {
  final Map<String, dynamic> _state = {};

  StateSet();

  T? get<T>(String key) => _state.containsKey(key) ? _state[key] as T : null;

  void set(String key, dynamic value) => _state[key] = value;

  void patch(Map<String, dynamic> values) => _state.addAll(values);

  Map<String, dynamic> snapshot() => Map<String, dynamic>.unmodifiable(_state);

  void clear() => _state.clear();
}
