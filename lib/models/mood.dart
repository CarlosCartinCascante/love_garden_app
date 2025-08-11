enum MoodType {
  terrible(0, 'Terrible', '😢'),
  bad(1, 'Mal', '😔'),
  okay(2, 'Regular', '😐'),
  good(3, 'Bien', '😊'),
  great(4, 'Genial', '😄'),
  amazing(5, 'Increíble', '🤩');

  const MoodType(this.value, this.label, this.emoji);

  final int value;
  final String label;
  final String emoji;

  static MoodType fromValue(int value) {
    return MoodType.values.firstWhere((mood) => mood.value == value);
  }
}

class MoodEntry {
  final String id;
  final MoodType mood;
  final DateTime date;
  final String? note;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.date,
    this.note,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      id: id,
      mood: MoodType.fromValue(map['mood'] ?? 0),
      date: map['date']?.toDate() ?? DateTime.now(),
      note: map['note'],
    );
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? '',
      mood: MoodType.fromValue(json['mood'] ?? 0),
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'mood': mood.value, 'date': date, 'note': note};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.value,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

class PlantGrowth {
  final String id;
  final String userId;
  final int totalMoodPoints;
  final int currentLevel;
  final DateTime lastUpdated;
  final List<MoodEntry> moodHistory;

  PlantGrowth({
    required this.id,
    required this.userId,
    required this.totalMoodPoints,
    required this.currentLevel,
    required this.lastUpdated,
    required this.moodHistory,
  });

  factory PlantGrowth.fromMap(Map<String, dynamic> map, String id) {
    return PlantGrowth(
      id: id,
      userId: map['userId'] ?? '',
      totalMoodPoints: map['totalMoodPoints'] ?? 0,
      currentLevel: map['currentLevel'] ?? 1,
      lastUpdated: map['lastUpdated']?.toDate() ?? DateTime.now(),
      moodHistory: [], // This will be loaded separately
    );
  }

  factory PlantGrowth.fromJson(Map<String, dynamic> json) {
    return PlantGrowth(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      totalMoodPoints: json['totalMoodPoints'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      moodHistory: [], // This will be loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalMoodPoints': totalMoodPoints,
      'currentLevel': currentLevel,
      'lastUpdated': lastUpdated,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalMoodPoints': totalMoodPoints,
      'currentLevel': currentLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  PlantGrowth copyWith({
    String? id,
    String? userId,
    int? totalMoodPoints,
    int? currentLevel,
    DateTime? lastUpdated,
    List<MoodEntry>? moodHistory,
  }) {
    return PlantGrowth(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalMoodPoints: totalMoodPoints ?? this.totalMoodPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      moodHistory: moodHistory ?? this.moodHistory,
    );
  }

  // Calculate plant level based on mood points
  static int calculateLevel(int moodPoints) {
    if (moodPoints < 10) return 1; // Semilla
    if (moodPoints < 25) return 2; // Brote
    if (moodPoints < 50) return 3; // Planta pequeña
    if (moodPoints < 100) return 4; // Planta mediana
    if (moodPoints < 200) return 5; // Planta grande
    return 6; // Planta florecida
  }

  String get plantStage {
    switch (currentLevel) {
      case 1:
        return 'Semilla';
      case 2:
        return 'Brote';
      case 3:
        return 'Planta Pequeña';
      case 4:
        return 'Planta Mediana';
      case 5:
        return 'Planta Grande';
      case 6:
        return 'Planta Florecida';
      default:
        return 'Desconocido';
    }
  }

  String get plantImagePath {
    return 'assets/plants/plant_level_$currentLevel.png';
  }
}
