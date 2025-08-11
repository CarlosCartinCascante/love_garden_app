import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/plant_growth.dart' as domain;

/// Concrete implementation of PlantRepository using SharedPreferences.
///
/// This repository manages plant growth state and provides
/// persistent storage for plant-related data.
class SharedPreferencesPlantRepository implements PlantRepository {
  static const String _plantStateKey = 'plant_growth_state';

  @override
  Future<void> savePlantGrowth(domain.PlantGrowth plantGrowth) async {
    final prefs = await SharedPreferences.getInstance();
    final json = plantGrowth.toJson();
    await prefs.setString(_plantStateKey, jsonEncode(json));
  }

  @override
  Future<domain.PlantGrowth?> loadPlantGrowth() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_plantStateKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return domain.PlantGrowth.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return null
      return null;
    }
  }

  @override
  Future<domain.PlantGrowth> updatePlantGrowth(int moodPoints) async {
    final currentState =
        await loadPlantGrowth() ?? domain.PlantGrowth.initial();

    // Calculate new total points (today-only model expected)
    final newTotalPoints = currentState.totalMoodPoints + moodPoints;

    // Determine level based on new daily thresholds (0..6)
    int newLevel = 0;
    if (newTotalPoints >= 28) {
      newLevel = 6;
    } else if (newTotalPoints >= 21) {
      newLevel = 5;
    } else if (newTotalPoints >= 15) {
      newLevel = 4;
    } else if (newTotalPoints >= 10) {
      newLevel = 3;
    } else if (newTotalPoints >= 6) {
      newLevel = 2;
    } else if (newTotalPoints >= 3) {
      newLevel = 1;
    } else {
      newLevel = 0;
    }

    final nextThreshold = newLevel >= 6
        ? domain.PlantGrowth.getPointsForLevel(6)
        : domain.PlantGrowth.getPointsForLevel(newLevel + 1);

    final newState = currentState.copyWith(
      currentLevel: newLevel,
      plantStage: domain.PlantGrowth.getPlantStageName(newLevel),
      totalMoodPoints: newTotalPoints,
      pointsForNextLevel: nextThreshold,
      lastUpdated: DateTime.now(),
    );

    await savePlantGrowth(newState);
    return newState;
  }

  @override
  Future<domain.PlantGrowth> resetPlantGrowth() async {
    final initialState = domain.PlantGrowth.initial();
    await savePlantGrowth(initialState);
    return initialState;
  }

  @override
  Future<double> getProgressToNextLevel() async {
    final currentState =
        await loadPlantGrowth() ?? domain.PlantGrowth.initial();

    if (currentState.currentLevel >= 6) {
      return 1.0; // Max level reached
    }

    final currentThreshold = currentState.currentLevel <= 0
        ? 0
        : domain.PlantGrowth.getPointsForLevel(currentState.currentLevel);
    final nextThreshold = domain.PlantGrowth.getPointsForLevel(
      currentState.currentLevel + 1,
    );
    final progressPoints = currentState.totalMoodPoints - currentThreshold;
    final requiredPoints = nextThreshold - currentThreshold;
    final ratio = requiredPoints <= 0
        ? 1.0
        : progressPoints / requiredPoints;
    return ratio.clamp(0.0, 1.0);
  }

  @override
  Future<String> getProgressDescription() async {
    final currentState =
        await loadPlantGrowth() ?? domain.PlantGrowth.initial();

    if (currentState.currentLevel >= 6) {
      return 'Tu planta ha alcanzado su máximo crecimiento! 🌸';
    }

    final currentThreshold = currentState.currentLevel <= 0
        ? 0
        : domain.PlantGrowth.getPointsForLevel(currentState.currentLevel);
    final nextThreshold = domain.PlantGrowth.getPointsForLevel(
      currentState.currentLevel + 1,
    );
    // Compute remaining strictly within the current level band
    final requiredPoints = (nextThreshold - currentThreshold).clamp(1, 1 << 31);
    final earnedInLevel = (currentState.totalMoodPoints - currentThreshold).clamp(0, 1 << 31);
    final remainingInLevel = (requiredPoints - earnedInLevel).clamp(0, 1 << 31);
    final pointsNeeded = remainingInLevel;
    final progress = await getProgressToNextLevel();
    final nextStage = domain.PlantGrowth.getPlantStageName(
      currentState.currentLevel + 1,
    );

    return 'Necesitas $pointsNeeded puntos más para que tu planta se convierta en $nextStage. '
        'Progreso: ${(progress * 100).toInt()}%';
  }
}
