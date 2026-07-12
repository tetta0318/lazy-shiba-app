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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 表示する画面のリスト。
    // IndexedStackは非表示のタブも生存させ続けるため、タブを切り替えても
    // 各画面のinitStateは再実行されない。そこで現在選択中かどうか(isActive)を
    // 渡し、成績集計を持つ画面は「表示された瞬間」に自身で再計算させる。
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToTab: _onItemTapped,
        isActive: _selectedIndex == 0,
      ), // 0
      const TasksScreen(), // 1
      GradesPage(isActive: _selectedIndex == 2), // 2
      const ScheduleScreen(), // 3
    ];

    return Scaffold(
      // IndexedStackを使うと、画面を切り替えても各タブの状態（スクロール位置や入力内容）が保持されます
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
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