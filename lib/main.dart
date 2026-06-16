import 'package:flutter/material.dart';

// 💡 ご自身のフォルダ構造（パッケージ名）に合わせてインポートパスを正しく調整してください
import 'package:lazy_shiba_app/features/auth/LoginWebviewPage.dart';
import 'package:lazy_shiba_app/features/tasks/TasksScraping.dart'; 
import 'package:lazy_shiba_app/features/schedule/SubjectsScraping.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSyncing = false;
  
  // 取得した生のデータをUIで使い回すために状態（変数）として保持する
  List<Assignment> _fetchedTasks = [];
  List<String> _fetchedSubjects = [];
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lazy Shiba App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isSyncing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '学校ポータルからデータを取得中...\nリアルタイムで解析しています。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // 連携・同期ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.sync),
                      label: const Text('学校ポータルと連携して最新データに更新'),
                      onPressed: _startSync,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.red)),

                  // 取得データの表示エリア
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
                                      // タブ1: 課題一覧表示
                                      _buildTaskList(),
                                      // タブ2: 科目名一覧表示
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

  // 🔄 同期処理のメインロジック
  Future<void> _startSync() async {
    final String? grabbedCookies = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const LoginWebviewPage()),
    );

    if (grabbedCookies == null || grabbedCookies.isEmpty) {
      setState(() {
        _errorMessage = '⚠️ 連携がキャンセルされました。';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _errorMessage = '';
    });

    try {
      // 1. 課題スクレイピング
      final tasksScraper = TasksScraping();
      tasksScraper.taskDio.options.headers['Cookie'] = grabbedCookies;
      await tasksScraper.getTasks();

      // 2. 科目名スクレイピング
      final subjectsScraper = SubjectsScraping();
      subjectsScraper.timetableDio.options.headers['Cookie'] = grabbedCookies;
      await subjectsScraper.getSubjectNames();

      // 3. 取得完了した中身をそのまま画面の変数に代入
      setState(() {
        _fetchedTasks = tasksScraper.assignmentList;
        _fetchedSubjects = subjectsScraper.subjectNames;
      });

    } catch (e) {
      setState(() {
        _errorMessage = '❌ 同期中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  // 📋 課題リストのUIを組み立てるメソッド
  Widget _buildTaskList() {
    if (_fetchedTasks.isEmpty) {
      return const Center(child: Text('現在、未提出の課題はありません。🎉'));
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
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              print('提出URL: ${task.submissionURL}');
            },
          ),
        );
      },
    );
  }

  // 📋 科目リストのUIを組み立てるメソッド
  Widget _buildSubjectList() {
    if (_fetchedSubjects.isEmpty) {
      return const Center(child: Text('登録されている科目がありません。'));
    }
    return ListView.builder(
      itemCount: _fetchedSubjects.length,
      itemBuilder: (context, index) {
        final subjectName = _fetchedSubjects[index];
        return ListTile(
          leading: const Icon(Icons.book, color: Colors.blue),
          title: Text(subjectName),
          dense: true,
        );
      },
    );
  }
}
