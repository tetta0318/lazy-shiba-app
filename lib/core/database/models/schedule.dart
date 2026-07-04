class Schedule {
  final int? id;
  final DateTime date;
  final String title;
  final String genre;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Schedule({
    this.id,
    required this.date,
    required this.title,
    required this.genre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: _parseNullableInt(map['id']),
      date: _parseDateTime(map['date']),
      title: map['title']?.toString() ?? '',
      genre: map['genre']?.toString() ?? '',
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'genre': genre,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Schedule copyWith({
    int? id,
    DateTime? date,
    String? title,
    String? genre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

int? _parseNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

DateTime _parseDateTime(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
}
