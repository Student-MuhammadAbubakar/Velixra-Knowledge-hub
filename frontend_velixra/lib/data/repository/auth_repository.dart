import 'dart:convert';
import '../../core/storage/token_storage.dart';
import '../datasource/auth_datasource.dart';
import '../models/user_model.dart';

/// Sits between the datasource and the provider. Right now it's a thin
/// pass-through, but this is the layer where you'd add things like
/// "decode the JWT locally" or "cache the last logged-in user" later,
/// without touching the UI or the raw API-calling code.
class AuthRepository {
  final AuthDatasource datasource;
  final TokenStorage tokenStorage;

  AuthRepository(this.datasource, this.tokenStorage);

  Future<UserModel> login(String email, String password) async {
    final data = await datasource.login(email, password);
    final token = data["access_token"] as String;

    // Your backend's /auth/login only returns a token, not the user's
    // role directly — the role is encoded inside the JWT payload itself.
    // We decode it here so the router knows where to redirect.
    final role = _decodeRoleFromToken(token);

    await tokenStorage.saveToken(token, role);
    return UserModel(id: 0, name: "", email: email, role: role, isActive: true);
  }

  String _decodeRoleFromToken(String token) {
    final parts = token.split(".");
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> json = jsonDecode(decoded);
    return json["role"] as String;
  }

  Future<void> logout() => tokenStorage.clear();
}