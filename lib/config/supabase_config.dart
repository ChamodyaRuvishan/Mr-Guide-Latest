/// SupabaseConfig is deprecated.
///
/// The Mr. Guide mobile application has migrated to the unified Node.js REST API
/// backend and Neon PostgreSQL database, matching the web application.
/// Authentication, reviews, guides, places, and bookings are now managed via ApiService.
class SupabaseConfig {
  /// Inert stub kept for backward compatibility.
  static Future<void> initialize() async {
    // No-op: Supabase is no longer used.
  }
}

