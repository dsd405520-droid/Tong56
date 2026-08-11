import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Same base host as your existing SchoolDataService — keep these in sync.
  // When you deploy the backend for real, update both to the new URL.
  static const String baseUrl = 'http://127.0.0.1:8000';
}

class AuthUser {
  final int id;
  final String email;
  final String role;

  AuthUser({required this.id, required this.email, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j['id'],
        email: j['email'],
        role: j['role'],
      );
}

class AuthService {
  static const _tokenKey = 'auth_token';

  /// Calls POST /auth/login. Throws an Exception with a readable message on failure.
  static Future<AuthUser> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final message = body['detail']?['error']?['message'] ??
          body['detail'] ??
          'Login failed (${res.statusCode})';
      throw Exception(message);
    }

    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final token = json['access_token'] as String;
    final user = AuthUser.fromJson(json['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
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
