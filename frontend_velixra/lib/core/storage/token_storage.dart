import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage so the JWT is stored in the device's
/// encrypted keystore (Android Keystore / iOS Keychain) — never in
/// plain SharedPreferences, since this token grants full account access.
class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = "access_token";
  static const _roleKey = "user_role";

  Future<void> saveToken(String token, String role) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}