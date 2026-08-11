import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
}

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
  static const _tokenKey = 'auth_token';
  static const _isAdminKey = 'is_admin';

  /// Pulls a readable message out of a FastAPI error body, whether
  /// `detail` is a plain string (e.g. HTTPException(detail="...")) or
  /// a nested object/list (e.g. Pydantic validation errors).
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

  /// Calls POST /auth/login. Throws an Exception with a readable message on failure.
  static Future<AuthUser> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }

    final token = json['access_token'] as String;
    final user = AuthUser.fromJson(json['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isAdminKey, user.isAdmin);

    return user;
  }

  /// Calls POST /auth/signup. Throws an Exception with a readable message on failure.
  static Future<void> signup(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  /// Calls POST /auth/verify-email. Throws an Exception with a readable message on failure.
  static Future<void> verifyEmail(String email, String code) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  /// Calls POST /auth/forgot-password.
  static Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final json = jsonDecode(utf8.decode(res.bodyBytes));

    if (res.statusCode != 200) {
      throw Exception(_extractErrorMessage(json, res.statusCode));
    }
  }

  /// Calls POST /auth/reset-password.
  static Future<void> resetPassword(
      String email, String code, String newPassword) async {
    final res = await http.post(
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_isAdminKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Convenience header map to attach to authenticated requests, e.g.:
  /// http.put(uri, headers: await AuthService.authHeaders(), ...)
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
