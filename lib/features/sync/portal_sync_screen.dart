import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🌟パッケージをインポート

import '../auth/login_webview_page.dart';
import '../auth/subject_scraping.dart';
import '../auth/task_scraping.dart';

class PortalSyncScreen extends StatefulWidget {
  const PortalSyncScreen({super.key});

  @override
  State<PortalSyncScreen> createState() => _PortalSyncScreenState();
}

class _PortalSyncScreenState extends State<PortalSyncScreen> {
  // 🌟【追加】学籍番号とパスワードを保持するためのコントローラー
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSyncing = false;
  bool _isObscure = true; // 🌟【追加】パスワードの非表示（目隠し）管理
  List<Assignment> _fetchedTasks = [];
  List<String> _fetchedSubjects = [];
  String _errorMessage = '';

  // 🌟【追加】画面が立ち上がった時に自動で実行される初期化処理
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // スマホに保存されたログイン情報を読み込む
  }

  // 🌟【追加】スマホの保存領域からデータを読み込んでTextFieldにセットする関数
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 'scombz_id' と 'scombz_password' という名前で保存された文字を取得（なければ空文字）
      final savedId = prefs.getString('scombz_id') ?? '';
      final savedPassword = prefs.getString('scombz_password') ?? '';

      if (mounted) {
        setState(() {
          // コントローラーの .text に直接代入すると、TextFieldに自動で文字が埋まります
          _idController.text = savedId;
          _passwordController.text = savedPassword;
        });
      }
    } catch (e) {
      print('データの読み込みに失敗しました: $e');
    }
  }

  // 🌟【追加】画面が閉じられるときにコントローラーを破棄してメモリを解放する
  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              padding: const EdgeInsets.all(16), // 余白を少し広げて綺麗に整えました
              child: Column(
                children: [
                  // 🌟【追加】学籍番号入力欄
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: '学籍番号 (ScombZ ID)',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // 🌟【追加】パスワード入力欄（目隠しボタン付き）
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    obscureText: _isObscure,
                  ),
                  const SizedBox(height: 16),

                  // 同期ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.sync),
                      label: const Text('学校ポータルと連携して更新', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _startSync,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // エラー表示エリア
                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 課題・科目の表示タブ
                  Expanded(
                    child: _fetchedTasks.isEmpty && _fetchedSubjects.isEmpty
                        ? const Center(
                            child: Text(
                              'データがありません。\n学籍番号とパスワードを入力して同期してください。',
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
    // 🌟【追加】空欄のままボタンを押した時のチェック処理
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '学籍番号とパスワードを入力してください。';
      });
      return;
    }

    // 🌟【追加】ボタンを押して同期するタイミングでも、最新のID/PWをスマホに上書き保存しておく
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scombz_id', _idController.text);
      await prefs.setString('scombz_password', _passwordController.text);
    } catch (e) {
      print('データの保存に失敗しました: $e');
    }

    // WebView画面を起動し、コントローラーから直でIDとパスワードを渡す
    final grabbedCookies = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => LoginWebviewPage(
          id: _idController.text,
          password: _passwordController.text,
        ),
      ),
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
      final tasksScraper = TaskScraping();
      tasksScraper.taskDio.options.headers['Cookie'] = grabbedCookies;
      await tasksScraper.getTasks();

      final subjectsScraper = SubjectsScraping();
      subjectsScraper.timetableDio.options.headers['Cookie'] = grabbedCookies;
      await subjectsScraper.getSubjectNames();

      if (!mounted) return;

      setState(() {
        _fetchedTasks = tasksScraper.assignmentList;
        _fetchedSubjects = subjectsScraper.subjectNames;
      });
    } catch (error) {
      if (!mounted) return;

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

  // 課題リストのビルダー
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
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              child: const Icon(Icons.assignment, size: 20),
            ),
            title: Text(
              task.taskName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('科目: ${task.subjectName}'),
                  const SizedBox(height: 2),
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
          ),
        );
      },
    );
  }

  // 履修科目リストのビルダー
  Widget _buildSubjectList() {
    if (_fetchedSubjects.isEmpty) {
      return const Center(child: Text('登録されている科目がありません。'));
    }

    return ListView.builder(
      itemCount: _fetchedSubjects.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.blue),
            title: Text(
              _fetchedSubjects[index],
              style: const TextStyle(fontSize: 14),
            ),
            dense: true,
          ),
        );
      },
    );
  }
}
