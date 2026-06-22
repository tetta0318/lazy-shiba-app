import 'package:flutter/material.dart';

import '../sync/portal_sync_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 全体の成績エリア（外部設計書の記述に準拠）
              _buildSectionTitle('全体の成績'),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
                          Text('現在のGPA', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('3.25', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: const [
                          Text('全体の成績', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('35%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. 一番近い予定・休校日エリア（外部設計書の記述に準拠）
              _buildSectionTitle('一番近い休校日・予定'),
              Card(
                elevation: 2,
                color: Colors.orange.shade50,
                child: const ListTile(
                  leading: Icon(Icons.calendar_month, color: Colors.orange),
                  title: Text('○○中間テスト', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('残り時間: 1か月'),
                ),
              ),
              const SizedBox(height: 24),

              // 3. 直近の課題サマリーエリア（外部・内部設計書の「課題名 あと○日」に準拠）
              _buildSectionTitle('直近の未完了課題'),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.red),
                      title: const Text('ソフトウェア開発演習 宿題1'),
                      subtitle: const Text('あと2日'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.orange),
                      title: const Text('アルゴリズムとデータ構造 レポート'),
                      subtitle: const Text('あと5日'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text('学校ポータルと同期'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PortalSyncScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // セクションのタイトルを見栄えよく表示するための共通Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
