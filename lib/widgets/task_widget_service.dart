import 'package:home_widget/home_widget.dart';

import '../core/database/repositories/task_repository.dart';
import 'task_widget_config.dart';

/// 課題ウィジェット(W11)にDBの最新の未完了課題を反映する。
class TaskWidgetService {
  TaskWidgetService({TaskRepository? taskRepository})
    : _taskRepository = taskRepository ?? TaskRepository();

  final TaskRepository _taskRepository;

  Future<void> refresh() async {
    final incompleteTasks = await _taskRepository.getTasksByStatus(0);
    incompleteTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    final visibleTasks = incompleteTasks
        .take(TaskWidgetConfig.maxVisibleTasks)
        .toList();

    for (var i = 0; i < TaskWidgetConfig.maxVisibleTasks; i++) {
      final nameKey = '${TaskWidgetConfig.taskNameKeyPrefix}${i + 1}';
      final remainingKey = '${TaskWidgetConfig.taskRemainingKeyPrefix}${i + 1}';

      if (i < visibleTasks.length) {
        final task = visibleTasks[i];
        await HomeWidget.saveWidgetData<String>(nameKey, '・${task.taskName}');
        await HomeWidget.saveWidgetData<String>(
          remainingKey,
          _formatRemaining(task.deadline),
        );
      } else {
        await HomeWidget.saveWidgetData<String>(
          nameKey,
          i == 0 ? '課題はありません' : null,
        );
        await HomeWidget.saveWidgetData<String>(remainingKey, null);
      }
    }

    await HomeWidget.updateWidget(
      qualifiedAndroidName: TaskWidgetConfig.androidProviderName,
    );
  }

  String _formatRemaining(DateTime deadline) {
    final now = DateTime.now();
    final days = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (days == 0) {
      return '今日';
    }
    if (days > 0) {
      return 'あと$days日';
    }
    return '${days.abs()}日前';
  }
}