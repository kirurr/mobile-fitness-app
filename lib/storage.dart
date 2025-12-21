import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Create storage instance
  late final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Store a value securely
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to write secure storage: $e');
    }
  }

  /// Read a value securely
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('Failed to read from secure storage: $e');
    }
  }

  /// Delete a value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete from secure storage: $e');
    }
  }

  /// Delete all values
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all from secure storage: $e');
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw Exception('Failed to check key existence: $e');
    }
  }
}

// Convenience methods for common use cases in a fitness app
extension SecureStorageExtensions on SecureStorageService {
  // Token storage methods
  Future<void> storeToken(String token) => write('auth_token', token);
  Future<String?> getToken() => read('auth_token');
  Future<void> deleteToken() => delete('auth_token');

  // User ID storage
  Future<void> storeUserId(String userId) => write('user_id', userId);
  Future<String?> getUserId() => read('user_id');
  Future<void> deleteUserId() => delete('user_id');

  Future<void> storeEmail(String email) => write('email', email);
  Future<String?> getEmail() => read('email');
  Future<void> deleteEmail() => delete('email');

  Future<void> storePassword(String password) => write('password', password);
  Future<String?> getPassword() => read('password');
  Future<void> deletePassword() => delete('password');
}