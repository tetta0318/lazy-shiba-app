class Subject {
  final int? id;
  final String subjectName;
  final bool isOnline;
  final int attendanceCount;
  final int totalClassCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    this.id,
    required this.subjectName,
    required this.isOnline,
    required this.attendanceCount,
    required this.totalClassCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: _parseNullableInt(map['id']),
      subjectName: map['subject_name']?.toString() ?? '',
      isOnline: _parseInt(map['is_online']) == 1,
      attendanceCount: _parseInt(map['attendance_count']),
      totalClassCount: _parseInt(map['total_class_count']),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_name': subjectName,
      'is_online': isOnline ? 1 : 0,
      'attendance_count': attendanceCount,
      'total_class_count': totalClassCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Subject copyWith({
    int? id,
    String? subjectName,
    bool? isOnline,
    int? attendanceCount,
    int? totalClassCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      isOnline: isOnline ?? this.isOnline,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      totalClassCount: totalClassCount ?? this.totalClassCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

int _parseInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
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
