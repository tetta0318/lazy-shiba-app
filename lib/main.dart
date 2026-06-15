// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// // 課題のスクレイピングファイルをインポート
// import 'package:lazy_shiba_app/features/tasks/TasksScraping.dart'; 
// // スケジュール（科目名）のスクレイピングファイルをインポート（パスは環境に合わせてください）
// import 'package:lazy_shiba_app/features/schedule/SubjectsScraping.dart'; 

// void main() async {
//   // Flutterの初期化処理
//   WidgetsFlutterBinding.ensureInitialized();

//   print('=== スクレイピングテスト開始 ===\n');

//   // ==========================================
//   // 1. 課題（Tasks）のスクレイピング処理
//   // ==========================================
//   print('[1/2] 課題一覧を取得中...');
//   final tasksScraper = TasksScraping();
//   await tasksScraper.getTasks();

//   if (tasksScraper.assignmentList.isEmpty) {
//     print('   -> 課題は見つかりませんでした。\n');
//   } else {
//     print('   -> 取得成功！件数: ${tasksScraper.assignmentList.length}件');
    
//     for (final assignment in tasksScraper.assignmentList) {
//       print('-----------------------------------------');
//       print('【科目名】 ${assignment.subjectName}');
//       print('【課題名】 ${assignment.taskName}');
//       print('【締切日】 ${assignment.deadline}');
//       print('【URL】    ${assignment.submissionURL}');
//     }
//     print('-----------------------------------------\n');
//   }

//   // ==========================================
//   // 2. スケジュール（科目名）のスクレイピング処理
//   // ==========================================
//   print('[2/2] 時間割から科目名を取得中...');
//   final scheduleScraper = SubjectsScraping(); // あなたが作った時間割用のクラス
  
//   // もしメソッド名を「getSubjectNames」にしている場合はそちらを呼び出してください
//   scheduleScraper.getSubjectNames(); 

//   if (scheduleScraper.subjectNames.isEmpty) {
//     print('   -> 科目名は見つかりませんでした。\n');
//   } else {
//     print('   -> 取得成功！件数: ${scheduleScraper.subjectNames.length}件');
    
//     print('------------- 取得した科目名 -------------');
//     for (final subjectName in scheduleScraper.subjectNames) {
//       print('・ $subjectName');
//     }
//     print('-----------------------------------------\n');
//   }

//   print('=== スクレイピングテスト終了 ===');
// }import 'package:flutter/material.dart';
// 認証リポジトリだけをインポート
// import 'package:flutter/material.dart';
// // インポートパスはあなたのプロジェクトの配置に合わせて調整してください
// import 'package:lazy_shiba_app/features/auth/LoginWebviewPage.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String _cookieStatus = '未ログイン（学校ポータルと連携していません）';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Lazy Shiba App')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 現在のステータスを表示するテキスト
//               Text(
//                 _cookieStatus,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 32),
              
//               // ログイン画面を開くボタン
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//                 child: const Text('学校ポータルと連携（ログイン）'),
//                 onPressed: () async {
//                   // 1. WebViewログイン画面を開き、完了して戻ってくるのを待つ
//                   final String? grabbedCookies = await Navigator.push<String>(
//                     context,
//                     MaterialPageRoute(builder: (context) => const LoginWebviewPage()),
//                   );

//                   // 2. 戻ってきた結果の判定
//                   if (grabbedCookies == null || grabbedCookies.isEmpty) {
//                     print('【通知】ログインがキャンセルされたか、Cookieが取れませんでした。');
//                     setState(() {
//                       _cookieStatus = '❌ 連携に失敗、またはキャンセルされました。';
//                     });
//                     return;
//                   }

//                   // 3. 取得成功時の処理
//                   print('\n=========================================');
//                   print('🎉 【成功】Main画面がCookieを受け取りました！');
//                   print(grabbedCookies);
//                   print('=========================================\n');

//                   setState(() {
//                     _cookieStatus = '✅ 学校ポータルとの連携に成功しました！\n（Cookieを取得済）';
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
