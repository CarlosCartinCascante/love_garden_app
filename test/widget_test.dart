// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:love_garden_app/main.dart';
import 'package:love_garden_app/providers/theme_provider.dart';
import 'package:love_garden_app/providers/app_state_provider.dart';
import 'package:love_garden_app/services/service_locator.dart';
import 'package:love_garden_app/domain/repositories/repositories.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/models/message.dart';
import 'package:love_garden_app/data/repositories/user_preferences_repository.dart';
import 'package:love_garden_app/domain/entities/plant_growth.dart' as domain;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:love_garden_app/services/notification_service.dart';

class _NoopMoodRepo implements MoodRepository {
  @override
  Future<void> addMoodEntry(MoodEntry entry) async {}
  @override
  Future<void> clearAllMoodEntries() async {}
  @override
  Future<List<MoodEntry>> getAllMoodEntries() async => [];
  @override
  Future<double> getAverageMoodScore() async => 0;
  @override
  Future<List<MoodEntry>> getMoodEntriesForDateRange(DateTime start, DateTime end) async => [];
  @override
  Future<List<MoodEntry>> getTodayMoodEntries() async => [];
  @override
  Future<Map<String, int>> getTodayMoodCounts() async => {};
  @override
  Future<List<MoodEntry>> getWeeklyMoods() async => [];
  @override
  Future<void> resetTodayMoods() async {}
}

class _NoopPlantRepo implements PlantRepository {
  @override
  Future<double> getProgressToNextLevel() async => 0.0;
  @override
  Future<String> getProgressDescription() async => '';
  @override
  Future<domain.PlantGrowth?> loadPlantGrowth() async => null;
  @override
  Future<domain.PlantGrowth> resetPlantGrowth() async => domain.PlantGrowth.initial();
  @override
  Future<void> savePlantGrowth(domain.PlantGrowth plantGrowth) async {}
  @override
  Future<domain.PlantGrowth> updatePlantGrowth(int moodPoints) async => domain.PlantGrowth.initial();
}

class _NoopMessageRepo implements MessageRepository {
  @override
  Message getCurrentMessage() => Message(id: '0', content: 'Hola', timeOfDay: 'mañana', theme: 'Amor');
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
  testWidgets('Love Garden App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final sl = ServiceLocator();
    sl.reset();
    sl.register<MoodRepository>(_NoopMoodRepo());
    sl.register<PlantRepository>(_NoopPlantRepo());
    sl.register<MessageRepository>(_NoopMessageRepo());
    sl.register<SharedPreferencesUserRepository>(SharedPreferencesUserRepository());
    sl.register<NotificationService>(_NoopNotificationService());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const LoveGardenApp(),
      ),
    );

    // Avoid pumpAndSettle due to animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
