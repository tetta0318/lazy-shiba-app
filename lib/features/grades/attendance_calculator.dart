import '../../core/database/models/attendance.dart';
import '../../core/database/models/subject.dart';
import 'subject_db_access.dart';

/// 出席確認ダイアログで確認が必要な1コマ分の情報。
class PendingAttendanceCheck {
  final int subjectId;
  final String subjectName;
  final DateTime date;

  const PendingAttendanceCheck({
    required this.subjectId,
    required this.subjectName,
    required this.date,
  });
}

/// 出席情報の起動時同期・出席率計算を担当する
/// （M4-3 出席情報取得・計算処理に相当）。
/// DBアクセスはすべてSubjectDbAccessに委譲し、このクラスは
/// 列挙・差集合・振り分け・計算のロジックのみを持つ。
class AttendanceCalculator {
  AttendanceCalculator({SubjectDbAccess? subjectDbAccess})
      : _subjectDbAccess = subjectDbAccess ?? SubjectDbAccess();

  /// 要確認リストに含めるのは、直近何日以内のコマまでか。
  /// これより古いコマは「未確認」として自動記録し、確認を求めない
  /// （長期休暇明けにダイアログが溜まるのを防ぐ）。
  static const _confirmWithinDays = 7;

  final SubjectDbAccess _subjectDbAccess;

  /// 起動時同期。全科目について不足している出席レコードを補完し、
  /// ユーザー確認が必要なコマの一覧を返す。
  /// 休講日・8日以上前の未確認分はDBに自動記録され、以後は同じ結果を返さない
  /// （冪等）。[today]はテスト用に注入可能で、省略時はDateTime.now()。
  Future<List<PendingAttendanceCheck>> syncAttendanceRecords({
    DateTime? today,
  }) async {
    final normalizedToday = _dateOnly(today ?? DateTime.now());
    final subjects = await _subjectDbAccess.getSubjects();
    final cancellationDates = await _subjectDbAccess.getCancellationDates();

    final pending = <PendingAttendanceCheck>[];

    for (final subject in subjects) {
      if (subject.id == null) {
        continue;
      }

      final expectedDates =
          _enumerateExpectedClassDates(subject, normalizedToday);
      if (expectedDates.isEmpty) {
        continue;
      }

      final existingDates = (await _subjectDbAccess
              .getAttendancesBySubjectId(subject.id!))
          .map((a) => a.date)
          .toSet();

      for (final date in expectedDates) {
        if (existingDates.contains(date)) {
          continue;
        }

        if (cancellationDates.contains(date)) {
          await _subjectDbAccess.saveAttendance(
            subjectId: subject.id!,
            date: date,
            status: AttendanceStatus.cancelled,
          );
          continue;
        }

        final daysAgo = normalizedToday.difference(date).inDays;
        if (daysAgo >= _confirmWithinDays + 1) {
          await _subjectDbAccess.saveAttendance(
            subjectId: subject.id!,
            date: date,
            status: AttendanceStatus.unconfirmed,
          );
          continue;
        }

        pending.add(PendingAttendanceCheck(
          subjectId: subject.id!,
          subjectName: subject.subjectName,
          date: date,
        ));
      }
    }

    pending.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.subjectName.compareTo(b.subjectName);
    });

    return pending;
  }

  /// 出席確認ダイアログの回答を保存する。
  Future<void> saveAttendanceAnswer({
    required int subjectId,
    required DateTime date,
    required int status,
  }) {
    const answerableStatuses = {
      AttendanceStatus.absent,
      AttendanceStatus.present,
      AttendanceStatus.cancelled,
    };
    if (!answerableStatuses.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        '出席/欠席/休講のいずれかを指定してください。',
      );
    }

    return _subjectDbAccess.saveAttendance(
      subjectId: subjectId,
      date: date,
      status: status,
    );
  }

  /// 出席率（0〜100）を計算する。
  /// 分母は休講・未確認を除いたコマ数、分子は出席したコマ数。
  /// 分母が0（対象コマが無い）場合はnullを返す。
  Future<double?> calculateAttendanceRate(String subjectName) async {
    final attendances =
        await _subjectDbAccess.getAttendancesBySubjectName(subjectName);

    final countedAttendances = attendances.where((a) =>
        a.status != AttendanceStatus.cancelled &&
        a.status != AttendanceStatus.unconfirmed);
    final total = countedAttendances.length;
    if (total == 0) {
      return null;
    }

    final present = countedAttendances
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    return present / total * 100;
  }

  /// 科目の開講曜日・学期期間から「本来あるべきコマの日付一覧」を列挙する。
  /// day_of_week / term_start_date が未設定の科目は同期対象外（空リスト）。
  /// 上限は「昨日」まで（今日はまだ受講していない可能性があるため、
  /// スキップ不可のダイアログでの回答を強制しないようにする）。
  List<DateTime> _enumerateExpectedClassDates(
    Subject subject,
    DateTime today,
  ) {
    final dayOfWeek = subject.dayOfWeek;
    final termStartDate = subject.termStartDate;
    if (dayOfWeek == null || termStartDate == null) {
      return [];
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final termEndDate = subject.termEndDate;
    final upperBound = termEndDate != null && termEndDate.isBefore(yesterday)
        ? _dateOnly(termEndDate)
        : yesterday;

    final start = _dateOnly(termStartDate);
    if (upperBound.isBefore(start)) {
      return [];
    }

    final dates = <DateTime>[];
    var current = start.add(
      Duration(days: (dayOfWeek - start.weekday + 7) % 7),
    );
    while (!current.isAfter(upperBound)) {
      dates.add(current);
      current = current.add(const Duration(days: 7));
    }
    return dates;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}