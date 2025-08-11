import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../models/mood.dart';
import '../models/message.dart';
import 'mood_tracker_screen.dart';
import 'how_it_works_screen.dart';
import '../services/share_service.dart';
import 'settings_screen.dart';
import '../domain/entities/plant_growth.dart' as domain;
import 'package:love_garden_app/utils/mood_stats.dart';

class FinalHomeScreen extends StatefulWidget {
  const FinalHomeScreen({super.key});

  @override
  State<FinalHomeScreen> createState() => _FinalHomeScreenState();
}

class _FinalHomeScreenState extends State<FinalHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _heartController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  // Returns greeting for a given configured period
  String _greetingForPeriod(String period) {
    switch (period) {
      case 'mañana':
        return '¡Buenos días! 🌅';
      case 'tarde':
        return '¡Buenas tardes! ☀️';
      case 'noche':
      case 'madrugada':
      default:
        return '¡Buenas noches! 🌙';
    }
  }

  // Formats date in Spanish
  String _getSpanishDate() {
    final now = DateTime.now();
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];

    return '$dayName, ${now.day} de $monthName de ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Love Garden',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Open Settings
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Configuración',
          ),
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: themeProvider.isDarkMode
                    ? 'Modo claro'
                    : 'Modo oscuro',
              );
            },
          ),
          // Help / How it works
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HowItWorksScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: '¿Cómo funciona?',
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - 32, // Account for padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting and date
                      _buildGreetingCard(appState),
                      const SizedBox(height: 20),

                      // Daily message
                      _buildDailyMessageCard(appState),
                      const SizedBox(height: 20),

                      // Today's mood statistics
                      _buildMoodStatsCard(appState),
                      const SizedBox(height: 20),

                      // Current mood and plant
                      _buildMoodAndPlantCard(appState),
                      const SizedBox(height: 20),

                      // Weekly emotional progress
                      _buildEmotionalProgressCard(appState),
                      const SizedBox(height: 20),

                      // Action buttons
                      _buildActionButtons(appState),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGreetingCard(AppStateProvider appState) {
    final period = appState.getCurrentPeriod();
    final greeting = _greetingForPeriod(period);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(76),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: GoogleFonts.comfortaa(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSpanishDate(),
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.white.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMessageCard(AppStateProvider appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ValueListenableBuilder<Message?>(
        valueListenable: appState.currentMessageNotifier,
        builder: (context, message, _) {
          // Fallback to async fetch once if null
          if (message == null) {
            return FutureBuilder<Message>(
              future: appState.getCurrentMessage().then((m) {
                appState.currentMessageNotifier.value = m;
                return m;
              }),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildMessageContent(snapshot.data!, appState);
              },
            );
          }
          return _buildMessageContent(message, appState);
        },
      ),
    );
  }

  Widget _buildMessageContent(Message message, AppStateProvider appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _heartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value,
                  child: Text(
                    _getThemeIcon(message.theme),
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getLocalizedThemeMessage(
                  message.theme,
                  message.timeOfDay,
                ),
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                await appState.nextMessage();
              },
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              tooltip: 'Siguiente mensaje',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          message.content,
          style: GoogleFonts.openSans(
            fontSize: 16,
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.timeOfDay,
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodAndPlantCard(AppStateProvider appState) {
    final currentMood = appState.getCurrentMood();
    final plantEmoji = appState.getCurrentPlantEmoji();
    final plantLevel = appState.getPlantLevel();
    final totalPoints = appState.plantGrowth?.totalMoodPoints ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tu jardín emocional',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Plant container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(plantEmoji, style: const TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 16),

          // Current mood information
          if (currentMood != null) ...[
            Text(
              'Estado actual: ${currentMood.emoji} ${_getMoodName(currentMood)}',
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
          ],

          Text(
            'Nivel: ${_getPlantLevelName(plantLevel)}',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Puntos totales: $totalPoints',
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          if (appState.moodEntries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Entradas registradas: ${appState.moodEntries.length}',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionalProgressCard(AppStateProvider appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen semanal',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          FutureBuilder<List<MoodEntry>>(
            future: appState.getWeeklyMoods(),
            builder: (context, weeklySnapshot) {
              if (!weeklySnapshot.hasData || weeklySnapshot.data!.isEmpty) {
                return Text(
                  'Registra tu primer estado de ánimo para ver tu progreso',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                );
              }

              final weeklyMoods = weeklySnapshot.data!;
              final reps = computeDailyRepresentativeMood(
                now: DateTime.now(),
                moods: weeklyMoods,
              );

              String abbreviateLabel(String label) {
                switch (label) {
                  case 'Increíble':
                    return 'Incr.';
                  case 'Terrible':
                    return 'Terr.';
                  case 'Genial':
                    return 'Gen.';
                  default:
                    return label;
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: reps.entries.map((entry) {
                  final dayName = entry.key; // Already abbreviated Lun..Dom
                  final mood = entry.value;
                  final emoji = mood?.emoji ?? '⭕';
                  final label = mood?.label ?? '-';
                  final short = abbreviateLabel(label);

                  return Expanded(
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(
                          dayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.openSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          short,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 9,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppStateProvider appState) {
    return Column(
      children: [
        // Navigate to mood tracker
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoodTrackerScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite),
                const SizedBox(width: 12),
                Text(
                  'Registrar estado de ánimo',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Share progress
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              final plantEmoji = appState.getCurrentPlantEmoji();
              final plantLevel = appState.getPlantLevel();
              final averageScore = await appState.getAverageMoodScore();

              final message =
                  '🌱 ¡Mi jardín emocional está creciendo! $plantEmoji\n\n'
                  'Nivel: ${_getPlantLevelName(plantLevel)}\n'
                  'Bienestar promedio: ${(averageScore * 20).toStringAsFixed(0)}%\n'
                  'Días registrados: ${appState.moodEntries.length}\n\n'
                  '¡Únete a Love Garden y cultiva tu felicidad! 💕';

              await ShareService.shareToWhatsApp(text: message);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share),
                const SizedBox(width: 12),
                Text(
                  'Compartir mi progreso',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Full reset
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showFullResetDialog(appState),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[600]!, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restart_alt),
                const SizedBox(width: 12),
                Text(
                  'Reiniciar jardín completo',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFullResetDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '⚠️ Reiniciar Jardín Completo',
            style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que quieres reiniciar completamente tu jardín?\n\nEsto eliminará TODO tu progreso y volverás a empezar desde cero con una semilla.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                await appState.clearAllData();
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🌱 Jardín completamente reiniciado. ¡Comienza de nuevo!',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Reiniciar Todo'),
            ),
          ],
        );
      },
    );
  }

  String _getMoodName(MoodType mood) {
    return mood.label; // Use the label directly from the enum
  }

  String _getPlantLevelName(int level) {
    return domain.PlantGrowth.getPlantStageName(level);
  }

  Widget _buildMoodStatsCard(AppStateProvider appState) {
    final moodCounts = appState.todayMoodCounts;
    final total = moodCounts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(25),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '📊 Estados de ánimo hoy',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no has registrado ningún estado de ánimo hoy',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Estados de ánimo hoy',
            style: GoogleFonts.comfortaa(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...moodCounts.entries.where((entry) => entry.value > 0).map((entry) {
            // Repository returns label (e.g., "Bien", "Increíble").
            final label = entry.key;
            final count = entry.value;
            final moodType = MoodType.values.firstWhere(
              (m) => m.label == label,
              orElse: () => MoodType.okay,
            );
            final emoji = moodType.emoji;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Returns a localized theme header by type and period
  String _getLocalizedThemeMessage(String? theme, String timeOfDay) {
    // Supports Spanish keys used by the message repository
    final themeLabels = {
      'Amor': 'Mensaje de amor',
      'Motivación': 'Mensaje de motivación',
      'Inspiración': 'Mensaje de inspiración',
      // English keys for forward compatibility
      'greeting': 'Saludo',
      'motivation': 'Motivación',
      'reflection': 'Reflexión',
      'check_in': 'Seguimiento',
      'wellness': 'Bienestar',
      'care': 'Cuidado personal',
      'validation': 'Validación',
      'comfort': 'Tranquilidad',
    };

    final periodLabels = {
      'mañana': 'la mañana',
      'tarde': 'la tarde',
      'noche': 'la noche',
      'madrugada': 'la madrugada',
    };

    final periodLabel = periodLabels[timeOfDay] ?? timeOfDay;

    if (theme != null && themeLabels.containsKey(theme)) {
      return '${themeLabels[theme]} de $periodLabel';
    }

    return 'Mensaje de $periodLabel';
  }

  String _getThemeIcon(String? theme) {
    switch (theme) {
      case 'Amor':
        return '💕';
      case 'Motivación':
        return '💪';
      case 'Inspiración':
        return '✨';
      default:
        return '💕';
    }
  }
}
