import 'package:flutter/material.dart';

import '../../core/database/models/schedule.dart';
import '../../core/database/models/task.dart' as database_model;
import '../../core/database/repositories/schedule_repository.dart';
import '../../core/database/repositories/task_repository.dart';
import '../../widgets/widget_main.dart';
import '../grades/attendance_check_dialog.dart';
import '../grades/grade_main.dart';
import '../sync/portal_sync_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab, this.isActive = true});

  /// ボトムナビゲーションのタブを切り替えるためのコールバック。
  /// 課題タブ = 1, 成績タブ = 2, 予定タブ = 3
  final void Function(int index)? onNavigateToTab;

  /// このタブが現在ボトムナビゲーションで選択中かどうか。
  /// falseからtrueに変わった瞬間（タブが表示された瞬間）に成績サマリを再計算する。
  final bool isActive;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final WidgetMain _widgetMain = WidgetMain();
  final GradeMain _gradeMain = GradeMain();

  List<database_model.Task> _tasks = [];
  List<Schedule> _schedules = [];
  double? _currentGpa;
  double? _averageOverallScore;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
    _loadGradeSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await AttendanceCheckDialog.showIfNeeded(context);
      if (!mounted) {
        return;
      }
      await _loadGradeSummary();
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 他タブで成績が変わっている可能性があるため、このタブが
    // 表示された瞬間（非選択→選択）に成績サマリを再計算する。
    if (!oldWidget.isActive && widget.isActive) {
      _loadGradeSummary();
    }
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

    await _widgetMain.refreshAllWidgets();
  }

  Future<void> _loadGradeSummary() async {
    final results = await Future.wait([
      _gradeMain.loadExpectedGpa(),
      _gradeMain.loadAverageOverallScore(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _currentGpa = results[0];
      _averageOverallScore = results[1];
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
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(2),
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
                          children: [
                            Column(
                              children: [
                                const Text(
                                  '現在のGPA',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatGpa(_currentGpa),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  '全体の成績',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatOverallScore(_averageOverallScore),
                                  style: const TextStyle(
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('一番近い休校日・予定'),
                    Card(
                      elevation: 2,
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_month,
                          color: Colors.orange,
                        ),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                    subtitle: Text(
                                      _formatDaysUntil(task.deadline),
                                    ),
                                  ),
                                  if (task != incompleteTasks.last)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                    ),
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
                    ).then((_) {
                      _loadSummaries();
                      _loadGradeSummary();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGpa(double? gpa) {
    return gpa != null ? gpa.toStringAsFixed(1) : '-';
  }

  String _formatOverallScore(double? score) {
    return score != null ? '${score.toStringAsFixed(0)}%' : '-';
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
