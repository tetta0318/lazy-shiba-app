import 'package:flutter/material.dart';

import '../auth/login.dart';
import 'completion_report_screen.dart';
import 'task_main.dart';
import 'task_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskMain _taskMain = TaskMain();
  final List<TaskMock> _tasks = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final items = await _taskMain.loadVisibleTasks();
    if (!mounted) {
      return;
    }

    setState(() {
      _tasks
        ..clear()
        ..addAll(items.map(_toTaskMock));
      _isLoading = false;
    });

    await _taskMain.refreshHomeWidget();
  }

  TaskMock _toTaskMock(TaskListItem item) {
    return TaskMock(
      id: item.taskId.toString(),
      name: item.taskName,
      deadline: _formatDeadline(item.deadline),
      complete: item.isCompleted,
    );
  }

  Future<void> _onRefreshPressed() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _taskMain.syncWithScombz();
    } on SessionExpiredException {
      if (!mounted) return;
      await _showErrorDialog('セッションが切れました。再度ログインしてください。');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    } on TaskSyncNetworkException {
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
      await _taskMain.revertCompletion(taskId: taskId);
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