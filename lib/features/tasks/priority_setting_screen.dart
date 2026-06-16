import 'package:flutter/material.dart';
import 'task_model.dart';

class PrioritySettingScreen extends StatefulWidget {
  final List<TaskMock> tasks;
  const PrioritySettingScreen({super.key, required this.tasks});

  @override
  State<PrioritySettingScreen> createState() => _PrioritySettingScreenState();
}

class _PrioritySettingScreenState extends State<PrioritySettingScreen> {
  late List<TaskMock> _localTasks;

  @override
  void initState() {
    super.initState();
    // 元のリストを汚さないように複製して利用
    _localTasks = List.from(widget.tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '優先度変更',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _localTasks.length,
              itemBuilder: (context, index) {
                final task = _localTasks[index];
                return Card(
                  key: ValueKey(task.id),
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(
                      task.name,
                      style: const TextStyle(fontSize: 16), // 課題名は16sp
                    ),
                    trailing: Text(
                      task.deadline,
                      style: const TextStyle(fontSize: 14), // 期限は14sp
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _localTasks.removeAt(oldIndex);
                  _localTasks.insert(newIndex, item);
                });
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () {
                // 変更後のリストを元の画面に戻す
                Navigator.pop(context, _localTasks);
              },
              child: const Text('変更を適応', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}