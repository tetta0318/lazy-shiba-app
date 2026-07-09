import '../app_database.dart';
import '../models/attendance.dart';

class AttendanceRepository {
  AttendanceRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// 日付を「その日の00:00」に正規化する。
  /// (subject_id, date)のUNIQUE制約が文字列完全一致で効くため、
  /// 書き込み前には必ずこれを通す。
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<int> createAttendance(Attendance attendance) async {
    final values = attendance.toMap()..remove('id');
    values['date'] = normalizeDate(attendance.date).toIso8601String();

    return _database.insertRow(
      AppTable.attendances,
      values,
    );
  }

  /// 同一(subjectId, date)の行があればstatusのみ更新、なければ新規作成する。
  /// 起動時同期・ダイアログ回答のどちらもこのメソッドを唯一の書き込み口とする。
  Future<void> saveAttendance({
    required int subjectId,
    required DateTime date,
    required int status,
  }) async {
    final normalizedDate = normalizeDate(date);
    final existing = await getAttendanceByDate(
      subjectId: subjectId,
      date: normalizedDate,
    );

    if (existing == null) {
      final now = DateTime.now();
      await createAttendance(
        Attendance(
          subjectId: subjectId,
          date: normalizedDate,
          status: status,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return;
    }

    await updateAttendanceStatus(id: existing.id!, status: status);
  }

  Future<List<Attendance>> getAttendancesBySubjectId(int subjectId) async {
    final maps = await _database.getRows(
      AppTable.attendances,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'date ASC',
    );

    return maps.map(Attendance.fromMap).toList();
  }

  Future<Attendance?> getAttendanceByDate({
    required int subjectId,
    required DateTime date,
  }) async {
    final maps = await _database.getRows(
      AppTable.attendances,
      where: 'subject_id = ? AND date = ?',
      whereArgs: [subjectId, normalizeDate(date).toIso8601String()],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Attendance.fromMap(maps.first);
  }

  Future<Attendance?> getAttendanceById(int id) async {
    final map = await _database.getRowById(
      AppTable.attendances,
      id,
    );
    if (map == null) {
      return null;
    }
    return Attendance.fromMap(map);
  }

  Future<int> updateAttendanceStatus({
    required int id,
    required int status,
  }) async {
    return _database.updateRow(
      AppTable.attendances,
      id,
      {'status': status},
    );
  }

  Future<int> deleteAttendance(int id) async {
    return _database.deleteRow(
      AppTable.attendances,
      id,
    );
  }
}