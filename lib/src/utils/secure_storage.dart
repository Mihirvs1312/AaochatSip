import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Private constructor
  SecureStorage._internal();

  // Singleton instance
  static final SecureStorage _instance = SecureStorage._internal();

  // Factory constructor
  factory SecureStorage() => _instance;

  // FlutterSecureStorage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save data
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> writebool({required String key, required bool value}) async {
    await _storage.write(key: key, value: value.toString());
  }

  // Read data
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("Error clearing storage: $e");
    }
  }
}
