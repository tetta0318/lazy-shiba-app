class Task {
  final int? id;
  final int subjectId;
  final String taskName;
  final DateTime deadline;
  final String? url;
  final int feeling;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    this.id,
    required this.subjectId,
    required this.taskName,
    required this.deadline,
    required this.url,
    required this.feeling,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: _parseNullableInt(map['id']),
      subjectId: _parseInt(map['subject_id'], fallback: 1),
      taskName: map['task_name']?.toString() ?? '',
      deadline: _parseDateTime(map['deadline']),
      url: map['url']?.toString(),
      feeling: _parseInt(map['feeling']),
      status: _parseInt(map['status']),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'task_name': taskName,
      'deadline': deadline.toIso8601String(),
      'url': url,
      'feeling': feeling,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    int? subjectId,
    String? taskName,
    DateTime? deadline,
    String? url,
    int? feeling,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      taskName: taskName ?? this.taskName,
      deadline: deadline ?? this.deadline,
      url: url ?? this.url,
      feeling: feeling ?? this.feeling,
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
  final text = value?.toString() ?? '';
  final normalized = text
      .replaceAll('年', '-')
      .replaceAll('月', '-')
      .replaceAll('日', ' ')
      .replaceAll('/', '-')
      .trim();

  final parsed = DateTime.tryParse(normalized);
  if (parsed != null) {
    return parsed;
  }

  final match = RegExp(
    r'(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})(?:[日\s]+(\d{1,2}):(\d{1,2}))?',
  ).firstMatch(text);

  if (match != null) {
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.tryParse(match.group(4) ?? '') ?? 23;
    final minute = int.tryParse(match.group(5) ?? '') ?? 59;
    return DateTime(year, month, day, hour, minute);
  }

  return DateTime.now();
}
