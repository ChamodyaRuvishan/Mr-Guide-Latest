import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        await removeToken();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> formData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await saveToken(data['token']);
        return {'success': true, 'user': User.fromJson(data['user'])};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error. Please try again.'};
    }
  }

  static Future<void> logout() async {
    await removeToken();
  }
}
