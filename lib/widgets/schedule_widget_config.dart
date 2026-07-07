/// 予定ウィジェット(W13)の設定値。
/// Android側の AndroidManifest.xml / ScheduleWidgetProvider.kt と対応している。
class ScheduleWidgetConfig {
  const ScheduleWidgetConfig._();

  static const String androidProviderName =
      'com.example.lazy_shiba_app.ScheduleWidgetProvider';

  static const String tomorrowKey = 'widget_schedule_tomorrow';
  static const String weekKey = 'widget_schedule_week';
  static const String monthKey = 'widget_schedule_month';
  static const String nearestHolidayKey = 'widget_schedule_holiday';
}