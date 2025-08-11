import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'domain/repositories/repositories.dart';
import 'data/repositories/user_preferences_repository.dart';
import 'providers/app_state_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/service_locator.dart';
import 'services/notification_service.dart';

/// Main entry point of the Love Garden application.
///
/// This function sets up the dependency injection container,
/// initializes services, and configures the app with proper
/// state management following SOLID principles.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  final serviceLocator = ServiceLocator();
  serviceLocator.registerRepositories();

  // Initialize notification service via DI (can be mocked in tests)
  try {
    await serviceLocator.get<NotificationService>().initialize();
  } catch (e) {
    // In test or unsupported platforms, skip initialization errors
  }

  // Initialize background worker for Android to reshuffle daily messages
  if (Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher);
    // Ensure a unique daily task exists (runs around 00:05 local time)
    await Workmanager().registerPeriodicTask(
      'daily_reshuffle_unique',
      'daily_reshuffle_notifications',
      frequency: const Duration(days: 1),
      initialDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.notRequired),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        // Application state provider with repository dependencies
        ChangeNotifierProvider(create: (context) => AppStateProvider()),
        // Theme provider for UI theming
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const LoveGardenApp(),
    ),
  );
}

/// Background task dispatcher for Workmanager.
///
/// This function is the entry point for the background task
/// executed by Workmanager on Android.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Recreate service locator minimal stack
    final sl = ServiceLocator();
    if (!sl.isRegistered<NotificationService>()) {
      sl.registerRepositories();
    }
    try {
      final notificationService = sl.get<NotificationService>();
      await notificationService.initialize();

      final messages = sl.get<MessageRepository>();
      String pickFor(String p) {
        final list = messages.getMessagesForTimePeriod(p);
        if (list.isEmpty) {
          return '💌 Te envío un mensaje de amor para alegrar tu día.';
        }
        final idx = DateTime.now().millisecondsSinceEpoch % list.length;
        final item = list[idx];
        final content = item['content'];
        return content is String && content.trim().isNotEmpty
            ? content
            : '💌 Te envío un mensaje de amor para alegrar tu día.';
      }

      final userRepo = sl.get<SharedPreferencesUserRepository>();
      final prefs = await userRepo.loadUserPreferences();

      await notificationService.scheduleDailyMessages(
        morningText: pickFor('mañana'),
        afternoonText: pickFor('tarde'),
        eveningText: pickFor('noche'),
        nightText: pickFor('madrugada'),
        times: prefs.notificationTimes,
      );
    } catch (_) {}

    return Future.value(true);
  });
}

/// Main application widget following Flutter best practices.
///
/// This widget configures the MaterialApp with theme management
/// and navigation structure.
class LoveGardenApp extends StatefulWidget {
  const LoveGardenApp({super.key});

  @override
  State<LoveGardenApp> createState() => _LoveGardenAppState();
}

class _LoveGardenAppState extends State<LoveGardenApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final app = context.read<AppStateProvider>();
      app.checkPeriodAndRefresh(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Love Garden',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const FinalHomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
