import 'package:home_widget/home_widget.dart';

import '../core/database/models/subject.dart';
import '../core/database/models/task.dart';
import '../core/database/repositories/subject_repository.dart';
import '../core/database/repositories/task_repository.dart';
import 'grade_widget_config.dart';

/// 成績ウィジェット(W12)にDBの最新の出席率・全体の成績を反映する。
class GradeWidgetService {
  GradeWidgetService({
    SubjectRepository? subjectRepository,
    TaskRepository? taskRepository,
  })  : _subjectRepository = subjectRepository ?? SubjectRepository(),
        _taskRepository = taskRepository ?? TaskRepository();

  final SubjectRepository _subjectRepository;
  final TaskRepository _taskRepository;

  Future<void> refresh() async {
    final subjects = await _subjectRepository.getSubjects();
    final completedTasks = await _taskRepository.getTasksByStatus(1);

    final attendanceRate = _calcAttendanceRate(subjects);
    final overallScore = _calcOverallScore(completedTasks);

    await HomeWidget.saveWidgetData<String>(
      GradeWidgetConfig.attendanceRateKey,
      attendanceRate?.toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      GradeWidgetConfig.overallScoreKey,
      overallScore?.toString(),
    );

    await HomeWidget.updateWidget(
      qualifiedAndroidName: GradeWidgetConfig.androidProviderName,
    );
  }

  int? _calcAttendanceRate(List<Subject> subjects) {
    var attended = 0;
    var total = 0;
    for (final subject in subjects) {
      attended += subject.attendanceCount;
      total += subject.totalClassCount;
    }

    if (total <= 0) {
      return null;
    }
    return (attended / total * 100).round().clamp(0, 100);
  }

  int? _calcOverallScore(List<Task> completedTasks) {
    if (completedTasks.isEmpty) {
      return null;
    }
    final total = completedTasks.fold<int>(0, (sum, task) => sum + task.feeling);
    return (total / completedTasks.length).round().clamp(0, 100);
  }
}