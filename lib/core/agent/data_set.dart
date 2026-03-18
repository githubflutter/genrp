/// Minimal key/value dataset for agents.
class DataSet {
  final Map<String, dynamic> _items = {};

  DataSet();

  T? get<T>(String key) => _items.containsKey(key) ? _items[key] as T : null;

  dynamic operator [](String key) => _items[key];

  void operator []=(String key, dynamic value) {
    if (key.startsWith('x_row.v.')) {
      final index = int.tryParse(key.substring(8));
      if (index != null && _items['x_row'] != null && _items['x_row'].v != null) {
        if (index >= 0 && index < _items['x_row'].v.length) {
          _items['x_row'].v[index] = value;
          return;
        }
      }
    }
    _items[key] = value;
  }

  void set(String key, dynamic value) => this[key] = value;

  void patch(Map<String, dynamic> values) => _items.addAll(values);

  Map<String, dynamic> snapshot() => Map<String, dynamic>.unmodifiable(_items);

  void clear() => _items.clear();
}
