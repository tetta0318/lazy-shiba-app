import '../../core/database/models/attendance.dart';
import '../../core/database/models/subject.dart';
import '../../core/database/models/task.dart';
import '../../core/database/repositories/attendance_repository.dart';
import '../../core/database/repositories/schedule_repository.dart';
import '../../core/database/repositories/subject_repository.dart';
import '../../core/database/repositories/task_repository.dart';

/// 成績画面(GradesPage)・成績確認画面(SubjectDetailPage)向けの
/// 科目データベースアクセス処理。
///
/// 判定・計算・日付列挙のロジックは持たない。生データの取得と、
/// 科目名→IDの解決、repositoryへの委譲のみを行う（計算はAttendanceCalculatorの責務）。
class SubjectDbAccess {
  SubjectDbAccess({
    SubjectRepository? subjectRepository,
    TaskRepository? taskRepository,
    ScheduleRepository? scheduleRepository,
    AttendanceRepository? attendanceRepository,
  })  : _subjectRepository = subjectRepository ?? SubjectRepository(),
        _taskRepository = taskRepository ?? TaskRepository(),
        _scheduleRepository = scheduleRepository ?? ScheduleRepository(),
        _attendanceRepository =
            attendanceRepository ?? AttendanceRepository();

  final SubjectRepository _subjectRepository;
  final TaskRepository _taskRepository;
  final ScheduleRepository _scheduleRepository;
  final AttendanceRepository _attendanceRepository;

  static const _cancelledScheduleGenre = '休講';

  /// 登録済みの全科目を取得する。
  Future<List<Subject>> getSubjects() {
    return _subjectRepository.getSubjects();
  }

  /// 科目名から、その科目に紐づく課題を完了・未完了を問わず取得する。
  /// 該当科目がDBに存在しない場合は空リストを返す。
  Future<List<Task>> getTasksBySubjectName(String subjectName) async {
    final subject = await _subjectRepository.getSubjectByName(subjectName);
    if (subject?.id == null) {
      return [];
    }
    return _taskRepository.getTasksBySubjectId(subject!.id!);
  }

  /// 課題の成績予想（手ごたえ）を更新する。
  Future<void> updateTaskFeeling({
    required int taskId,
    required int feeling,
  }) {
    return _taskRepository.updateTaskFeeling(
      id: taskId,
      feeling: feeling,
    );
  }

  /// 科目IDに紐づく出席レコードを日付昇順で取得する。
  Future<List<Attendance>> getAttendancesBySubjectId(int subjectId) {
    return _attendanceRepository.getAttendancesBySubjectId(subjectId);
  }

  /// 科目名に紐づく出席レコードを日付昇順で取得する。
  /// 該当科目がDBに存在しない場合は空リストを返す。
  Future<List<Attendance>> getAttendancesBySubjectName(
    String subjectName,
  ) async {
    final subject = await _subjectRepository.getSubjectByName(subjectName);
    if (subject?.id == null) {
      return [];
    }
    return _attendanceRepository.getAttendancesBySubjectId(subject!.id!);
  }

  /// 出席レコードを1件保存する（同一科目・同一日付が既にあればstatus更新）。
  Future<void> saveAttendance({
    required int subjectId,
    required DateTime date,
    required int status,
  }) {
    return _attendanceRepository.saveAttendance(
      subjectId: subjectId,
      date: date,
      status: status,
    );
  }

  /// genre='休講'の予定の日付集合を返す（時刻を落とした日付のみ）。
  Future<Set<DateTime>> getCancellationDates() async {
    final schedules =
        await _scheduleRepository.getSchedulesByGenre(_cancelledScheduleGenre);
    return schedules
        .map((s) => AttendanceRepository.normalizeDate(s.date))
        .toSet();
  }
}