import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';
import '../models/mood.dart';
import '../domain/entities/plant_growth.dart' as domain;
import '../services/share_service.dart';

/// Pantalla principal para el seguimiento y registro del estado de ánimo.
/// Permite a los usuarios ver su progreso emocional y registrar nuevos estados.
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _growthController.dispose();
    super.dispose();
  }

  /// Inicializa las animaciones de crecimiento de la planta
  void _initializeAnimations() {
    _growthController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _growthAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.elasticOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return _buildBody(appState);
        },
      ),
    );
  }

  /// Construye la barra de aplicación con estilo consistente
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Mi Jardín del Amor',
        style: GoogleFonts.comfortaa(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
    );
  }

  /// Construye el cuerpo principal de la pantalla
  Widget _buildBody(AppStateProvider appState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Column(
              children: [
                _buildPlantDisplay(appState),
                const SizedBox(height: 24),
                _buildMoodStatsCard(appState),
                const SizedBox(height: 24),
                _buildMoodSelector(appState),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye la sección de visualización de la planta y progreso
  Widget _buildPlantDisplay(AppStateProvider appState) {
    final plantGrowth = appState.plantGrowth;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(30),
              Theme.of(context).colorScheme.primary.withAlpha(10),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildPlantContainer(plantGrowth),
            const SizedBox(height: 16),
            _buildPlantInfo(plantGrowth),
            const SizedBox(height: 16),
            _buildProgressBar(appState),
            const SizedBox(height: 16),
            _buildActionButtons(appState),
          ],
        ),
      ),
    );
  }

  /// Construye el contenedor animado de la planta
  Widget _buildPlantContainer(domain.PlantGrowth? plantGrowth) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _growthAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _growthAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _getPlantWidget(plantGrowth?.currentLevel ?? 0),
            ),
          );
        },
      ),
    );
  }

  /// Construye la información de la planta
  Widget _buildPlantInfo(domain.PlantGrowth? plantGrowth) {
    return Column(
      children: [
        Text(
          plantGrowth?.plantStage ?? 'Semilla',
          style: GoogleFonts.comfortaa(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Puntos de felicidad: ${plantGrowth?.totalMoodPoints ?? 0}',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Construye los botones de acción (compartir y reiniciar)
  Widget _buildActionButtons(AppStateProvider appState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareToWhatsApp(appState),
            icon: const Icon(Icons.share),
            label: const Text('Compartir Progreso'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp green
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(appState),
            icon: const Icon(Icons.today),
            label: const Text('Reiniciar Hoy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange[600],
              side: BorderSide(color: Colors.orange[600]!, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Obtiene el widget de la planta según el nivel
  Widget _getPlantWidget(int level) {
    final emoji = domain.PlantGrowth.getPlantEmoji(level);
    final size = 60.0 + (level * 8.0); // Size grows with level (supports 0..6)

    return Center(
      child: Text(emoji, style: TextStyle(fontSize: size)),
    );
  }

  /// Construye la barra de progreso hacia el siguiente nivel
  Widget _buildProgressBar(AppStateProvider appState) {
    return FutureBuilder<double>(
      future: appState.getProgressToNextLevel(),
      builder: (context, progressSnapshot) {
        return FutureBuilder<String>(
          future: appState.getProgressDescription(),
          builder: (context, descriptionSnapshot) {
            final progress = progressSnapshot.data ?? 0.0;
            final description = descriptionSnapshot.data ?? 'Cargando...';

            return Column(
              children: [
                Text(
                  'Progreso al siguiente nivel',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Construye el selector de estados de ánimo
  Widget _buildMoodSelector(AppStateProvider appState) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Cómo te sientes hoy?',
              style: GoogleFonts.comfortaa(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: MoodType.values.map((mood) {
                return _buildMoodButton(mood, appState);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un botón individual de estado de ánimo
  Widget _buildMoodButton(MoodType mood, AppStateProvider appState) {
    final moodColor = _getMoodColor(mood);

    return GestureDetector(
      onTap: () => _addMoodEntry(appState, mood),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: moodColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: moodColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              mood.label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: moodColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el color asociado a cada tipo de estado de ánimo
  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.terrible:
        return Colors.red;
      case MoodType.bad:
        return Colors.orange;
      case MoodType.okay:
        return Colors.yellow[700]!;
      case MoodType.good:
        return Colors.lightGreen;
      case MoodType.great:
        return Colors.green;
      case MoodType.amazing:
        return Colors.purple;
    }
  }

  /// Registra un nuevo estado de ánimo y muestra feedback visual
  void _addMoodEntry(AppStateProvider appState, MoodType mood) async {
    final oldLevel = appState.plantGrowth?.currentLevel ?? 0;
    final oldPoints = appState.plantGrowth?.totalMoodPoints ?? 0;

    // Register mood and wait for state to update
    await appState.addMoodEntry(mood);

    final newLevel = appState.plantGrowth?.currentLevel ?? 0;
    final newPoints = appState.plantGrowth?.totalMoodPoints ?? 0;

    // Animate and show feedback
    _playGrowthAnimation();
    _showMoodFeedback(mood, oldPoints, newPoints, oldLevel, newLevel);
  }

  /// Reproduce la animación de crecimiento de la planta
  void _playGrowthAnimation() {
    _growthController.forward().then((_) {
      _growthController.reverse();
    });
  }

  /// Muestra feedback detallado sobre el registro del estado de ánimo
  void _showMoodFeedback(
    MoodType mood,
    int oldPoints,
    int newPoints,
    int oldLevel,
    int newLevel,
  ) {
    // Limpiar snackbars existentes para evitar acumulación
    ScaffoldMessenger.of(context).clearSnackBars();

    final pointsGained = newPoints - oldPoints;
    String message = 'Estado de ánimo registrado: ${mood.label}';

    if (pointsGained > 0) {
      message += '\n+$pointsGained puntos ganados!';
    }

    if (newLevel > oldLevel) {
      message += '\n🎉 ¡Subiste al nivel $newLevel!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getMoodColor(mood),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Muestra el diálogo de confirmación para reiniciar los estados de ánimo del día
  void _showResetDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).dialogTheme.backgroundColor ??
              Theme.of(context).cardColor,
          title: Text(
            '⚠️ Reiniciar Hoy',
            style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres borrar los estados de ánimo de hoy?\n\nEsto eliminará solo las entradas del día actual.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmReset(appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reiniciar Hoy'),
            ),
          ],
        );
      },
    );
  }

  /// Confirma y ejecuta el reinicio de los estados de ánimo del día
  void _confirmReset(AppStateProvider appState) {
    appState.resetTodayMoods();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗓️ Estados de ánimo de hoy eliminados'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Comparte el progreso emocional en WhatsApp
  Future<void> _shareToWhatsApp(AppStateProvider appState) async {
    try {
      final shareText = _generateShareText(appState);
      await ShareService.shareToWhatsApp(text: shareText);
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al compartir: $e');
      }
    }
  }

  /// Genera el texto para compartir el progreso
  String _generateShareText(AppStateProvider appState) {
    final plantGrowth = appState.plantGrowth;
    if (plantGrowth == null) return 'Mi jardín emocional está creciendo 🌱';

    final currentMood = appState.currentMood;
    final moodText = currentMood?.label ?? 'tranquilo';
    final plantEmoji = appState.getPlantEmojiForLevel(plantGrowth.currentLevel);

    return '''🌱 ¡Mi jardín emocional está creciendo! $plantEmoji

💚 Estado actual: Me siento $moodText
📊 Nivel de planta: ${plantGrowth.plantStage}
⭐ Puntos de felicidad: ${plantGrowth.totalMoodPoints}

¡Cuida tu bienestar emocional día a día! 💕

#JardínEmocional #BienestarMental #LoveGarden''';
  }

  /// Muestra un mensaje de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Construye la tarjeta de estadísticas de estados de ánimo del día
  Widget _buildMoodStatsCard(AppStateProvider appState) {
    final moodCounts = appState.todayMoodCounts;
    final total = moodCounts.values.fold(0, (sum, count) => sum + count);

    return Card(
      margin: const EdgeInsets.all(0),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            if (total == 0)
              _buildEmptyStatsMessage()
            else
              _buildMoodStatsList(moodCounts),
          ],
        ),
      ),
    );
  }

  /// Construye el mensaje cuando no hay estadísticas
  Widget _buildEmptyStatsMessage() {
    return Text(
      'Aún no has registrado ningún estado de ánimo hoy',
      style: GoogleFonts.openSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Construye la lista de estadísticas de estados de ánimo
  Widget _buildMoodStatsList(Map<String, int> moodCounts) {
    return Column(
      children: moodCounts.entries
          .where((entry) => entry.value > 0)
          .map((entry) => _buildMoodStatItem(entry))
          .toList(),
    );
  }

  /// Construye un elemento individual de estadística de estado de ánimo
  Widget _buildMoodStatItem(MapEntry<String, int> entry) {
    final label = entry.key; // The key is already the mood label
    final count = entry.value;

    // Find the corresponding MoodType for this label to get the emoji
    final moodType = MoodType.values.firstWhere(
      (mood) => mood.label == label,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
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
  }
}
