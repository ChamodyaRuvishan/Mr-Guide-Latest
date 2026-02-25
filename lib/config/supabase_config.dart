import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://scdgkcbyqxslcebulxaj.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_lhLkluMuD0VCpd3-Br3H_w_G6P4DlBZ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
