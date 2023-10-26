class KeyValueStore{
  static final KeyValueStore _singleton = KeyValueStore._internal();
  factory KeyValueStore() {
    return _singleton;
  }
  KeyValueStore._internal();
  final Map<String, dynamic> _store = <String, dynamic>{};
  void put(String key, dynamic value) {
    _store[key] = value;
  }
  dynamic get(String key) {
    return _store[key];
  }
  void remove(String key) {
    _store.remove(key);
  }
  void clear() {
    _store.clear();
  }
}