import '../domain/repositories/repositories.dart';
import '../data/repositories/mood_repository_impl.dart';
import '../data/repositories/plant_repository_impl.dart';
import '../data/repositories/message_repository_impl.dart';
import '../data/repositories/user_preferences_repository.dart';
import 'notification_service.dart';

/// Service locator for dependency injection following SOLID principles.
///
/// This class implements the Dependency Inversion Principle by providing
/// a centralized location for registering and retrieving dependencies.
/// It allows for easy testing and flexibility in implementation choices.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  /// Registers all repositories with their concrete implementations
  void registerRepositories() {
    // Register mood repository
    _services[MoodRepository] = SharedPreferencesMoodRepository();

    // Register plant repository
    _services[PlantRepository] = SharedPreferencesPlantRepository();

    // Register message repository
    _services[MessageRepository] = InMemoryMessageRepository();

    // Register user preferences repository
    _services[SharedPreferencesUserRepository] =
        SharedPreferencesUserRepository();

    // Register notification service
    _services[NotificationService] = LocalNotificationService();
  }

  /// Gets a service instance by type
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    return service as T;
  }

  /// Registers a specific service instance
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Clears all registered services (useful for testing)
  void reset() {
    _services.clear();
  }

  /// Checks if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }
}

/// Extension to make service location more convenient
extension ServiceLocatorExtension on Object {
  T locate<T>() => ServiceLocator().get<T>();
}
