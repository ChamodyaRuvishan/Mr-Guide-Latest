import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart' as app_user;

class AuthService {
  static SupabaseClient get _supabase => SupabaseConfig.client;

  /// Get current authenticated user with profile data
  static Future<app_user.User?> getCurrentUser() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) return null;

      // Fetch profile data from profiles table
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) return null;

      return app_user.User.fromJson({
        ...response,
        'email': authUser.email ?? response['email'],
      });
    } catch (e) {
      return null;
    }
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch profile data
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profile != null) {
          return {
            'success': true,
            'user': app_user.User.fromJson({
              ...profile,
              'email': response.user!.email ?? profile['email'],
            }),
          };
        } else {
          return {'success': false, 'error': 'Profile not found'};
        }
      } else {
        return {'success': false, 'error': 'Login failed'};
      }
    } on AuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Connection error. Please try again.'};
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> formData,
  ) async {
    try {
      // Sign up with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: formData['email'],
        password: formData['password'],
        data: {'username': formData['username']},
      );

      if (authResponse.user == null) {
        return {'success': false, 'error': 'Registration failed'};
      }

      // Create profile in profiles table
      final profileData = {
        'id': authResponse.user!.id,
        'username': formData['username'],
        'email': formData['email'],
        'mobile_number': formData['mobileNumber'],
        'country_code': formData['countryCode'],
        'country': formData['country'],
        'role': formData['role'] ?? 'user',
      };

      // Add authentic user fields if role is authentic_user
      if (formData['role'] == 'authentic_user') {
        profileData['title'] = formData['title'];
        profileData['education'] = formData['education'];
        profileData['job_title'] = formData['jobTitle'];
        profileData['age'] = formData['age'] != null && formData['age'] != ''
            ? int.tryParse(formData['age'].toString())
            : null;
        profileData['description'] = formData['description'];
        profileData['has_business'] = formData['hasBusiness'] ?? false;
        if (formData['hasBusiness'] == true) {
          profileData['business_name'] = formData['businessName'];
          profileData['business_type'] = formData['businessType'];
          profileData['business_description'] = formData['businessDescription'];
        }
      }

      await _supabase.from('profiles').insert(profileData);

      // Fetch the created profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return {
        'success': true,
        'user': app_user.User.fromJson({
          ...profile,
          'email': authResponse.user!.email,
        }),
      };
    } on AuthException catch (e) {
      return {'success': false, 'error': e.message};
    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate key')) {
        return {'success': false, 'error': 'Username or email already exists'};
      }
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'Registration error: ${e.toString()}'};
    }
  }

  /// Logout current user
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
