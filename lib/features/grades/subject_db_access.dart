import '../../core/database/repositories/subject_repository.dart';

/// 成績確認画面(SubjectDetailPage)向けの科目データベースアクセス処理。
class SubjectDbAccess {
  SubjectDbAccess({SubjectRepository? subjectRepository})
      : _subjectRepository = subjectRepository ?? SubjectRepository();

  final SubjectRepository _subjectRepository;

  /// 科目名から出席率（0〜100）を計算する。
  /// 該当科目がDBに存在しない、または総回数が0の場合は0を返す。
  Future<double> getAttendanceRate(String subjectName) async {
    final subject = await _subjectRepository.getSubjectByName(subjectName);
    if (subject == null || subject.totalClassCount <= 0) {
      return 0;
    }
    return subject.attendanceCount / subject.totalClassCount * 100;
  }
}