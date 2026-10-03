import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _recentSearchKey = 'recent_searches';
  static const int _maxRecentSearches = 6;

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchKey) ?? <String>[];
    return searches.where((value) => value.trim().isNotEmpty).toList();
  }

  static Future<void> addRecentSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_recentSearchKey) ?? <String>[];
    final updated = [normalizedQuery, ...existing.where((value) => value.trim().isNotEmpty && value.trim().toLowerCase() != normalizedQuery.toLowerCase())];

    await prefs.setStringList(
      _recentSearchKey,
      updated.take(_maxRecentSearches).toList(),
    );
  }

  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchKey);
  }
}
