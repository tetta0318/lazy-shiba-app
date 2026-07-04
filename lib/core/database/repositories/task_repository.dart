import '../app_database.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  //taskオブジェクトをdatabaseに追加
  Future<int> createTask(Task task) async {
    final values = task.toMap();
    if (task.id == null) {
      values.remove('id');
    }

    return _database.insertRow(
      AppTable.tasks,
      values,
    );
  }

  //taskオブジェクトのリストとしてすべてのタスクを返す
  Future<List<Task>> getTasks() async {
    final maps = await _database.getRows(
      AppTable.tasks,
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  //idからタスクオブジェクトとしてタスクを返す
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

  //科目idからtaskオブジェクトのリストとしてタスクを返す
  Future<List<Task>> getTasksBySubjectId(int subjectId) async {
    final maps = await _database.getRows(
      AppTable.tasks,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getTasksByStatus(int status) async {
    final maps = await _database.getRows(
      AppTable.tasks,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getTasksByDeadlineRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final maps = await _database.getRows(
      AppTable.tasks,
      where: 'deadline >= ? AND deadline <= ?',
      whereArgs: [
        from.toIso8601String(),
        to.toIso8601String(),
      ],
      orderBy: 'deadline ASC',
    );

    return maps.map(Task.fromMap).toList();
  }

  Future<void> upsertTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('同期するTaskにはidが必要です');
    }

    final existingTask = await getTaskById(task.id!);
    if (existingTask == null) {
      await createTask(task);
      return;
    }

    await updateTask(task);
  }

  //idをもとにタスクを更新
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

  //idからtaskのstatusを更新する
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

  //idからtaskの手ごたえを更新
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

  Future<int> reportTaskCompletion({
    required int id,
    required int feeling,
  }) async {
    return _database.updateRow(
      AppTable.tasks,
      id,
      {
        'status': 1,
        'feeling': feeling,
      },
    );
  }

  //idからタスクを削除
  Future<int> deleteTask(int id) async {
    return _database.deleteRow(
      AppTable.tasks,
      id,
    );
  }
}
