class Task{
  final int? taskId;
  final int subjectId;
  final String taskName;
  final String subjectName;
  final DateTime deadline;
  final String? url;
  final int feeling;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    this.taskId,
    required this.subjectId,
    required this.taskName,
    required this.subjectName,
    required this.deadline,
    required this.url,
    required this.feeling,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromMap(Map<String, dynamic> map){
    return Task(
      taskId: map['task_id'],
      subjectId: map['subject_id'],
      taskName: map['task_name'],
      subjectName: map['subject_name'],
      deadline: DateTime.parse(map['deadline']),
      url: map['url'],
      feeling: map['feeling'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'subject_id': subjectId,
      'task_name': taskName,
      'subject_name': subjectName,
      'deadline': deadline.toIso8601String(),
      'url': url,
      'feeling': feeling,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}