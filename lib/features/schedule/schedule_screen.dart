import 'package:flutter/material.dart';

import '../../core/database/models/schedule.dart';
import '../../core/database/repositories/schedule_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  List<Schedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await _scheduleRepository.getSchedules();
    if (!mounted) {
      return;
    }

    setState(() {
      _schedules = schedules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final upcomingSchedules = _schedules.where(_isUpcoming).take(5).toList();
    final nearestHoliday = _firstWhereOrNull(_schedules, _isUpcomingHoliday);
    final nearestTest = _firstWhereOrNull(_schedules, _isUpcomingTest);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '予定',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('直近の予定'),
                Card(
                  elevation: 2,
                  child: upcomingSchedules.isEmpty
                      ? const ListTile(title: Text('直近の予定はありません。'))
                      : Column(
                          children: [
                            for (final schedule in upcomingSchedules) ...[
                              _buildScheduleRow(
                                _formatDate(schedule.date),
                                schedule.title,
                              ),
                              if (schedule != upcomingSchedules.last)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('一番近い休校日'),
                Card(
                  elevation: 2,
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.event_busy, color: Colors.red),
                    title: Text(
                      nearestHoliday == null
                          ? '予定はありません'
                          : _formatDate(nearestHoliday.date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(nearestHoliday?.title ?? '休校予定は未登録です'),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('直近のテストまでの日数'),
                Card(
                  elevation: 2,
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.timer, color: Colors.orange),
                    title: Text(
                      nearestTest?.title ?? '試験予定はありません',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      nearestTest == null
                          ? '-'
                          : 'あと ${_daysUntil(nearestTest.date)} 日',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _isUpcoming(Schedule schedule) {
    final today = DateTime.now();
    final date = schedule.date;
    return DateTime(date.year, date.month, date.day).isAfter(
          DateTime(today.year, today.month, today.day)
              .subtract(const Duration(days: 1)),
        );
  }

  bool _isUpcomingHoliday(Schedule schedule) {
    return _isUpcoming(schedule) &&
        (schedule.genre.contains('休講') || schedule.title.contains('休'));
  }

  bool _isUpcomingTest(Schedule schedule) {
    return _isUpcoming(schedule) &&
        (schedule.genre.contains('試験') || schedule.title.contains('テスト'));
  }

  Schedule? _firstWhereOrNull(
    Iterable<Schedule> schedules,
    bool Function(Schedule schedule) test,
  ) {
    for (final schedule in schedules) {
      if (test(schedule)) {
        return schedule;
      }
    }
    return null;
  }

  int _daysUntil(DateTime date) {
    final today = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildScheduleRow(String period, String eventTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              period,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              eventTitle,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
