import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// Main application widget following Flutter best practices.
///
/// This widget configures the MaterialApp with theme management
/// and navigation structure.
class LoveGardenApp extends StatelessWidget {
  const LoveGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Love Garden',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const FinalHomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
