/// 課題ウィジェット(W11)の設定値。
/// Android側の AndroidManifest.xml / TaskWidgetProvider.kt と対応している。
class TaskWidgetConfig {
  const TaskWidgetConfig._();

  static const String androidProviderName =
      'com.example.lazy_shiba_app.TaskWidgetProvider';

  static const String taskNameKeyPrefix = 'widget_task_name_';
  static const String taskRemainingKeyPrefix = 'widget_task_remaining_';
  static const int maxVisibleTasks = 4;
}