import 'package:flutter_test/flutter_test.dart';
import 'package:love_garden_app/providers/app_state_provider.dart';
import 'package:love_garden_app/services/service_locator.dart';
import 'package:love_garden_app/domain/repositories/repositories.dart';
import 'package:love_garden_app/domain/entities/plant_growth.dart' as domain;
import 'package:love_garden_app/data/repositories/user_preferences_repository.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:love_garden_app/models/message.dart';
import 'package:love_garden_app/services/notification_service.dart';

class _FakeMoodRepo implements MoodRepository {
  final List<MoodEntry> _entries = [];

  @override
  Future<void> addMoodEntry(MoodEntry entry) async => _entries.add(entry);

  @override
  Future<void> clearAllMoodEntries() async => _entries.clear();

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async => List.of(_entries);

  @override
  Future<double> getAverageMoodScore() async {
    if (_entries.isEmpty) return 0;
    final sum = _entries.fold<int>(0, (s, e) => s + e.mood.value);
    return sum / _entries.length;
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesForDateRange(DateTime start, DateTime end) async =>
      _entries.where((e) => !e.date.isBefore(start) && e.date.isBefore(end)).toList();

  @override
  Future<List<MoodEntry>> getTodayMoodEntries() async {
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, now.day);
    final e = s.add(const Duration(days: 1));
    return getMoodEntriesForDateRange(s, e);
  }

  @override
  Future<Map<String, int>> getTodayMoodCounts() async {
    final today = await getTodayMoodEntries();
    final m = <String, int>{};
    for (final e in today) {
      m[e.mood.label] = (m[e.mood.label] ?? 0) + 1;
    }
    return m;
  }

  @override
  Future<List<MoodEntry>> getWeeklyMoods() async => _entries;

  @override
  Future<void> resetTodayMoods() async {
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, now.day);
    final e = s.add(const Duration(days: 1));
    _entries.removeWhere((x) => !x.date.isBefore(s) && x.date.isBefore(e));
  }
}

class _FakePlantRepo implements PlantRepository {
  int points = 0;

  int _levelFromPoints(int p) {
    if (p < 10) return 1;
    if (p < 25) return 2;
    if (p < 50) return 3;
    if (p < 100) return 4;
    if (p < 200) return 5;
    return 6;
  }

  @override
  Future<double> getProgressToNextLevel() async => 0.0;

  @override
  Future<String> getProgressDescription() async => '';

  @override
  Future<domain.PlantGrowth?> loadPlantGrowth() async => null;

  @override
  Future<domain.PlantGrowth> resetPlantGrowth() async => domain.PlantGrowth.initial();

  @override
  Future<void> savePlantGrowth(domain.PlantGrowth growth) async {}

  @override
  Future<domain.PlantGrowth> updatePlantGrowth(int moodPoints) async {
    points += moodPoints;
    final level = _levelFromPoints(points);
    return domain.PlantGrowth(
      currentLevel: level,
      plantStage: domain.PlantGrowth.getPlantStageName(level),
      totalMoodPoints: points,
      pointsForNextLevel: domain.PlantGrowth.getPointsForLevel(level + 1),
      lastUpdated: DateTime.now(),
    );
  }
}

class _DummyMessageRepo implements MessageRepository {
  @override
  Message getCurrentMessage() => Message(id: 't1', content: 'Hola', timeOfDay: 'mañana', theme: 'Amor');
  @override
  void nextMessage() {}
  @override
  List<Map<String, dynamic>> getMessagesForTimePeriod(String period) => [];
  @override
  Future<Message> getMessageByIndex() async => getCurrentMessage();
  @override
  Future<void> advanceToNextMessage() async {}
  @override
  Future<void> resetMessageIndex() async {}
}

class _NoopNotificationService implements NotificationService {
  @override
  Future<void> cancelAllNotifications() async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> requestPermissions() async {}
  @override
  Future<void> scheduleDailyMessages({
    required String morningText,
    required String afternoonText,
    required String eveningText,
    required String nightText,
    Map<String, String>? times,
  }) async {}
  @override
  Future<void> showInstantNotification(String title, String body) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Adding a mood entry updates today counts', () async {
    SharedPreferences.setMockInitialValues({});
    final sl = ServiceLocator();
    sl.reset();
    sl.register<MoodRepository>(_FakeMoodRepo());
    sl.register<PlantRepository>(_FakePlantRepo());
    sl.register<MessageRepository>(_DummyMessageRepo());
    sl.register<SharedPreferencesUserRepository>(SharedPreferencesUserRepository());
    sl.register<NotificationService>(_NoopNotificationService());

    final provider = AppStateProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    expect(provider.todayMoodCounts.values.fold(0, (s, v) => s + v), 0);
    await provider.addMoodEntry(MoodType.good);
    await Future.delayed(const Duration(milliseconds: 100));
    final total = provider.todayMoodCounts.values.fold(0, (s, v) => s + v);
    expect(total, 1);
  });
}
