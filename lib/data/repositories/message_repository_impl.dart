import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/message.dart';

/// Concrete implementation of MessageRepository using in-memory storage
/// and SharedPreferences for persistence.
///
/// NOTE: Time period determination inside this repository is static
/// (hour-based). The app should prefer AppStateProvider.getCurrentPeriod(),
/// which respects user-configured times, and then call
/// getMessagesForTimePeriod(period).
class InMemoryMessageRepository implements MessageRepository {
  static const String _currentMessageIndexKey = 'current_message_index';

  // Predefined messages organized by time periods
  final Map<String, List<Map<String, dynamic>>> _messagesByPeriod = {
    'mañana': [
      {
        "content":
            "¡Buenos días, mi amor hermosa! ☀️ Tu sonrisa ilumina mi mundo cada mañana",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "Despertar pensando en ti es la mejor parte de mi día 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Buenos días, mi amor! Que este día sea tan hermoso como tú ✨",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "Cada mañana contigo es un regalo 🎁 ¡Que tengas un día increíble!",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "¡Arriba, mi princesa! El mundo te espera para brillar ✨",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Buenos días, mi corazón. Eres lo primero que viene a mi mente 💖",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Que tengas un día tan increíble como el amor que siento por ti! 🌅",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Despertar es más fácil sabiendo que existes en mi vida 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Buenos días, mi amor! Tu felicidad es mi motivación diaria",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Cada amanecer me recuerda lo afortunado que soy de tenerte 🌞",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Levántate, mi vida! El mundo necesita tu luz hoy ✨",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Buenos días, mi tesoro. Eres mi energía para todo el día 💝",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Que este día te traiga tantas sonrisas como me das tú! 😊",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Hoy es un nuevo día para crear recuerdos hermosos juntos 🌸",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content":
            "¡Buenos días, mi cielo! Hoy será un día maravilloso porque tú estás en él",
        "type": "motivational",
        "theme": "Motivación",
      },
    ],
    'tarde': [
      {
        "content":
            "¡Buenas tardes! Espero que tu día esté siendo fantástico 🌤️",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Pensando en ti en esta tarde soleada 💭☀️",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¿Cómo va tu día, mi corazón? Espero que lleno de sonrisas 😊",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Esta tarde es más bella porque sé que compartes el mismo cielo 🌅",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Buenas tardes, mi vida! Tu felicidad es mi felicidad 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "El sol de la tarde no brilla tanto como tu sonrisa ☀️✨",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Espero que estés teniendo un día tan dulce como tú! 🍯",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Buenas tardes, mi princesa. Eres mi pensamiento constante 👑",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Que esta tarde te traiga paz y mucho amor! 🕊️💕",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Pensando en abrazarte cuando termine este día 🤗",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Buenas tardes, mi tesoro! Tu amor me acompaña siempre 💎",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "Espero que estés cuidándote mucho por ahí, mi amor 💝",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Cada tarde contigo es una nueva oportunidad de amarte más 🌺",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content": "¡Buenas tardes, mi cielo! Eres mi motivación constante ⭐",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Tu amor hace que cada tarde sea especial 💖",
        "type": "romantic",
        "theme": "Amor",
      },
    ],
    'noche': [
      {
        "content":
            "¡Buenas noches! Espero que hayas tenido un día maravilloso 🌙",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Al terminar el día, mi corazón está lleno de amor por ti 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Que tengas una noche tranquila y llena de dulces sueños! ✨",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "La luna me recuerda lo hermosa que eres 🌙💖",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Buenas noches, mi amor! Descansa y sueña bonito 😴",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "Que las estrellas cuiden tus sueños esta noche ⭐💫",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content": "¡Espero que mañana despiertes con una sonrisa! 😊",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content":
            "Buenas noches, mi princesa. Eres mi último pensamiento del día 👑",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Que descanses mucho! Mañana será otro día para amarte 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "La noche es más bella cuando sé que estás bien 🌃💖",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Buenas noches, mi cielo! Que tengas dulces sueños 🌟",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Cerrando el día agradecido por tenerte en mi vida 🙏💞",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content": "Tu amor hace que cada noche sea especial 🌙💞",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Descansa bien! Mañana será un nuevo día lleno de oportunidades ✨",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content": "Buenas noches, mi tesoro. Que tengas la noche más linda 💎",
        "type": "romantic",
        "theme": "Amor",
      },
    ],
    'madrugada': [
      {
        "content": "Es muy tarde, pero quería desearte una noche perfecta 🌙",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "Aunque es tarde, mi amor por ti nunca duerme 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Espero que estés descansando bien, mi vida! 😴",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "La madrugada me trae pensamientos dulces de ti 🌃💭",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Que tengas los sueños más hermosos del mundo! ✨",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content":
            "Aún despierto, pensando en lo afortunado que soy de tenerte 💖",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "¡Dulces sueños, mi princesa! Que descanses profundamente 👑",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content":
            "La noche protege tu sueño mientras yo cuido tu corazón 🛡️💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Espero que mañana despiertes renovada y feliz! 🌅",
        "type": "motivational",
        "theme": "Motivación",
      },
      {
        "content": "Cada estrella en el cielo brilla por tu belleza ⭐✨",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content":
            "¡Buenas noches tardías! Eres mi último y primer pensamiento 💭",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "Que la paz de la noche llene tu corazón 🕊️💞",
        "type": "inspirational",
        "theme": "Inspiración",
      },
      {
        "content":
            "¡Descansa, mi amor! Mañana será otro día para amarte más 💕",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "La madrugada susurra tu nombre en mis sueños 🌙💫",
        "type": "romantic",
        "theme": "Amor",
      },
      {
        "content": "¡Que tengas la noche más reparadora, mi cielo! 🌟",
        "type": "motivational",
        "theme": "Motivación",
      },
    ],
  };

  @override
  Message getCurrentMessage() {
    final period = _getCurrentTimePeriod();
    final messages = _messagesByPeriod[period] ?? _messagesByPeriod['mañana']!;
    final messageData = messages.first;

    return Message(
      id: 'daily_${DateTime.now().day}_0',
      content: messageData['content'],
      timeOfDay: period,
      theme: messageData['theme'],
    );
  }

  @override
  void nextMessage() {
    // This method is called when the user wants to see the next message
    // We'll implement it as advancing the message index
    advanceToNextMessage();
  }

  @override
  List<Map<String, dynamic>> getMessagesForTimePeriod(String period) {
    return _messagesByPeriod[period] ?? [];
  }

  /// Determines the current time period based on the hour of day
  String _getCurrentTimePeriod() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'mañana';
    } else if (hour >= 12 && hour < 18) {
      return 'tarde';
    } else if (hour >= 18 && hour < 22) {
      return 'noche';
    } else {
      return 'madrugada';
    }
  }

  /// Gets a message based on current message index (for cycling through messages)
  @override
  Future<Message> getMessageByIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_currentMessageIndexKey) ?? 0;

    final period = _getCurrentTimePeriod();
    final messages = _messagesByPeriod[period] ?? _messagesByPeriod['mañana']!;
    final messageIndex = currentIndex % messages.length;
    final messageData = messages[messageIndex];

    return Message(
      id: 'daily_${DateTime.now().day}_$messageIndex',
      content: messageData['content'],
      timeOfDay: period,
      theme: messageData['theme'],
    );
  }

  /// Advances to the next message and persists the index
  @override
  Future<void> advanceToNextMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_currentMessageIndexKey) ?? 0;
    await prefs.setInt(_currentMessageIndexKey, currentIndex + 1);
  }

  /// Resets message index to 0
  @override
  Future<void> resetMessageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentMessageIndexKey, 0);
  }
}
