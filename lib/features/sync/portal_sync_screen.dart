import 'package:flutter/material.dart';

import '../auth/LoginWebviewPage.dart';
import '../schedule/SubjectsScraping.dart';
import '../tasks/TasksScraping.dart';

class PortalSyncScreen extends StatefulWidget {
  const PortalSyncScreen({super.key});

  @override
  State<PortalSyncScreen> createState() => _PortalSyncScreenState();
}

class _PortalSyncScreenState extends State<PortalSyncScreen> {
  bool _isSyncing = false;
  List<Assignment> _fetchedTasks = [];
  List<String> _fetchedSubjects = [];
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学校ポータル同期'),
        centerTitle: true,
      ),
      body: _isSyncing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '学校ポータルからデータを取得中...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.sync),
                      label: const Text('学校ポータルと連携して更新'),
                      onPressed: _startSync,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  Expanded(
                    child: _fetchedTasks.isEmpty && _fetchedSubjects.isEmpty
                        ? const Center(
                            child: Text(
                              'データがありません。\n上のボタンからログインして同期してください。',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                const TabBar(
                                  tabs: [
                                    Tab(text: '未提出課題'),
                                    Tab(text: '履修科目一覧'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildTaskList(),
                                      _buildSubjectList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _startSync() async {
    final grabbedCookies = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LoginWebviewPage()),
    );

    if (grabbedCookies == null || grabbedCookies.isEmpty) {
      setState(() {
        _errorMessage = '連携がキャンセルされました。';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _errorMessage = '';
    });

    try {
      final tasksScraper = TasksScraping();
      tasksScraper.taskDio.options.headers['Cookie'] = grabbedCookies;
      await tasksScraper.getTasks();

      final subjectsScraper = SubjectsScraping();
      subjectsScraper.timetableDio.options.headers['Cookie'] = grabbedCookies;
      await subjectsScraper.getSubjectNames();

      if (!mounted) {
        return;
      }

      setState(() {
        _fetchedTasks = tasksScraper.assignmentList;
        _fetchedSubjects = subjectsScraper.subjectNames;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = '同期中にエラーが発生しました: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Widget _buildTaskList() {
    if (_fetchedTasks.isEmpty) {
      return const Center(child: Text('現在、未提出の課題はありません。'));
    }

    return ListView.builder(
      itemCount: _fetchedTasks.length,
      itemBuilder: (context, index) {
        final task = _fetchedTasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${task.taskId}'),
            ),
            title: Text(
              task.taskName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('科目: ${task.subjectName} (ID: ${task.subjectId})'),
                Text(
                  '締切: ${task.deadline}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectList() {
    if (_fetchedSubjects.isEmpty) {
      return const Center(child: Text('登録されている科目がありません。'));
    }

    return ListView.builder(
      itemCount: _fetchedSubjects.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.book, color: Colors.blue),
          title: Text(_fetchedSubjects[index]),
          dense: true,
        );
      },
    );
  }
}
