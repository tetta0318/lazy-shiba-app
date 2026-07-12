/// 出席レコードの状態。値はattendances.statusカラムのint値。
class AttendanceStatus {
  const AttendanceStatus._();

  /// 欠席
  static const int absent = 0;

  /// 出席
  static const int present = 1;

  /// 休講
  static const int cancelled = 2;

  /// 未確認（古すぎて確認しなかった分）
  static const int unconfirmed = 3;
}

/// 1コマ・1科目分の出席レコード（[subjectId], [date]の組で一意）。
class Attendance {
  final int? id;
  final int subjectId;
  final DateTime date;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Attendance({
    this.id,
    required this.subjectId,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: _parseNullableInt(map['id']),
      subjectId: _parseInt(map['subject_id']),
      date: _parseDateTime(map['date']),
      status: _parseInt(map['status'], fallback: AttendanceStatus.unconfirmed),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'date': date.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Attendance copyWith({
    int? id,
    int? subjectId,
    DateTime? date,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      status: status ?? this.status,
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