import 'package:flutter/material.dart';
import 'features/tasks/tasks_screen.dart'; // 作成した課題画面をインポート

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '成績管理アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TasksScreen(), // 最初の画面に指定
    );
  }
}