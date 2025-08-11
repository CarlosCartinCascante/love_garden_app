import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user_preferences.dart';

/// Concrete implementation of UserPreferences repository using SharedPreferences.
///
/// This implementation follows the Repository pattern and provides
/// persistent storage for user preferences.
class SharedPreferencesUserRepository {
  static const String _userPreferencesKey = 'user_preferences';

  /// Saves user preferences to SharedPreferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final json = preferences.toJson();
    await prefs.setString(_userPreferencesKey, jsonEncode(json));
  }

  /// Loads user preferences from SharedPreferences
  Future<UserPreferences> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userPreferencesKey);

    if (jsonString == null) {
      return UserPreferences.initial();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPreferences.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return initial preferences
      return UserPreferences.initial();
    }
  }

  /// Updates specific user preference
  Future<void> updateUserPreference<T>({
    String? userId,
    bool? notificationsEnabled,
    bool? isFirstTime,
    int? currentMessageIndex,
    Map<String, String>? notificationTimes,
    bool? use24hFormat,
  }) async {
    final currentPreferences = await loadUserPreferences();
    final updatedPreferences = currentPreferences.copyWith(
      userId: userId,
      notificationsEnabled: notificationsEnabled,
      isFirstTime: isFirstTime,
      currentMessageIndex: currentMessageIndex,
      notificationTimes: notificationTimes,
      use24hFormat: use24hFormat,
      lastUpdated: DateTime.now(),
    );
    await saveUserPreferences(updatedPreferences);
  }

  /// Clears all user preferences (for reset functionality)
  Future<void> clearUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userPreferencesKey);
  }
}
