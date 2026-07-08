import '../app_database.dart';
import '../models/subject.dart';

class SubjectRepository {
  SubjectRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createSubject(Subject subject) async {
    final values = subject.toMap();
    if (subject.id == null) {
      values.remove('id');
    }

    return _database.insertRow(
      AppTable.subjects,
      values,
    );
  }

  Future<List<Subject>> getSubjects() async {
    final maps = await _database.getRows(
      AppTable.subjects,
      orderBy: 'subject_name ASC',
    );
    return maps.map(Subject.fromMap).toList();
  }

  Future<Subject?> getSubjectById(int id) async {
    final map = await _database.getRowById(
      AppTable.subjects,
      id,
    );
    if (map == null) {
      return null;
    }
    return Subject.fromMap(map);
  }

  Future<Subject?> getSubjectByName(String subjectName) async {
    final maps = await _database.getRows(
      AppTable.subjects,
      where: 'subject_name = ?',
      whereArgs: [subjectName],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Subject.fromMap(maps.first);
  }

  Future<int> findOrCreateSubject({
    required String subjectName,
    bool isOnline = false,
    int attendanceCount = 0,
    int totalClassCount = 0,
    int? dayOfWeek,
    int? period,
  }) async {
    final existingSubject = await getSubjectByName(subjectName);
    if (existingSubject?.id != null) {
      return existingSubject!.id!;
    }

    final now = DateTime.now();
    return createSubject(
      Subject(
        subjectName: subjectName,
        isOnline: isOnline,
        attendanceCount: attendanceCount,
        totalClassCount: totalClassCount,
        dayOfWeek: dayOfWeek,
        period: period,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> updateSubject(Subject subject) async {
    if (subject.id == null) {
      throw ArgumentError('更新するSubjectにはidが必要です');
    }
    return _database.updateRow(
      AppTable.subjects,
      subject.id!,
      subject.toMap()..remove('id'),
    );
  }

  Future<int> updateAttendanceCount({
    required int id,
    required int attendanceCount,
  }) async {
    return _database.updateRow(
      AppTable.subjects,
      id,
      {'attendance_count': attendanceCount},
    );
  }

  Future<int> updateTotalClassCount({
    required int id,
    required int totalClassCount,
  }) async {
    return _database.updateRow(
      AppTable.subjects,
      id,
      {'total_class_count': totalClassCount},
    );
  }

  Future<int> updateOnlineStatus({
    required int id,
    required bool isOnline,
  }) async {
    return _database.updateRow(
      AppTable.subjects,
      id,
      {'is_online': isOnline ? 1 : 0},
    );
  }

  Future<int> updateSchedule({
    required int id,
    int? dayOfWeek,
    int? period,
  }) async {
    return _database.updateRow(
      AppTable.subjects,
      id,
      {'day_of_week': dayOfWeek, 'period': period},
    );
  }

  Future<int> deleteSubject(int id) async {
    return _database.deleteRow(
      AppTable.subjects,
      id,
    );
  }
}
