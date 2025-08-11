import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla que explica cómo funciona la aplicación Love Garden.
/// Muestra una serie de páginas con información sobre el seguimiento emocional.
class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Construye la barra de aplicación con estilo consistente
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '¿Cómo funciona?',
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

  /// Construye el cuerpo principal con el PageView
  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildPage1(),
              _buildPage2(),
              _buildPage3(),
              _buildPage4(),
              _buildPage5(),
            ],
          ),
        ),
        _buildPageIndicator(),
        _buildNavigationButtons(),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Construye la primera página - introducción
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¡Bienvenido a Love Garden!',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu jardín emocional personal donde cada estado de ánimo ayuda a crecer tu planta de la felicidad.',
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard('💝', 'Cultiva tu bienestar emocional'),
          const SizedBox(height: 12),
          _buildFeatureCard('📊', 'Sigue tu progreso diario'),
          const SizedBox(height: 12),
          _buildFeatureCard('🌸', 'Ve crecer tu jardín personal'),
        ],
      ),
    );
  }

  /// Construye la segunda página sobre mensajes
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💌', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Mensajes Personalizados',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Recibe mensajes de amor y motivación personalizados según la hora del día para mantener tu espíritu positivo.',
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            '🌅',
            'Mensajes matutinos llenos de amor y energía positiva',
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            '☀️',
            'Recordatorios de la tarde para cuidar tu bienestar',
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            '🌙',
            'Mensajes nocturnos para cerrar el día con gratitud',
          ),
        ],
      ),
    );
  }

  /// Construye la tercera página sobre el seguimiento del ánimo
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📊', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Sistema de Puntos de Felicidad',
            style: GoogleFonts.comfortaa(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Cada estado de ánimo que registres aporta puntos a tu jardín. ¡Entre más positivo, más crece tu planta!',
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildMoodScaleCard(
            '😢',
            'Terrible',
            '0 puntos',
            Colors.red.shade300,
          ),
          const SizedBox(height: 8),
          _buildMoodScaleCard('😔', 'Mal', '1 punto', Colors.orange.shade300),
          const SizedBox(height: 8),
          _buildMoodScaleCard(
            '😐',
            'Regular',
            '2 puntos',
            Colors.yellow.shade600,
          ),
          const SizedBox(height: 8),
          _buildMoodScaleCard(
            '😊',
            'Bien',
            '3 puntos',
            Colors.lightGreen.shade400,
          ),
          const SizedBox(height: 8),
          _buildMoodScaleCard(
            '😄',
            'Genial',
            '4 puntos',
            Colors.green.shade400,
          ),
          const SizedBox(height: 8),
          _buildMoodScaleCard(
            '🤩',
            'Increíble',
            '5 puntos',
            Colors.blue.shade400,
          ),
        ],
      ),
    );
  }

  /// Construye la cuarta página sobre el jardín emocional
  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Niveles de Crecimiento',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tu planta evoluciona según los puntos de felicidad que acumules en el día. ¡Cada estado de ánimo positivo la hace crecer!',
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildPlantLevelCard('🌱', 'Semilla', '0-2 puntos', 'El comienzo de tu jardín'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🌿', 'Brote', '3-5 puntos', 'Primeros signos de crecimiento'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🪴', 'Plántula', '6-9 puntos', 'Crecimiento constante'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🌻', 'Planta Joven', '10-14 puntos', 'Más fuerza y vitalidad'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🌺', 'Planta Madura', '15-20 puntos', 'Bienestar sólido'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🌸', 'Planta Floreciente', '21-27 puntos', 'Casi en su máximo esplendor'),
          const SizedBox(height: 8),
          _buildPlantLevelCard('🌷', 'Planta Radiante', '28+ puntos', 'Máximo bienestar del día'),
        ],
      ),
    );
  }

  /// Construye la quinta página sobre el progreso
  Widget _buildPage5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📈', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¡Comienza tu Viaje!',
            style: GoogleFonts.comfortaa(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Observa tu progreso semanal, comparte tu crecimiento y celebra cada pequeño paso hacia una vida más plena.',
            style: GoogleFonts.openSans(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildFeatureCard('📊', 'Progreso semanal detallado con gráficos'),
          const SizedBox(height: 12),
          _buildFeatureCard('🎯', 'Metas personales y logros desbloqueables'),
          const SizedBox(height: 12),
          _buildFeatureCard('🤝', 'Comparte tu jardín con familiares y amigos'),
        ],
      ),
    );
  }

  /// Construye una tarjeta de característica
  Widget _buildFeatureCard(String emoji, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de escala de ánimo con puntos
  Widget _buildMoodScaleCard(
    String emoji,
    String mood,
    String points,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  points,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de nivel de planta
  Widget _buildPlantLevelCard(
    String emoji,
    String level,
    String points,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  points,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el indicador de página
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Construye los botones de navegación
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Anterior
          if (_currentPage > 0)
            ElevatedButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          else
            const SizedBox(
              width: 120,
            ), // Espacio para mantener el botón siguiente alineado
          // Botón Siguiente
          if (_currentPage < 4)
            ElevatedButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text('¡Empezar!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
