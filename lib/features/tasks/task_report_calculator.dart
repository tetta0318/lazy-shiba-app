import 'task_database_accessor.dart';

/// 完了報告の受付とステータス更新を担当する（M3-4 完了報告・成績計算処理）
class TaskReportCalculator {
  TaskReportCalculator({TaskDatabaseAccessor? taskDatabaseAccessor})
      : _taskDatabaseAccessor = taskDatabaseAccessor ?? TaskDatabaseAccessor();

  final TaskDatabaseAccessor _taskDatabaseAccessor;

  Future<void> processCompletionReport({
    required int taskId,
    required int feeling,
  }) {
    if (feeling < 0 || feeling > 100) {
      throw ArgumentError.value(feeling, 'feeling', '0〜100の範囲で入力してください。');
    }

    return _taskDatabaseAccessor.saveCompletionReport(
      taskId: taskId,
      feeling: feeling,
    );
  }

  Future<void> revertCompletion({required int taskId}) {
    return _taskDatabaseAccessor.revertCompletion(taskId: taskId);
  }
}