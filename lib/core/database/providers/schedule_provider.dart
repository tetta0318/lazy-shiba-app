import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../repositories/schedule_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  ScheduleProvider({
    ScheduleRepository? repository,
  }) : _repository = repository ?? ScheduleRepository();

  final ScheduleRepository _repository;

  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  Future<void> loadSchedules() async {
    _schedules = await _repository.getSchedules();
    notifyListeners();
  }

  Future<void> createSchedule(Schedule schedule) async {
    await _repository.createSchedule(schedule);
    await loadSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    await _repository.updateSchedule(schedule);
    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await _repository.deleteSchedule(id);
    await loadSchedules();
  }
}