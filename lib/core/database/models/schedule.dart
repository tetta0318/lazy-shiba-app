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
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      genre: map['genre'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
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