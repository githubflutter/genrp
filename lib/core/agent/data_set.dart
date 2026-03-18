/// Minimal key/value dataset for agents.
class DataSet {
  final Map<String, dynamic> _items = {};

  DataSet();

  T? get<T>(String key) => _items.containsKey(key) ? _items[key] as T : null;

  dynamic operator [](String key) => _items[key];

  void operator []=(String key, dynamic value) => _items[key] = value;

  void set(String key, dynamic value) => _items[key] = value;

  void patch(Map<String, dynamic> values) => _items.addAll(values);

  Map<String, dynamic> snapshot() => Map<String, dynamic>.unmodifiable(_items);

  void clear() => _items.clear();
}
