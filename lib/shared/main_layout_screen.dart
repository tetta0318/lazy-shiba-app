import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/grades/grades_page.dart';
import '../features/schedule/schedule_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  // 表示する画面のリスト
  final List<Widget> _screens = const [
    HomeScreen(),     // 0
    TasksScreen(),    // 1
    GradesPage(),     // 2
    ScheduleScreen(), // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStackを使うと、画面を切り替えても各タブの状態（スクロール位置や入力内容）が保持されます
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '課題'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '成績'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '予定'),
        ],
      ),
    );
  }
}