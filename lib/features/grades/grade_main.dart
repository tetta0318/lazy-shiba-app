import '../../core/database/models/task.dart';
import 'attendance_calculator.dart';
import 'subject_db_access.dart';

export 'attendance_calculator.dart'
    show PendingAttendanceCheck, SubjectGradeSummary;
export '../../core/database/models/attendance.dart' show AttendanceStatus;

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
  GradeMain({
    SubjectDbAccess? subjectDbAccess,
    AttendanceCalculator? attendanceCalculator,
  })  : _subjectDbAccess = subjectDbAccess ?? SubjectDbAccess(),
        _attendanceCalculator =
            attendanceCalculator ?? AttendanceCalculator();

  final SubjectDbAccess _subjectDbAccess;
  final AttendanceCalculator _attendanceCalculator;

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

  /// 起動時の出席データ同期（main.dartから呼ぶ）。
  /// BuildContext不要の純粋なDB処理で、休講・8日以上前の未確認分を
  /// 自動記録する。戻り値（要確認リスト）はここでは使わない。
  Future<void> syncAttendanceOnStartup() async {
    await _attendanceCalculator.syncAttendanceRecords();
  }

  /// 出席確認ダイアログに表示する要確認リストを取得する。
  /// 内部でsyncAttendanceRecordsを再実行するため、
  /// main.dartでの起動時同期が失敗していてもここで自己回復する。
  Future<List<PendingAttendanceCheck>> loadPendingAttendanceChecks() {
    return _attendanceCalculator.syncAttendanceRecords();
  }

  /// 出席確認ダイアログの回答1件を保存する。
  Future<void> answerAttendanceCheck({
    required PendingAttendanceCheck check,
    required int status,
  }) {
    return _attendanceCalculator.saveAttendanceAnswer(
      subjectId: check.subjectId,
      date: check.date,
      status: status,
    );
  }

  /// 成績確認画面(SubjectDetailPage)向けの成績サマリを取得する。
  /// 出席率・全体の成績（課題手ごたえとの平均）の両方をこれ1本で賄う。
  Future<SubjectGradeSummary> loadSubjectGradeSummary(String subjectName) {
    return _attendanceCalculator.calculateSubjectGrade(subjectName);
  }
}