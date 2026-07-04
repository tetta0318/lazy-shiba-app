import '../app_database.dart';
import '../models/schedule.dart';

class ScheduleRepository {
  ScheduleRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<int> createSchedule(Schedule schedule) async {
    return _database.insertRow(
      AppTable.schedules,
      schedule.toMap()..remove('id'),
    );
  }

  Future<List<Schedule>> getSchedules() async {
    final maps = await _database.getRows(
      AppTable.schedules,
      orderBy: 'date ASC',
    );
    return maps.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return getSchedulesByDateRange(
      from: start,
      to: end,
    );
  }

  Future<List<Schedule>> getSchedulesByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final maps = await _database.getRows(
      AppTable.schedules,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        from.toIso8601String(),
        to.toIso8601String(),
      ],
      orderBy: 'date ASC',
    );

    return maps.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getSchedulesByGenre(String genre) async {
    final maps = await _database.getRows(
      AppTable.schedules,
      where: 'genre = ?',
      whereArgs: [genre],
      orderBy: 'date ASC',
    );

    return maps.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getUpcomingSchedules({
    int limit = 5,
    DateTime? from,
  }) async {
    final maps = await _database.getRows(
      AppTable.schedules,
      where: 'date >= ?',
      whereArgs: [
        (from ?? DateTime.now()).toIso8601String(),
      ],
      orderBy: 'date ASC',
      limit: limit,
    );

    return maps.map(Schedule.fromMap).toList();
  }

  Future<Schedule?> getScheduleById(int id) async {
    final map = await _database.getRowById(
      AppTable.schedules,
      id,
    );
    if (map == null) {
      return null;
    }
    return Schedule.fromMap(map);
  }

  Future<int> updateSchedule(Schedule schedule) async {
    if (schedule.id == null) {
      throw ArgumentError('更新するScheduleにはidが必要です');
    }
    return _database.updateRow(
      AppTable.schedules,
      schedule.id!,
      schedule.toMap()..remove('id'),
    );
  }

  Future<int> deleteSchedule(int id) async {
    return _database.deleteRow(
      AppTable.schedules,
      id,
    );
  }
}
