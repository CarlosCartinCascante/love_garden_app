/// Domain entity representing user preferences in the Love Garden app.
///
/// This entity handles all user-specific settings and preferences,
/// following the Single Responsibility Principle.
class UserPreferences {
  /// Unique user identifier
  final String userId;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// Whether this is the user's first time using the app
  final bool isFirstTime;

  /// Current message index for cycling through messages
  final int currentMessageIndex;

  /// Date when preferences were last updated
  final DateTime lastUpdated;

  /// Preferred notification times per period (keys in Spanish):
  /// 'mañana', 'tarde', 'noche', 'madrugada' with values formatted as HH:mm
  final Map<String, String> notificationTimes;

  /// Whether to show times in 24-hour format
  final bool use24hFormat;

  const UserPreferences({
    required this.userId,
    required this.notificationsEnabled,
    required this.isFirstTime,
    required this.currentMessageIndex,
    required this.lastUpdated,
    required this.notificationTimes,
    required this.use24hFormat,
  });

  /// Factory constructor to create default user preferences
  factory UserPreferences.initial() {
    return UserPreferences(
      userId: '',
      notificationsEnabled: true,
      isFirstTime: true,
      currentMessageIndex: 0,
      lastUpdated: DateTime.now(),
      notificationTimes: const {
        'mañana': '08:30',
        'tarde': '13:00',
        'noche': '20:30',
        'madrugada': '23:30',
      },
      use24hFormat: true,
    );
  }

  /// Creates a copy of user preferences with updated values
  UserPreferences copyWith({
    String? userId,
    bool? notificationsEnabled,
    bool? isFirstTime,
    int? currentMessageIndex,
    DateTime? lastUpdated,
    Map<String, String>? notificationTimes,
    bool? use24hFormat,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      currentMessageIndex: currentMessageIndex ?? this.currentMessageIndex,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      use24hFormat: use24hFormat ?? this.use24hFormat,
    );
  }

  /// Serializes user preferences to a map for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'isFirstTime': isFirstTime,
      'currentMessageIndex': currentMessageIndex,
      'lastUpdated': lastUpdated.toIso8601String(),
      'notificationTimes': notificationTimes,
      'use24hFormat': use24hFormat,
    };
  }

  /// Creates UserPreferences instance from stored data
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] ?? '',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      isFirstTime: json['isFirstTime'] ?? true,
      currentMessageIndex: json['currentMessageIndex'] ?? 0,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      notificationTimes:
          (json['notificationTimes'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          const {
            'mañana': '08:30',
            'tarde': '13:00',
            'noche': '20:30',
            'madrugada': '23:30',
          },
      use24hFormat: json['use24hFormat'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.userId == userId &&
        other.notificationsEnabled == notificationsEnabled &&
        other.isFirstTime == isFirstTime &&
        other.currentMessageIndex == currentMessageIndex &&
        other.lastUpdated == lastUpdated &&
        _mapEquals(other.notificationTimes, notificationTimes) &&
        other.use24hFormat == use24hFormat;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        notificationsEnabled.hashCode ^
        isFirstTime.hashCode ^
        currentMessageIndex.hashCode ^
        lastUpdated.hashCode ^
        notificationTimes.hashCode ^
        use24hFormat.hashCode;
  }

  @override
  String toString() {
    return 'UserPreferences(userId: $userId, notifications: $notificationsEnabled, firstTime: $isFirstTime, use24h: $use24hFormat, times: $notificationTimes)';
  }
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
