import '../../core/database/models/task.dart';
import 'subject_db_access.dart';

/// 課題成績予想画面に表示する課題1件分の情報。
class TaskGradeItem {
  final int taskId;
  final String taskName;
  final DateTime deadline;
  final bool isCompleted;
  final int feeling;

  const TaskGradeItem({
    required this.taskId,
    required this.taskName,
    required this.deadline,
    required this.isCompleted,
    required this.feeling,
  });

  factory TaskGradeItem._fromTask(Task task) {
    return TaskGradeItem(
      taskId: task.id!,
      taskName: task.taskName,
      deadline: task.deadline,
      isCompleted: task.status == 1,
      feeling: task.feeling,
    );
  }
}

/// 成績確認画面(SubjectDetailPage)の「課題成績予想」向けの内部処理を担当する。
class GradeMain {
  GradeMain({SubjectDbAccess? subjectDbAccess})
      : _subjectDbAccess = subjectDbAccess ?? SubjectDbAccess();

  final SubjectDbAccess _subjectDbAccess;

  /// 指定科目に紐づく課題を、完了・未完了を問わず締切順に取得する。
  Future<List<TaskGradeItem>> loadTaskGrades(String subjectName) async {
    final tasks = await _subjectDbAccess.getTasksBySubjectName(subjectName);
    final items = tasks.map(TaskGradeItem._fromTask).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return items;
  }

  /// 完了済み課題の成績予想（手ごたえ）を更新する。
  Future<void> updateTaskFeeling({
    required int taskId,
    required double value,
  }) {
    if (value < 0 || value > 100) {
      throw ArgumentError.value(value, 'value', '0〜100の範囲で入力してください。');
    }

    return _subjectDbAccess.updateTaskFeeling(
      taskId: taskId,
      feeling: value.round(),
    );
  }
}