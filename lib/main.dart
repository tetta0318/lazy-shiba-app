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
import 'package:flutter/material.dart';
import 'package:lazy_shiba_app/features/auth/authRepository.dart'; 

void main() async {
  // Flutterの初期化処理
  WidgetsFlutterBinding.ensureInitialized();

  print('=========================================');
  print('===      【単体テスト】認証処理      ===');
  print('=========================================\n');

  final authRepo = AuthRepository();

  // ⚠️ テストしたい実際の学籍番号（またはID）とパスワードに書き換えてください
  const String testUsername = 'al24010@sic.shibaura-it.ac.jp'; 
  const String testPassword = '12172826iI%'; 

  print('[$testUsername] でログインを試行します...');
  
  // 認証処理を実行
  bool isSuccess = await authRepo.login(
    username: testUsername,
    password: testPassword,
  );

  print('\n-----------------------------------------');
  if (isSuccess) {
    print('  🎉 ログイン成功！！ 🎉');
    print('  サーバーから正常なレスポンス（200 OK）が返ってきました。');
    print('  セッション（Cookie）が保持されています。');
  } else {
    print('  ❌ ログイン失敗 ❌');
    print('  ID/パスワードが違うか、URL・通信設定の調整が必要です。');
  }
  print('-----------------------------------------\n');

  print('=== 認証テスト終了 ===');
}


