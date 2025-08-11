/// Domain entity representing plant growth state in the Love Garden app.
///
/// This entity encapsulates all plant-related data and business logic,
/// following the Single Responsibility Principle.
class PlantGrowth {
  /// Current growth level of the plant (0-6)
  final int currentLevel;

  /// Name of the current plant stage
  final String plantStage;

  /// Total mood points accumulated
  final int totalMoodPoints;

  /// Points required for the next level
  final int pointsForNextLevel;

  /// Date when the plant was last updated
  final DateTime lastUpdated;

  const PlantGrowth({
    required this.currentLevel,
    required this.plantStage,
    required this.totalMoodPoints,
    required this.pointsForNextLevel,
    required this.lastUpdated,
  });

  /// Factory constructor to create initial plant state
  factory PlantGrowth.initial() {
    return PlantGrowth(
      currentLevel: 0,
      plantStage: 'Semilla',
      totalMoodPoints: 0,
      pointsForNextLevel: 3,
      lastUpdated: DateTime.now(),
    );
  }

  /// Creates a copy of this plant growth with updated values
  PlantGrowth copyWith({
    int? currentLevel,
    String? plantStage,
    int? totalMoodPoints,
    int? pointsForNextLevel,
    DateTime? lastUpdated,
  }) {
    return PlantGrowth(
      currentLevel: currentLevel ?? this.currentLevel,
      plantStage: plantStage ?? this.plantStage,
      totalMoodPoints: totalMoodPoints ?? this.totalMoodPoints,
      pointsForNextLevel: pointsForNextLevel ?? this.pointsForNextLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Serializes the plant growth to a map for storage
  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'plantStage': plantStage,
      'totalMoodPoints': totalMoodPoints,
      'pointsForNextLevel': pointsForNextLevel,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Creates a PlantGrowth instance from stored data
  factory PlantGrowth.fromJson(Map<String, dynamic> json) {
    return PlantGrowth(
      currentLevel: json['currentLevel'] ?? 0,
      plantStage: json['plantStage'] ?? 'Semilla',
      totalMoodPoints: json['totalMoodPoints'] ?? 0,
      pointsForNextLevel: json['pointsForNextLevel'] ?? 3,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Gets the plant stage name based on level
  static String getPlantStageName(int level) {
    const stageNames = {
      0: 'Semilla',
      1: 'Brote',
      2: 'Plántula',
      3: 'Planta Joven',
      4: 'Planta Madura',
      5: 'Planta Floreciente',
      6: 'Planta Radiante',
    };
    return stageNames[level] ?? 'Semilla';
  }

  /// Gets the emoji representation for the plant level
  static String getPlantEmoji(int level) {
    const plantEmojis = {
      0: '🌱',
      1: '🌿',
      2: '🪴',
      3: '🌻',
      4: '🌺',
      5: '🌸',
      6: '🌷',
    };
    return plantEmojis[level] ?? '🌱';
  }

  /// Calculates points required for next level
  static int getPointsForLevel(int level) {
    // Daily-friendly progression: achievable but meaningful
    // L1: 3, L2: 6, L3: 10, L4: 15, L5: 21, L6: 28
    const pointsRequired = {1: 3, 2: 6, 3: 10, 4: 15, 5: 21, 6: 28};
    return pointsRequired[level] ?? 28;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantGrowth &&
        other.currentLevel == currentLevel &&
        other.plantStage == plantStage &&
        other.totalMoodPoints == totalMoodPoints &&
        other.pointsForNextLevel == pointsForNextLevel &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return currentLevel.hashCode ^
        plantStage.hashCode ^
        totalMoodPoints.hashCode ^
        pointsForNextLevel.hashCode ^
        lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'PlantGrowth(level: $currentLevel, stage: $plantStage, points: $totalMoodPoints)';
  }
}
