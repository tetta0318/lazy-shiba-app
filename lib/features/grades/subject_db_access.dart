import '../../core/database/models/subject.dart';
import '../../core/database/models/task.dart';
import '../../core/database/repositories/subject_repository.dart';
import '../../core/database/repositories/task_repository.dart';

/// 成績画面(GradesPage)・成績確認画面(SubjectDetailPage)向けの
/// 科目データベースアクセス処理。
class SubjectDbAccess {
  SubjectDbAccess({
    SubjectRepository? subjectRepository,
    TaskRepository? taskRepository,
  })  : _subjectRepository = subjectRepository ?? SubjectRepository(),
        _taskRepository = taskRepository ?? TaskRepository();

  final SubjectRepository _subjectRepository;
  final TaskRepository _taskRepository;

  /// 登録済みの全科目を取得する。
  Future<List<Subject>> getSubjects() {
    return _subjectRepository.getSubjects();
  }

  /// 科目名から出席率（0〜100）を計算する。
  /// 該当科目がDBに存在しない、または総回数が0の場合は0を返す。
  Future<double> getAttendanceRate(String subjectName) async {
    final subject = await _subjectRepository.getSubjectByName(subjectName);
    if (subject == null || subject.totalClassCount <= 0) {
      return 0;
    }
    return subject.attendanceCount / subject.totalClassCount * 100;
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
}