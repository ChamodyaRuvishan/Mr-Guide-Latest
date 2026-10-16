import 'api_service.dart';
import '../models/user.dart' as app_user;

class AuthService {
  /// Get current authenticated user with profile data
  static Future<app_user.User?> getCurrentUser() async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await ApiService.get('/auth/me');
      if (response != null) {
        return app_user.User.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        // Save the token
        await ApiService.saveToken(response['token']);
        return {
          'success': true,
          'user': app_user.User.fromJson(response['user']),
        };
      }
      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> register(Map<String, dynamic> formData) async {
    try {
      // Create request payload matching Node.js backend
      final payload = {
        'username': formData['username'],
        'email': formData['email'],
        'password': formData['password'],
        'confirmPassword': formData['password'], // Backend expects confirmPassword
        'mobileNumber': formData['mobileNumber'],
        'countryCode': formData['countryCode'],
        'country': formData['country'],
        'role': formData['role'] ?? 'user',
      };

      // Add authentic user fields if role is authentic_user
      if (formData['role'] == 'authentic_user') {
        payload['title'] = formData['title'];
        payload['education'] = formData['education'];
        payload['jobTitle'] = formData['jobTitle'];
        payload['age'] = formData['age'] != null && formData['age'] != ''
            ? int.tryParse(formData['age'].toString())
            : null;
        payload['description'] = formData['description'];
        payload['hasBusiness'] = formData['hasBusiness'] ?? false;
        
        if (formData['hasBusiness'] == true) {
          payload['businessName'] = formData['businessName'];
          payload['businessType'] = formData['businessType'];
          payload['businessDescription'] = formData['businessDescription'];
        }
      }

      final response = await ApiService.post('/auth/register', body: payload);

      if (response != null && response['token'] != null) {
        // Save the token
        await ApiService.saveToken(response['token']);
        
        // Fetch full profile data using /auth/me to get all details including profile
        final userResponse = await ApiService.get('/auth/me');
        if (userResponse != null) {
          return {
            'success': true,
            'user': app_user.User.fromJson(userResponse),
          };
        } else {
          return {
            'success': true,
            'user': app_user.User.fromJson(response['user']),
          };
        }
      }
      return {'success': false, 'error': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logout current user
  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await ApiService.removeToken();
    }
  }
}
