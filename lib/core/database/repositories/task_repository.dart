import '../app_database.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createTask(Task task) async {
    return _database.insertRow(
      AppTable.tasks,
      task.toMap()..remove('id'),
    );
  }

  Future<List<Task>> getTasks() async {
    final maps = await _database.getRows(
      AppTable.tasks,
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final map = await _database.getRowById(
      AppTable.tasks,
      id,
    );

    if (map == null) {
      return null;
    }

    return Task.fromMap(map);
  }

  Future<List<Task>> getTasksBySubjectId(int subjectId) async {
    final db = await _database.database;

    final maps = await db.query(
      AppTable.tasks,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  Future<int> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('更新するTaskにはidが必要です');
    }

    return _database.updateRow(
      AppTable.tasks,
      task.id!,
      task.toMap()..remove('id'),
    );
  }

  Future<int> updateTaskStatus({
    required int id,
    required int status,
  }) async {
    return _database.updateRow(
      AppTable.tasks,
      id,
      {
        'status': status,
      },
    );
  }

  Future<int> updateTaskFeeling({
    required int id,
    required int feeling,
  }) async {
    return _database.updateRow(
      AppTable.tasks,
      id,
      {
        'feeling': feeling,
      },
    );
  }

  Future<int> deleteTask(int id) async {
    return _database.deleteRow(
      AppTable.tasks,
      id,
    );
  }
}