/// 成績ウィジェット(W12)の設定値。
/// Android側の AndroidManifest.xml / GradeWidgetProvider.kt と対応している。
class GradeWidgetConfig {
  const GradeWidgetConfig._();

  static const String androidProviderName =
      'com.example.lazy_shiba_app.GradeWidgetProvider';

  static const String attendanceRateKey = 'widget_grade_attendance_rate';
  static const String overallScoreKey = 'widget_grade_overall_score';
}