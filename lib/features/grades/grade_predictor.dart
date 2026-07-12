import 'attendance_calculator.dart';
import 'subject_db_access.dart';

/// 科目1つ分の成績サマリ（DBには保存しない。表示のたびに計算する）。
///
/// 各値は、算出に使える材料が1つも無い場合はnullとする
/// （0点・0%と「まだ計算できない」を区別するため）。
class SubjectGradeSummary {
  final double? attendanceRate;
  final double? taskAverage;
  final double? overallScore;

  const SubjectGradeSummary({
    required this.attendanceRate,
    required this.taskAverage,
    required this.overallScore,
  });
}

/// 科目単位の成績予想と、全科目の予想GPA計算を担当する（処理層）。
/// DBアクセスはSubjectDbAccessに委譲し、出席率の算出（休講・未確認の除外など
/// 出席ドメイン固有の意味論）はAttendanceCalculatorに委譲する。
class GradePredictor {
  GradePredictor({
    SubjectDbAccess? subjectDbAccess,
    AttendanceCalculator? attendanceCalculator,
  })  : _subjectDbAccess = subjectDbAccess ?? SubjectDbAccess(),
        _attendanceCalculator = attendanceCalculator ??
            AttendanceCalculator(subjectDbAccess: subjectDbAccess);

  final SubjectDbAccess _subjectDbAccess;
  final AttendanceCalculator _attendanceCalculator;

  /// 成績予想を計算する。全課題（完了済みのみ）の手ごたえの単純平均と、
  /// 出席率の単純平均を成績予想とする。
  /// 片方の材料しか無い場合はその値を採用し、両方無い場合はnullとする。
  Future<SubjectGradeSummary> calculateSubjectGrade(
    String subjectName,
  ) async {
    final attendanceRate =
        await _attendanceCalculator.calculateAttendanceRate(subjectName);

    final tasks = await _subjectDbAccess.getTasksBySubjectName(subjectName);
    final completedTasks = tasks.where((t) => t.status == 1).toList();
    final taskAverage = completedTasks.isEmpty
        ? null
        : completedTasks.fold<int>(0, (sum, t) => sum + t.feeling) /
            completedTasks.length;

    double? overallScore;
    if (attendanceRate != null && taskAverage != null) {
      overallScore = (attendanceRate + taskAverage) / 2;
    } else {
      overallScore = attendanceRate ?? taskAverage;
    }

    return SubjectGradeSummary(
      attendanceRate: attendanceRate,
      taskAverage: taskAverage,
      overallScore: overallScore,
    );
  }

  /// 全科目の予想GPAを計算する。
  /// 科目ごとの成績予想(overallScore)をGP値(0〜4)に変換し、その単純平均を返す。
  /// overallScoreが算出できた科目が1つも無い場合はnull。
  Future<double?> calculateExpectedGpa() async {
    final overallScores = await _collectOverallScores();
    if (overallScores.isEmpty) {
      return null;
    }

    final gradePoints = overallScores.map(scoreToGradePoint);
    final total = gradePoints.reduce((a, b) => a + b);
    return total / overallScores.length;
  }

  /// 全科目の成績予想(overallScore, 0〜100)の単純平均を返す（GP変換はしない）。
  /// overallScoreが算出できた科目が1つも無い場合はnull。
  Future<double?> calculateAverageOverallScore() async {
    final overallScores = await _collectOverallScores();
    if (overallScores.isEmpty) {
      return null;
    }

    final total = overallScores.reduce((a, b) => a + b);
    return total / overallScores.length;
  }

  /// 全科目のoverallScoreを収集する（算出不能な科目はスキップする）。
  Future<List<double>> _collectOverallScores() async {
    final subjects = await _subjectDbAccess.getSubjects();

    final overallScores = <double>[];
    for (final subject in subjects) {
      final summary = await calculateSubjectGrade(subject.subjectName);
      final overallScore = summary.overallScore;
      if (overallScore == null) {
        continue;
      }
      overallScores.add(overallScore);
    }
    return overallScores;
  }

  /// 点数(0〜100)をGP値(0〜4)に変換する。
  /// 0-49:0, 50-59:1, 60-69:2, 70-79:3, 80-100:4。
  /// 事前の四捨五入は行わない（区間の下端を含む閾値比較のみ）。
  static int scoreToGradePoint(double score) {
    if (score >= 80) {
      return 4;
    }
    if (score >= 70) {
      return 3;
    }
    if (score >= 60) {
      return 2;
    }
    if (score >= 50) {
      return 1;
    }
    return 0;
  }
}