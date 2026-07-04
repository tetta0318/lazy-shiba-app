import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/database/models/task.dart' as database_model;
import '../../core/database/repositories/task_repository.dart';
import '../../widgets/task_widget_service.dart';
import '../auth/login.dart';
import 'TasksScraping.dart';
import 'completion_report_screen.dart';
import 'task_model.dart';
import 'task_report_calculator.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const _hideCompletedAfter = Duration(days: 7);

  final TaskRepository _taskRepository = TaskRepository();
  final TaskReportCalculator _taskReportCalculator = TaskReportCalculator();
  final TasksScraping _tasksScraping = TasksScraping();
  final TaskWidgetService _taskWidgetService = TaskWidgetService();
  final List<TaskMock> _tasks = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskRepository.getTasks();
    if (!mounted) {
      return;
    }

    final now = DateTime.now();
    final visibleTasks = tasks.where((task) {
      if (task.status == 0) {
        return true;
      }
      final completedAt = task.completedAt;
      if (completedAt == null) {
        return true;
      }
      return now.difference(completedAt) < _hideCompletedAfter;
    });

    setState(() {
      _tasks
        ..clear()
        ..addAll(visibleTasks.map(_toTaskMock));
      _isLoading = false;
    });

    _syncTaskWidget();
  }

  Future<void> _syncTaskWidget() async {
    try {
      await _taskWidgetService.refresh();
    } catch (_) {
      // ウィジェット未配置や権限差異では失敗しても画面操作を止めない。
    }
  }

  TaskMock _toTaskMock(database_model.Task task) {
    return TaskMock(
      id: task.id?.toString() ?? '',
      name: task.taskName,
      deadline: _formatDeadline(task.deadline),
      complete: task.status != 0,
    );
  }

  Future<void> _onRefreshPressed() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _tasksScraping.syncWithScombz();
    } on SessionExpiredException {
      if (!mounted) return;
      await _showErrorDialog('セッションが切れました。再度ログインしてください。');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    } on DioException {
      if (!mounted) return;
      await _showErrorDialog('通信に失敗しました。ネットワーク接続を確認してください。');
    } catch (_) {
      if (!mounted) return;
      await _showErrorDialog('課題の取得に失敗しました。');
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }

    await _loadTasks();
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCheckTapped(TaskMock task) async {
    final taskId = int.tryParse(task.id);
    if (taskId == null) {
      return;
    }

    if (task.complete) {
      await _taskReportCalculator.revertCompletion(taskId: taskId);
      _loadTasks();
      return;
    }

    final reported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionReportScreen(taskId: taskId),
      ),
    );

    if (reported == true) {
      _loadTasks();
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final days = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (days == 0) {
      return '今日';
    }
    if (days > 0) {
      return 'あと$days日';
    }
    return '${days.abs()}日前';
  }

  @override
  Widget build(BuildContext context) {
    _tasks.sort((a, b) {
      if (a.complete == b.complete) return 0;
      return a.complete ? 1 : -1;
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '課題一覧',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isSyncing ? null : _onRefreshPressed,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('課題はありません。'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      color: task.complete
                          ? Colors.grey.shade200
                          : Colors.white,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _onCheckTapped(task),
                          child: task.complete
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.circle_outlined),
                        ),
                        title: Text(
                          '${index + 1}. ${task.name}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            decoration: task.complete
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.complete ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: task.complete
                            ? null
                            : Text(
                                task.deadline,
                                style: const TextStyle(fontSize: 14),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}