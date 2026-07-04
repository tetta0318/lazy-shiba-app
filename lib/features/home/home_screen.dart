import 'package:flutter/material.dart';

import '../../core/database/models/schedule.dart';
import '../../core/database/models/task.dart' as database_model;
import '../../core/database/repositories/schedule_repository.dart';
import '../../core/database/repositories/task_repository.dart';
import '../sync/portal_sync_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  List<database_model.Task> _tasks = [];
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    final tasks = await _taskRepository.getTasks();
    final schedules = await _scheduleRepository.getSchedules();
    if (!mounted) {
      return;
    }

    setState(() {
      _tasks = tasks;
      _schedules = schedules;
    });
  }

  @override
  Widget build(BuildContext context) {
    final upcomingSchedule = _firstUpcomingSchedule();
    final incompleteTasks =
        _tasks.where((task) => task.status == 0).take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ホーム',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('全体の成績'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Column(
                        children: [
                          Text(
                            '現在のGPA',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '3.25',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '全体の成績',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '35%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('一番近い休校日・予定'),
              Card(
                elevation: 2,
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.orange),
                  title: Text(
                    upcomingSchedule?.title ?? '予定はありません',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    upcomingSchedule == null
                        ? '直近の予定は未登録です'
                        : _formatDaysUntil(upcomingSchedule.date),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('直近の未完了課題'),
              Card(
                elevation: 2,
                child: incompleteTasks.isEmpty
                    ? const ListTile(title: Text('未完了課題はありません。'))
                    : Column(
                        children: [
                          for (final task in incompleteTasks) ...[
                            ListTile(
                              leading: const Icon(
                                Icons.assignment,
                                color: Colors.red,
                              ),
                              title: Text(task.taskName),
                              subtitle: Text(_formatDaysUntil(task.deadline)),
                            ),
                            if (task != incompleteTasks.last)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('学校ポータルと同期'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PortalSyncScreen(),
                      ),
                    ).then((_) => _loadSummaries());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Schedule? _firstUpcomingSchedule() {
    final today = DateTime.now();
    for (final schedule in _schedules) {
      final date = schedule.date;
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (!dateOnly.isBefore(DateTime(today.year, today.month, today.day))) {
        return schedule;
      }
    }
    return null;
  }

  String _formatDaysUntil(DateTime date) {
    final today = DateTime.now();
    final days = DateTime(date.year, date.month, date.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    if (days == 0) {
      return '今日';
    }
    if (days > 0) {
      return 'あと$days日';
    }
    return '${days.abs()}日前';
  }
}
