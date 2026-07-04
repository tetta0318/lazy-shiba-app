import 'package:flutter/material.dart';

import '../../core/database/models/task.dart' as database_model;
import '../../core/database/repositories/task_repository.dart';
import 'completion_report_screen.dart';
import 'priority_setting_screen.dart';
import 'task_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final List<TaskMock> _tasks = [];
  bool _isLoading = true;

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

    setState(() {
      _tasks
        ..clear()
        ..addAll(tasks.map(_toTaskMock));
      _isLoading = false;
    });
  }

  TaskMock _toTaskMock(database_model.Task task) {
    return TaskMock(
      id: task.id?.toString() ?? '',
      name: task.taskName,
      deadline: _formatDeadline(task.deadline),
      complete: task.status != 0,
    );
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrioritySettingScreen(tasks: _tasks),
                  ),
                ).then((updatedList) {
                  if (updatedList != null) {
                    setState(() {
                      _tasks
                        ..clear()
                        ..addAll(updatedList);
                    });
                  }
                });
              },
              child: const Text(
                '優先度の変更',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
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
                              leading: task.complete
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : const Icon(Icons.circle_outlined),
                              title: Text(
                                '${index + 1}. ${task.name}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  decoration: task.complete
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color:
                                      task.complete ? Colors.grey : Colors.black,
                                ),
                              ),
                              trailing: task.complete
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CompletionReportScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        '完了報告する',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                  : Text(
                                      task.deadline,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
