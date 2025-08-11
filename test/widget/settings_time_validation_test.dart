import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:love_garden_app/screens/settings_screen.dart';
import 'package:love_garden_app/providers/app_state_provider.dart';
import 'package:love_garden_app/providers/theme_provider.dart';
import 'package:love_garden_app/domain/repositories/repositories.dart';
import 'package:love_garden_app/services/service_locator.dart';
import 'package:love_garden_app/data/repositories/user_preferences_repository.dart';
import 'package:love_garden_app/services/notification_service.dart';
import 'package:love_garden_app/models/mood.dart';
import 'package:love_garden_app/models/message.dart';
import 'package:love_garden_app/domain/entities/plant_growth.dart' as domain;

class _DummyMoodRepo implements MoodRepository {
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

class _DummyPlantRepo implements PlantRepository {
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
  Future<domain.PlantGrowth> updatePlantGrowth(int moodPoints) async => domain.PlantGrowth.initial();
}

class _DummyMessageRepo implements MessageRepository {
  @override
  void nextMessage() {}
  @override
  Message getCurrentMessage() => Message(id: '1', content: 'Hola', timeOfDay: 'mañana', theme: 'Amor');
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

  Future<Widget> _buildApp() async {
    SharedPreferences.setMockInitialValues({});
    final sl = ServiceLocator();
    sl.reset();
    sl.register<MoodRepository>(_DummyMoodRepo());
    sl.register<PlantRepository>(_DummyPlantRepo());
    sl.register<MessageRepository>(_DummyMessageRepo());
    sl.register<SharedPreferencesUserRepository>(SharedPreferencesUserRepository());
    sl.register<NotificationService>(_NoopNotificationService());

    // Increase viewport to avoid offscreen taps
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1080, 1920);
    binding.window.devicePixelRatioTestValue = 1.0;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  // Prefer widgetWithText to locate the actual button widget that contains the label
  Finder _saveButton() => find.widgetWithText(ElevatedButton, 'Guardar');
  Finder _resetButton() => find.widgetWithText(OutlinedButton, 'Restablecer');

  Future<void> _scrollToAndTap(WidgetTester tester, Finder buttonFinder) async {
    // Scroll the primary scrollable until the button is visible
    final scrollableFinder = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(buttonFinder, 200, scrollable: scrollableFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pump();
  }

  testWidgets('Guardar horarios no muestra error con 24h y 12h', (tester) async {
    final app = await _buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text('Horarios diarios'), findsOneWidget);

    await _scrollToAndTap(tester, _saveButton());

    expect(find.textContaining('Formato HH:mm'), findsNothing);
  });

  testWidgets('Restablecer y Guardar no muestran errores', (tester) async {
    final app = await _buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await _scrollToAndTap(tester, _resetButton());
    await _scrollToAndTap(tester, _saveButton());

    expect(find.textContaining('Formato HH:mm'), findsNothing);
  });
}
