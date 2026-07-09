import 'package:dio/dio.dart';

import '../../core/database/models/task.dart';
import '../../widgets/task_widget_service.dart';
import 'task_database_accessor.dart';
import 'task_report_calculator.dart';
import 'task_scraping.dart';

export 'task_scraping.dart' show SessionExpiredException;

/// ScombZとの通信に失敗した場合にスローされる（TasksScreen向けにDioExceptionを隠蔽する）
class TaskSyncNetworkException implements Exception {
  final String message;

  TaskSyncNetworkException([this.message = '通信に失敗しました。ネットワーク接続を確認してください。']);

  @override
  String toString() => message;
}

/// 課題一覧画面(TasksScreen)に表示する課題1件分の情報。
class TaskListItem {
  final int taskId;
  final String taskName;
  final DateTime deadline;
  final bool isCompleted;

  const TaskListItem({
    required this.taskId,
    required this.taskName,
    required this.deadline,
    required this.isCompleted,
  });

  factory TaskListItem._fromTask(Task task) {
    return TaskListItem(
      taskId: task.id!,
      taskName: task.taskName,
      deadline: task.deadline,
      isCompleted: task.status != 0,
    );
  }
}

/// 課題一覧画面(TasksScreen)・完了報告画面(CompletionReportScreen)向けの内部処理を担当する。
class TaskMain {
  TaskMain({
    TaskDatabaseAccessor? taskDatabaseAccessor,
    TaskReportCalculator? taskReportCalculator,
    TaskScraping? taskScraping,
    TaskWidgetService? taskWidgetService,
  })  : _taskDatabaseAccessor = taskDatabaseAccessor ?? TaskDatabaseAccessor(),
        _taskReportCalculator = taskReportCalculator ?? TaskReportCalculator(),
        _taskScraping = taskScraping ?? TaskScraping(),
        _taskWidgetService = taskWidgetService ?? TaskWidgetService();

  static const _hideCompletedAfter = Duration(days: 7);

  final TaskDatabaseAccessor _taskDatabaseAccessor;
  final TaskReportCalculator _taskReportCalculator;
  final TaskScraping _taskScraping;
  final TaskWidgetService _taskWidgetService;

  /// 未完了の課題、および完了から7日以内の課題を取得する。
  Future<List<TaskListItem>> loadVisibleTasks() async {
    final tasks = await _taskDatabaseAccessor.getTasks();
    final now = DateTime.now();

    final visibleTasks = tasks.where((task) {
      if (task.status == 0) {
        return true;
      }
      final completedAt = task.completedAt;
      if (completedAt == null) {
        return true;
      }
      return now.difference(completedAt) < _hideCompletedAfter;
    });

    return visibleTasks.map(TaskListItem._fromTask).toList();
  }

  /// 更新ボタンから呼び出す、ScombZとの再同期処理。
  Future<void> syncWithScombz() async {
    try {
      await _taskScraping.syncWithScombz();
    } on DioException {
      throw TaskSyncNetworkException();
    }
  }

  /// 完了報告の受付とステータス更新を行う。
  Future<void> reportCompletion({
    required int taskId,
    required int feeling,
  }) {
    return _taskReportCalculator.processCompletionReport(
      taskId: taskId,
      feeling: feeling,
    );
  }

  /// 完了済み課題を未完了に戻す。
  Future<void> revertCompletion({required int taskId}) {
    return _taskReportCalculator.revertCompletion(taskId: taskId);
  }

  /// 課題ウィジェット(W11)にDBの最新の未完了課題を反映する。
  /// ウィジェット未配置や権限差異では失敗しても画面操作を止めない。
  Future<void> refreshHomeWidget() async {
    try {
      await _taskWidgetService.refresh();
    } catch (_) {
      // 何もしない
    }
  }
}