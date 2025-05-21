import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // Singleton setup
  static final SharedPrefs _instance = SharedPrefs._internal();
  static SharedPreferences? _prefs;

  factory SharedPrefs() {
    return _instance;
  }

  SharedPrefs._internal();

  // Call this once during app start
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic Set Method
  Future<bool> setValue<T>(String key, T value) async {
    if (_prefs == null) return false;

    if (value is String) return await _prefs!.setString(key, value);
    if (value is int) return await _prefs!.setInt(key, value);
    if (value is bool) return await _prefs!.setBool(key, value);
    if (value is double) return await _prefs!.setDouble(key, value);
    if (value is List<String>) return await _prefs!.setStringList(key, value);

    throw Exception("Unsupported type");
  }

  // Generic Get Method
  T? getValue<T>(String key) {
    if (_prefs == null) return null;

    return _prefs!.get(key) as T?;
  }

  // Remove a key
  Future<bool> remove(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  // Clear all preferences
  Future<bool> clear() async {
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }
}
