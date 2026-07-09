import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/seed_data.dart';
import 'features/auth/login.dart';
import 'features/grades/grade_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeedData.insertIfEmpty();
  await _syncAttendanceOnStartup();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lazy Shiba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff256f68)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

/// 起動時の出席データ同期（休講・8日以上前の未確認分をF4へ自動記録する）。
/// BuildContextが無い時点の処理のためダイアログは出さない。
/// 失敗してもアプリ起動を止めない（HomeScreen表示時に自己回復する）。
Future<void> _syncAttendanceOnStartup() async {
  try {
    await GradeMain().syncAttendanceOnStartup();
  } catch (error) {
    debugPrint('出席データの起動時同期に失敗しました: $error');
  }
}
