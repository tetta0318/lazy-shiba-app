import 'grade_widget_service.dart';
import 'schedule_widget_service.dart';
import 'task_widget_service.dart';

/// 課題(W11)・成績(W12)・予定(W13)ウィジェットの更新を統括するメイン処理。
class WidgetMain {
  WidgetMain({
    TaskWidgetService? taskWidgetService,
    GradeWidgetService? gradeWidgetService,
    ScheduleWidgetService? scheduleWidgetService,
  })  : _taskWidgetService = taskWidgetService ?? TaskWidgetService(),
        _gradeWidgetService = gradeWidgetService ?? GradeWidgetService(),
        _scheduleWidgetService =
            scheduleWidgetService ?? ScheduleWidgetService();

  final TaskWidgetService _taskWidgetService;
  final GradeWidgetService _gradeWidgetService;
  final ScheduleWidgetService _scheduleWidgetService;

  bool _isRefreshing = false;

  /// 3つのウィジェットを順次更新する。
  /// いずれかの更新に失敗しても、他のウィジェットの更新は継続する。
  /// ウィジェット未配置や権限差異では失敗しても画面操作を止めない。
  Future<void> refreshAllWidgets() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    try {
      await _refreshSafely(_taskWidgetService.refresh);
      await _refreshSafely(_gradeWidgetService.refresh);
      await _refreshSafely(_scheduleWidgetService.refresh);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshSafely(Future<void> Function() refresh) async {
    try {
      await refresh();
    } catch (_) {
      // 何もしない
    }
  }
}