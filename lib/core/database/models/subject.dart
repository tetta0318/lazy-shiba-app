class Subject {
  final int? id;
  final String subjectName;
  final bool isOnline;
  final int attendanceCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    this.id,
    required this.subjectName,
    required this.isOnline,
    required this.attendanceCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      subjectName: map['subject_name'],
      isOnline: map['is_online'] == 1,
      attendanceCount: map['attendance_count'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_name': subjectName,
      'is_online': isOnline ? 1 : 0,
      'attendance_count': attendanceCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Subject copyWith({
    int? id,
    String? subjectName,
    bool? isOnline,
    int? attendanceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      isOnline: isOnline ?? this.isOnline,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}