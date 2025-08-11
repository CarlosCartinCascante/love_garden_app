import 'package:flutter/material.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/plant_growth.dart' as domain;
import '../domain/entities/user_preferences.dart';
import '../models/mood.dart';
import '../models/message.dart';
import '../services/service_locator.dart';
import '../services/notification_service.dart';
import '../data/repositories/user_preferences_repository.dart';

/// Application state provider following SOLID principles.
/// - Coordinates repositories (SRP)
/// - Exposes intent-driven methods for the UI (ISP)
/// - Uses repositories via abstractions (DIP)
class AppStateProvider extends ChangeNotifier {
  // Repository dependencies (injected via service locator)
  late final MoodRepository _moodRepository;
  late final PlantRepository _plantRepository;
  late final MessageRepository _messageRepository;
  late final SharedPreferencesUserRepository _userRepository;
  late final NotificationService _notificationService;

  // Current state
  domain.PlantGrowth? _plantGrowth;
  List<MoodEntry> _moodHistory = [];
  UserPreferences _userPreferences = UserPreferences.initial();
  Map<String, int> _todayMoodCounts = {};

  // Getters for state access
  domain.PlantGrowth? get plantGrowth => _plantGrowth;
  List<MoodEntry> get moodHistory => List.unmodifiable(_moodHistory);
  List<MoodEntry> get moodEntries =>
      List.unmodifiable(_moodHistory); // Alias for compatibility
  UserPreferences get userPreferences => _userPreferences;
  Map<String, int> get todayMoodCounts => Map.from(_todayMoodCounts);

  // Convenience getters
  String get userId => _userPreferences.userId;
  bool get notificationsEnabled => _userPreferences.notificationsEnabled;
  bool get use24hFormat => _userPreferences.use24hFormat;
  bool get isFirstTime => _userPreferences.isFirstTime;
  int get currentMessageIndex => _userPreferences.currentMessageIndex;

  // Plant-related convenience methods
  String getCurrentPlantEmoji() {
    if (_plantGrowth == null) return '🌱';
    return domain.PlantGrowth.getPlantEmoji(_plantGrowth!.currentLevel);
  }

  int getPlantLevel() {
    return _plantGrowth?.currentLevel ?? 0;
  }

  MoodType? getCurrentMood() {
    if (_moodHistory.isEmpty) return null;
    return _moodHistory.last.mood;
  }

  // Additional compatibility methods
  MoodType? get currentMood => getCurrentMood();

  String getPlantEmojiForLevel(int level) {
    return domain.PlantGrowth.getPlantEmoji(level);
  }

  Future<double> getProgressToNextLevel() async {
    return await _plantRepository.getProgressToNextLevel();
  }

  Future<String> getProgressDescription() async {
    return await _plantRepository.getProgressDescription();
  }

  /// Initializes the app state provider with dependency injection
  AppStateProvider() {
    _initializeDependencies();
    _initializeApp();
  }

  /// Initializes repository dependencies using service locator
  void _initializeDependencies() {
    _moodRepository = ServiceLocator().get<MoodRepository>();
    _plantRepository = ServiceLocator().get<PlantRepository>();
    _messageRepository = ServiceLocator().get<MessageRepository>();
    _userRepository = ServiceLocator().get<SharedPreferencesUserRepository>();
    _notificationService = ServiceLocator().get<NotificationService>();
  }

  /// Recalculate plant growth strictly from today's mood entries (daily model)
  Future<void> _recalculatePlantFromToday() async {
    final todayEntries = await _moodRepository.getTodayMoodEntries();
    final todayPoints = todayEntries.fold<int>(
      0,
      (sum, m) => sum + m.mood.value,
    );
    final level = _calculateLevelFromPoints(todayPoints);
    final stage = domain.PlantGrowth.getPlantStageName(level);
    final pointsForNext = domain.PlantGrowth.getPointsForLevel(level + 1);

    final updated = (_plantGrowth ?? domain.PlantGrowth.initial()).copyWith(
      currentLevel: level,
      plantStage: stage,
      totalMoodPoints: todayPoints,
      pointsForNextLevel: pointsForNext,
      lastUpdated: DateTime.now(),
    );
    _plantGrowth = updated;
    await _plantRepository.savePlantGrowth(updated);
  }

  /// Initializes the application state by loading persisted data
  Future<void> _initializeApp() async {
    try {
      await _loadUserPreferences();
      await _loadPlantGrowth();
      await _loadMoodHistory();
      await _updateTodayMoodCounts();

      // Ensure plant reflects only today's entries at startup
      await _recalculatePlantFromToday();

      // Preload current message for smoother UI
      try {
        final msg = await _messageRepository.getMessageByIndex();
        currentMessageNotifier.value = msg;
      } catch (_) {}

      if (_userPreferences.notificationsEnabled) {
        await _initializeNotifications();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  /// Loads user preferences from repository
  Future<void> _loadUserPreferences() async {
    _userPreferences = await _userRepository.loadUserPreferences();
  }

  /// Loads plant growth state from repository
  Future<void> _loadPlantGrowth() async {
    _plantGrowth =
        await _plantRepository.loadPlantGrowth() ??
        domain.PlantGrowth.initial();
  }

  /// Loads mood history from repository
  Future<void> _loadMoodHistory() async {
    _moodHistory = await _moodRepository.getAllMoodEntries();
  }

  /// Updates today's mood counts
  Future<void> _updateTodayMoodCounts() async {
    _todayMoodCounts = await _moodRepository.getTodayMoodCounts();
  }

  /// Initializes notification service and schedules daily messages
  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();

      // Pick texts per period (Spanish period keys)
      final morning = _pickMessageFor('mañana');
      final afternoon = _pickMessageFor('tarde');
      final evening = _pickMessageFor('noche');
      final night = _pickMessageFor('madrugada');

      await _notificationService.scheduleDailyMessages(
        morningText: morning,
        afternoonText: afternoon,
        eveningText: evening,
        nightText: night,
        times: _userPreferences.notificationTimes,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  String _pickMessageFor(String period) {
    final list = _messageRepository.getMessagesForTimePeriod(period);
    if (list.isEmpty) {
      return '💌 Te envío un mensaje de amor para alegrar tu día.';
    }
    final idx = DateTime.now().millisecondsSinceEpoch % list.length;
    final item = list[idx];
    final content = item['content'];
    if (content is String && content.trim().isNotEmpty) return content;
    return '💌 Te envío un mensaje de amor para alegrar tu día.';
  }

  Future<void> rescheduleDailyMessages() async {
    try {
      final morning = _pickMessageFor('mañana');
      final afternoon = _pickMessageFor('tarde');
      final evening = _pickMessageFor('noche');
      final night = _pickMessageFor('madrugada');

      await _notificationService.scheduleDailyMessages(
        morningText: morning,
        afternoonText: afternoon,
        eveningText: evening,
        nightText: night,
        times: _userPreferences.notificationTimes,
      );
    } catch (e) {
      debugPrint('Error rescheduling notifications: $e');
    }
  }

  /// Adds a mood entry and updates plant growth accordingly (today-only model)
  ///
  /// This method follows the Single Responsibility Principle by
  /// coordinating the mood entry process without handling persistence directly.
  Future<void> addMoodEntry(MoodType mood, {String? note}) async {
    try {
      // Create mood entry
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mood: mood,
        date: DateTime.now(),
        note: note,
      );

      // Save mood entry
      await _moodRepository.addMoodEntry(entry);

      // Refresh mood state and counts
      await _loadMoodHistory();
      await _updateTodayMoodCounts();

      // Recalculate plant from today's points (do not accumulate globally)
      await _recalculatePlantFromToday();

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
      rethrow;
    }
  }

  // Current cached message for smoother UI updates
  final ValueNotifier<Message?> currentMessageNotifier = ValueNotifier<Message?>(null);

  /// Gets the current message based on time of day and current index
  Future<Message> getCurrentMessage() async {
    try {
      final msg = await _messageRepository.getMessageByIndex();
      return msg;
    } catch (e) {
      // Fallback to regular current message if async method fails
      return _messageRepository.getCurrentMessage();
    }
  }

  /// Refreshes and caches the current message
  Future<void> refreshCurrentMessage() async {
    try {
      final msg = await _messageRepository.getMessageByIndex();
      currentMessageNotifier.value = msg;
    } catch (e) {
      currentMessageNotifier.value = _messageRepository.getCurrentMessage();
    }
  }

  /// Advances to the next message with minimal UI rebuilds
  Future<void> nextMessage() async {
    await _messageRepository.advanceToNextMessage();
    await _updateMessageIndexSilently(_userPreferences.currentMessageIndex + 1);
    await refreshCurrentMessage();
    // No notifyListeners here to avoid rebuilding the whole screen
  }

  Future<void> _updateMessageIndexSilently(int newIndex) async {
    _userPreferences = _userPreferences.copyWith(
      currentMessageIndex: newIndex,
      lastUpdated: DateTime.now(),
    );
    await _userRepository.saveUserPreferences(_userPreferences);
  }

  /// Update notification enabled flag
  Future<void> toggleNotifications(bool enabled) async {
    await _updateUserPreference(notificationsEnabled: enabled);

    if (enabled) {
      await _initializeNotifications();
      await rescheduleDailyMessages();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  /// Update a specific notification time (HH:mm)
  Future<void> updateNotificationTime(String periodKey, String hhmm) async {
    final updated = Map<String, String>.from(
      _userPreferences.notificationTimes,
    );
    updated[periodKey] = hhmm;
    await _updateUserPreference(notificationTimes: updated);
    if (_userPreferences.notificationsEnabled) {
      await rescheduleDailyMessages();
    }
  }

  /// Bulk update notification times
  Future<void> updateNotificationTimes(Map<String, String> times) async {
    await _updateUserPreference(notificationTimes: times);
    if (_userPreferences.notificationsEnabled) {
      await rescheduleDailyMessages();
    }
  }

  Future<void> setUse24hFormat(bool value) async {
    await _updateUserPreference(use24hFormat: value);
  }

  Future<void> resetNotificationTimesToDefault() async {
    const defaults = {
      'mañana': '08:30',
      'tarde': '13:00',
      'noche': '20:30',
      'madrugada': '23:30',
    };
    await _updateUserPreference(notificationTimes: defaults);
    if (_userPreferences.notificationsEnabled) {
      await rescheduleDailyMessages();
    }
  }

  /// Reset all settings to default values without deleting user data
  Future<void> resetAllSettingsToDefault() async {
    const defaultTimes = {
      'mañana': '08:30',
      'tarde': '13:00',
      'noche': '20:30',
      'madrugada': '23:30',
    };

    _userPreferences = _userPreferences.copyWith(
      notificationsEnabled: true,
      use24hFormat: true,
      notificationTimes: defaultTimes,
      currentMessageIndex: 0,
      lastUpdated: DateTime.now(),
    );
    await _userRepository.saveUserPreferences(_userPreferences);
    notifyListeners();

    if (_userPreferences.notificationsEnabled) {
      await _initializeNotifications();
      await rescheduleDailyMessages();
    }
  }

  /// Internal helper to update and persist user preferences
  Future<void> _updateUserPreference({
    String? userId,
    bool? notificationsEnabled,
    bool? isFirstTime,
    int? currentMessageIndex,
    Map<String, String>? notificationTimes,
    bool? use24hFormat,
  }) async {
    _userPreferences = _userPreferences.copyWith(
      userId: userId,
      notificationsEnabled: notificationsEnabled,
      isFirstTime: isFirstTime,
      currentMessageIndex: currentMessageIndex,
      notificationTimes: notificationTimes,
      use24hFormat: use24hFormat,
      lastUpdated: DateTime.now(),
    );

    await _userRepository.saveUserPreferences(_userPreferences);
    notifyListeners();
  }

  /// Marks first time setup as complete
  Future<void> completeFirstTimeSetup() async {
    await _updateUserPreference(isFirstTime: false);
  }

  /// Resets today's mood entries (does not affect historical totals)
  Future<void> resetTodayMoods() async {
    try {
      await _moodRepository.resetTodayMoods();
      await _loadMoodHistory();
      await _updateTodayMoodCounts();
      // Reset plant to daily initial state (level 0, 0 points)
      _plantGrowth = domain.PlantGrowth.initial();
      await _plantRepository.savePlantGrowth(_plantGrowth!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting today moods: $e');
      rethrow;
    }
  }

  /// Helper method to calculate plant level based on total points
  int _calculateLevelFromPoints(int points) {
    // Daily-friendly thresholds align with domain:
    // 0:[0-2], 1:[3-5], 2:[6-9], 3:[10-14], 4:[15-20], 5:[21-27], 6:[28+]
    if (points >= 28) return 6;
    if (points >= 21) return 5;
    if (points >= 15) return 4;
    if (points >= 10) return 3;
    if (points >= 6) return 2;
    if (points >= 3) return 1;
    return 0;
  }

  /// Resets plant growth to initial state
  Future<void> resetPlantGrowth() async {
    try {
      _plantGrowth = await _plantRepository.resetPlantGrowth();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting plant growth: $e');
      rethrow;
    }
  }

  /// Gets plant growth progress description
  Future<String> getPlantProgressDescription() async {
    return await _plantRepository.getProgressDescription();
  }

  /// Gets plant growth progress percentage
  Future<double> getPlantProgress() async {
    return await _plantRepository.getProgressToNextLevel();
  }

  /// Gets weekly mood entries
  Future<List<MoodEntry>> getWeeklyMoods() async {
    return await _moodRepository.getWeeklyMoods();
  }

  /// Gets average mood score
  Future<double> getAverageMoodScore() async {
    return await _moodRepository.getAverageMoodScore();
  }

  /// Gets mood entries for a specific date range
  Future<List<MoodEntry>> getMoodEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _moodRepository.getMoodEntriesForDateRange(start, end);
  }

  /// Gets today's accumulated mood points
  Future<int> getTodayMoodPoints() async {
    final entries = await _moodRepository.getTodayMoodEntries();
    return entries.fold<int>(0, (sum, e) => sum + e.mood.value);
  }

  /// Clears all data (for reset functionality)
  Future<void> clearAllData() async {
    try {
      await _moodRepository.clearAllMoodEntries();
      await _userRepository.clearUserPreferences();
      _plantGrowth = await _plantRepository.resetPlantGrowth();
      _userPreferences = UserPreferences.initial();
      _moodHistory.clear();
      _todayMoodCounts.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }
}
