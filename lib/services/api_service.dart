import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const String _authTokenKey = 'auth_token';

  /// Save the authentication token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// Retrieve the authentication token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Remove the authentication token from local storage
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  /// Build standard headers including Authorization if token exists
  static Future<Map<String, String>> _buildHeaders([Map<String, String>? customHeaders]) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Helper to handle the API response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      String errorMessage = 'Something went wrong';
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['error'] ?? body['message'] ?? errorMessage;
      } catch (e) {
        // Not JSON
        errorMessage = response.body.isNotEmpty ? response.body : response.reasonPhrase ?? errorMessage;
      }
      throw HttpException('Error ${response.statusCode}: $errorMessage', uri: response.request?.url);
    }
  }

  static const Duration _timeout = Duration(seconds: 15);

  /// GET request
  static Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final finalHeaders = await _buildHeaders(headers);
      final response = await http
          .get(url, headers: finalHeaders)
          .timeout(_timeout, onTimeout: () {
        throw HttpException(
          'Connection timed out. Unable to reach server at ${ApiConfig.baseUrl}',
          uri: url,
        );
      });
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  static Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final finalHeaders = await _buildHeaders(headers);
      final response = await http
          .post(
            url,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout, onTimeout: () {
        throw HttpException(
          'Connection timed out. Unable to reach server at ${ApiConfig.baseUrl}',
          uri: url,
        );
      });
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  static Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final finalHeaders = await _buildHeaders(headers);
      final response = await http
          .put(
            url,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout, onTimeout: () {
        throw HttpException(
          'Connection timed out. Unable to reach server at ${ApiConfig.baseUrl}',
          uri: url,
        );
      });
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  static Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final finalHeaders = await _buildHeaders(headers);
      final response = await http
          .delete(url, headers: finalHeaders)
          .timeout(_timeout, onTimeout: () {
        throw HttpException(
          'Connection timed out. Unable to reach server at ${ApiConfig.baseUrl}',
          uri: url,
        );
      });
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
