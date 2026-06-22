import 'package:flutter/material.dart';
import 'task_model.dart';
import 'priority_setting_screen.dart';
import 'completion_report_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
 ////////////// // 設計書に基づいた初期ダミーデータ////////////////////////////////////
  final List<TaskMock> _tasks = [
    TaskMock(id: '1', name: 'システム要件定義書の提出', deadline: 'あと2日', complete: true),
    TaskMock(id: '2', name: '基本設計書レビュー課題', deadline: 'あと5日', complete: false),
    TaskMock(id: '3', name: 'プログラミング演習小テスト', deadline: 'あと7日', complete: false),
  ];
////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    _tasks.sort((a, b) {
      if (a.complete == b.complete) return 0; // 状態が同じならそのまま
      return a.complete ? 1 : -1;             // aが完了(true)ならリストの後ろに移動させる
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        
        title: const Text('課題一覧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        

        actions:[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: 同期処理 (M3-2)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 優先度変更画面への遷移ボタン
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrioritySettingScreen(tasks: _tasks),
                  ),
                ).then((updatedList) {
                  if (updatedList != null) {
                    setState(() {
                      _tasks.clear();
                      _tasks.addAll(updatedList);
                    });
                  }
                });
              },
              child: const Text('優先度の変更', style: TextStyle(fontSize: 14)),
            ),
          ),
          
          // 課題一覧リスト
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  // 完了(true)なら背景を少しグレーにする
                  color: task.complete ? Colors.grey.shade200 : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    // 左側にチェックアイコンを表示（完了なら緑のチェック、未完了なら空の丸）
                    leading: task.complete 
                        ? const Icon(Icons.check_circle, color: Colors.green) 
                        : const Icon(Icons.circle_outlined),
                    title: Text(
                      '${index + 1}. ${task.name}',
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w500,
                        // 完了(true)なら名前に取り消し線を引く、テキストをグレーにする
                        decoration: task.complete ? TextDecoration.lineThrough : null,
                        color: task.complete ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: task.complete
                      ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero, // ボタンを少しコンパクトにする
                        ),
                        onPressed: () {
                        // 完了報告画面へナビゲート
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CompletionReportScreen()),
                          );
                        },
                        child: const Text('完了報告する', style: TextStyle(fontSize: 12)),
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
