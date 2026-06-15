import '../app_database.dart';
import '../models/subject.dart';

class SubjectRepository {
  SubjectRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createSubject(Subject subject) async {
    return _database.insertRow(
      AppTable.subjects,
      subject.toMap()..remove('id'),
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

  Future<int> deleteSubject(int id) async {
    return _database.deleteRow(
      AppTable.subjects,
      id,
    );
  }
}