import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Custom Exception for API Errors with HTTP Status Codes
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Uri? uri;

  ApiException(this.message, {this.statusCode = 500, this.uri});

  @override
  String toString() => message;
}

class ApiService {
  static const String _authTokenKey = 'auth_token';

  // Render cold start can take 30-50s on the free tier, so we use a 60-second timeout
  static const Duration _timeout = Duration(seconds: 60);

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

  /// Helper to validate HTTP status codes and handle responses
  static dynamic _handleResponse(http.Response response) {
    // 200 OK, 201 Created, 204 No Content
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return response.body;
        }
      }
      return null;
    }

    // Extract error message from backend response if available
    String errorMessage = 'An unexpected error occurred';
    try {
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        if (body is Map) {
          errorMessage = body['error'] ?? body['message'] ?? errorMessage;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }
    }

    // Map status codes according to backend conventions
    switch (response.statusCode) {
      case 400:
        throw ApiException(errorMessage, statusCode: 400, uri: response.request?.url);
      case 401:
        throw ApiException(errorMessage.isNotEmpty ? errorMessage : 'Unauthorized. Please login again.', statusCode: 401, uri: response.request?.url);
      case 403:
        throw ApiException(errorMessage.isNotEmpty ? errorMessage : 'Access forbidden.', statusCode: 403, uri: response.request?.url);
      case 404:
        throw ApiException(errorMessage.isNotEmpty ? errorMessage : 'Requested resource not found.', statusCode: 404, uri: response.request?.url);
      case 429:
        throw ApiException('Too many requests. Please wait a moment and try again.', statusCode: 429, uri: response.request?.url);
      case 500:
      case 502:
      case 503:
        throw ApiException(errorMessage.isNotEmpty ? errorMessage : 'Server error. Please try again later.', statusCode: response.statusCode, uri: response.request?.url);
      default:
        throw ApiException('Error ${response.statusCode}: $errorMessage', statusCode: response.statusCode, uri: response.request?.url);
    }
  }

  /// GET request
  static Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final finalHeaders = await _buildHeaders(headers);
      final response = await http
          .get(url, headers: finalHeaders)
          .timeout(_timeout, onTimeout: () {
        throw ApiException(
          'Connection timed out. The server might be waking up (Render cold start). Please try again.',
          statusCode: 408,
          uri: url,
        );
      });
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
        uri: url,
      );
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
        throw ApiException(
          'Connection timed out. The server might be waking up (Render cold start). Please try again.',
          statusCode: 408,
          uri: url,
        );
      });
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
        uri: url,
      );
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
        throw ApiException(
          'Connection timed out. The server might be waking up (Render cold start). Please try again.',
          statusCode: 408,
          uri: url,
        );
      });
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
        uri: url,
      );
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
        throw ApiException(
          'Connection timed out. The server might be waking up (Render cold start). Please try again.',
          statusCode: 408,
          uri: url,
        );
      });
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        'Unable to connect to server. Please check your internet connection.',
        statusCode: 0,
        uri: url,
      );
    } catch (e) {
      rethrow;
    }
  }
}
