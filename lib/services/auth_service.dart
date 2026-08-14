import 'dart:convert';

import '../config/api_config.dart';
import 'http_client.dart';

class AuthUser {
  final int id;
  final String email;
  final bool isAdmin;

  AuthUser({required this.id, required this.email, required this.isAdmin});

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'],
        email: j['email'],
        isAdmin: j['is_admin'] ?? false,
      );
}

class AuthService {
  // In-memory cache of the current user, populated on login/me. This is NOT
  // persisted anywhere (no SharedPreferences, no localStorage) -- it just
  // avoids an extra network round trip for isAdmin()/currentUser() calls
  // within the same app session. It's lost on refresh, which is fine: the
  // cookie is what actually keeps you logged in, and isLoggedIn()/me() will
  // repopulate this cache on app startup.
  static AuthUser? _cachedUser;

  static String _extractErrorMessage(dynamic body, int statusCode) {
    final detail = body is Map ? body['detail'] : null;

    if (detail == null) return 'Request failed ($statusCode)';
    if (detail is String) return detail;

    if (detail is Map && detail['error'] is Map) {
      final msg = detail['error']['message'];
      if (msg is String) return msg;
    }

    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) return first['msg'];
    }

    return 'Request failed ($statusCode)';
  }

  // NOTE: no more manual token storage. The browser stores and sends the
  // httpOnly cookie automatically on every request to the backend, as long
  // as `credentials: 'include'` is set (done via http.Client + withCredentials
  // below, or by using package:http's default browser behavior with credentials).

  static Future<AuthUser> login(String email, String password) async {
    final res = await apiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }

    final data = json['data'] as Map<String, dynamic>;
    final user = AuthUser.fromJson(data);
    _cachedUser = user;
    return user;
  }

  static Future<void> signup(String email, String password) async {
    final res = await apiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  static Future<void> verifyEmail(String email, String code) async {
    final res = await apiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  static Future<void> forgotPassword(String email) async {
    final res = await apiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  static Future<void> resetPassword(
      String email, String code, String newPassword) async {
    final res = await apiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'code': code, 'new_password': newPassword}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  static Future<void> logout() async {
    await apiClient.post(Uri.parse('${ApiConfig.baseUrl}/auth/logout'));
    _cachedUser = null;
  }

  // "Am I logged in?" can no longer be answered locally (no token to check),
  // since the cookie is httpOnly and invisible to Dart/JS. Instead, ask the
  // backend by hitting /auth/me -- if it succeeds, you're logged in, and we
  // cache the returned user for isAdmin()/currentUser() to use afterward.
  static Future<bool> isLoggedIn() async {
    final res = await apiClient.get(Uri.parse('${ApiConfig.baseUrl}/auth/me'));
    if (res.statusCode != 200) {
      _cachedUser = null;
      return false;
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final data = json['data'] as Map<String, dynamic>;
    _cachedUser = AuthUser.fromJson(data);
    return true;
  }

  static AuthUser? get currentUser => _cachedUser;

  static Future<bool> isAdmin() async {
    if (_cachedUser == null) {
      final loggedIn = await isLoggedIn();
      if (!loggedIn) return false;
    }
    return _cachedUser!.isAdmin;
  }
}