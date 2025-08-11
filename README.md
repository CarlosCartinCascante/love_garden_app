# Love Garden

A beautiful Flutter app that combines scheduled love messages with an emotional well‑being tracker that grows a virtual plant from your daily moods.

## Features

- Time‑based love messages (Morning, Afternoon, Evening, Late Night)
- Four daily local notifications with timezone support
- Emotional garden with 6 growth levels and dynamic emoji
- Daily mood tracking and weekly insights
- Share your progress on WhatsApp
- Light/Dark theme
- Settings screen to configure notifications and preferences

## Settings

Users can configure:
- Enable/disable notifications
- Per‑period notification times (Morning, Afternoon, Evening, Late Night)
- Theme (Light/Dark)

All settings are persisted locally via SharedPreferences.

## Architecture

The app follows SOLID principles with a lightweight clean architecture:
- Domain entities: immutable models (e.g., PlantGrowth, UserPreferences)
- Repositories: data access via abstractions, implemented with SharedPreferences or in‑memory
- Providers: AppStateProvider, ThemeProvider (UI state coordination)
- Services: NotificationService, ShareService, ServiceLocator

Benefits:
- SRP: Each class has a single responsibility
- OCP: New features/periods can be added with minimal changes
- LSP: Interfaces/abstractions are respected by implementations
- ISP: UI consumes intent‑based provider methods
- DIP: High‑level modules depend on abstractions (repositories)

## Build and Run

- Linux desktop: `flutter run -d linux`
- Android APK (release): `flutter build apk --release`

The output APK will be under `build/app/outputs/flutter-apk/app-release.apk`.

## Notifications

- Uses flutter_local_notifications + timezone + flutter_timezone
- Requests permissions on Android 13+ and iOS
- Reschedules daily messages on toggle or time changes

Default times (HH:mm):
- Morning: 08:30
- Afternoon: 13:00
- Evening: 20:30
- Late Night: 23:30

## Contributing

- Keep documentation in English
- Follow flutter_lints and SOLID principles
- Prefer repository/provider patterns and small, testable units

## License

This project is for personal use/demo. Replace with your own license if needed.
