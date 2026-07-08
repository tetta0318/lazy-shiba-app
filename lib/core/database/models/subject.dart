/// 授業がどの期間に開講されるか（[SubjectTerm] の値のいずれか、または未設定）。
class SubjectTerm {
  const SubjectTerm._();

  /// 通期・前期/後期を通して14週程度開講される科目。
  static const full = 'full';

  /// 前半7週のみ開講されるクォーター科目。
  static const q1 = 'q1';

  /// 後半7週のみ開講されるクォーター科目。
  static const q2 = 'q2';
}

/// 曜日は [DateTime.weekday] と同じ表現（1: 月曜日 〜 7: 日曜日）。
class Subject {
  final int? id;
  final String subjectName;
  final bool isOnline;
  final int attendanceCount;
  final int totalClassCount;
  final int? dayOfWeek;
  final int? period;

  /// [period] から連続して何コマ分を占有するか（例: 3限・4限の2コマ連続授業なら2）。
  final int periodCount;

  /// [SubjectTerm.full] / [SubjectTerm.q1] / [SubjectTerm.q2] のいずれか。未設定の場合は null。
  final String? termType;
  final DateTime? termStartDate;
  final DateTime? termEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    this.id,
    required this.subjectName,
    required this.isOnline,
    required this.attendanceCount,
    required this.totalClassCount,
    this.dayOfWeek,
    this.period,
    this.periodCount = 1,
    this.termType,
    this.termStartDate,
    this.termEndDate,
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
      dayOfWeek: _parseNullableInt(map['day_of_week']),
      period: _parseNullableInt(map['period']),
      periodCount: _parseInt(map['period_count'], fallback: 1),
      termType: map['term_type']?.toString(),
      termStartDate: _parseNullableDateTime(map['term_start_date']),
      termEndDate: _parseNullableDateTime(map['term_end_date']),
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
      'day_of_week': dayOfWeek,
      'period': period,
      'period_count': periodCount,
      'term_type': termType,
      'term_start_date': termStartDate?.toIso8601String(),
      'term_end_date': termEndDate?.toIso8601String(),
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
    int? dayOfWeek,
    int? period,
    int? periodCount,
    String? termType,
    DateTime? termStartDate,
    DateTime? termEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      isOnline: isOnline ?? this.isOnline,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      totalClassCount: totalClassCount ?? this.totalClassCount,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      period: period ?? this.period,
      periodCount: periodCount ?? this.periodCount,
      termType: termType ?? this.termType,
      termStartDate: termStartDate ?? this.termStartDate,
      termEndDate: termEndDate ?? this.termEndDate,
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

DateTime? _parseNullableDateTime(Object? value) {
  if (value == null || value.toString().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
