import '../entities/plant_growth.dart' as domain;
import '../../models/mood.dart';
import '../../models/message.dart';

/// Repository interface for mood-related operations.
///
/// This interface defines the contract for mood data persistence,
/// following the Dependency Inversion Principle.
abstract class MoodRepository {
  /// Adds a new mood entry
  Future<void> addMoodEntry(MoodEntry entry);

  /// Retrieves all mood entries
  Future<List<MoodEntry>> getAllMoodEntries();

  /// Gets mood entries for a specific date range
  Future<List<MoodEntry>> getMoodEntriesForDateRange(
    DateTime start,
    DateTime end,
  );

  /// Gets mood entries for today
  Future<List<MoodEntry>> getTodayMoodEntries();

  /// Gets mood counts for today grouped by mood type
  Future<Map<String, int>> getTodayMoodCounts();

  /// Resets all mood entries for today
  Future<void> resetTodayMoods();

  /// Gets mood entries for the current week
  Future<List<MoodEntry>> getWeeklyMoods();

  /// Calculates average mood score
  Future<double> getAverageMoodScore();

  /// Removes all mood entries (for reset functionality)
  Future<void> clearAllMoodEntries();
}

/// Repository interface for plant growth operations.
///
/// This interface defines the contract for plant growth data persistence.
abstract class PlantRepository {
  /// Saves plant growth state
  Future<void> savePlantGrowth(domain.PlantGrowth plantGrowth);

  /// Loads plant growth state
  Future<domain.PlantGrowth?> loadPlantGrowth();

  /// Updates plant growth based on mood points
  Future<domain.PlantGrowth> updatePlantGrowth(int moodPoints);

  /// Resets plant growth to initial state
  Future<domain.PlantGrowth> resetPlantGrowth();

  /// Gets progress to next level (0.0 to 1.0)
  Future<double> getProgressToNextLevel();

  /// Gets progress description text
  Future<String> getProgressDescription();
}

/// Repository interface for message operations.
///
/// This interface defines the contract for message data access.
abstract class MessageRepository {
  /// Gets current message based on time of day
  Message getCurrentMessage();

  /// Advances to next message
  void nextMessage();

  /// Gets all messages for a specific time period
  List<Map<String, dynamic>> getMessagesForTimePeriod(String period);

  /// Gets a message based on current message index (for cycling through messages)
  Future<Message> getMessageByIndex();

  /// Advances to the next message and persists the index
  Future<void> advanceToNextMessage();

  /// Resets message index to 0
  Future<void> resetMessageIndex();
}
