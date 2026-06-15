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