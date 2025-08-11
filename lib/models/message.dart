class Message {
  final String id;
  final String content;
  final String timeOfDay; // 'morning', 'afternoon', 'evening', 'night'
  final String? theme; // 'Amor', 'Motivación', 'Inspiración'
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.content,
    required this.timeOfDay,
    this.theme,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      content:
          map['text'] ??
          map['content'] ??
          '', // Support both 'text' and 'content'
      timeOfDay:
          map['period'] ??
          map['timeOfDay'] ??
          'mañana', // Support both 'period' and 'timeOfDay'
      theme: map['type'] ?? map['theme'], // Support both 'type' and 'theme'
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'timeOfDay': timeOfDay,
      'theme': theme,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Message copyWith({
    String? id,
    String? content,
    String? timeOfDay,
    String? theme,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
