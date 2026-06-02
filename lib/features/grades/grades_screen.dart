import 'package:flutter/material.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  // 状態管理用の変数（実際のデータ取得ロジックに置き換えます）
  bool _isLoading = false;
  String? _errorMessage;
  
  // モックデータ（M4-1 成績管理メイン処理から取得する想定）
  final Map<String, String> _mockTimetable = {
    '月2': 'ソフトウェア工学',
    '火3': 'データベース',
    '木1': 'ネットワーク',
  };

  @override
  void initState() {
    super.initState();
    _fetchGradeData();
  }

  // データ取得のダミーメソッド（E1〜E4のエラー処理をここに組み込みます）
  Future<void> _fetchGradeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // APIリクエストをシミュレート
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // エラーテスト用: _errorMessage = "成績データの取得に失敗しました。";
    });
  }

  @override
  Widget build(BuildContext context) {
    // 日本語: sans-serif-cjk, 英数字: sans-serif の指定に沿うようテーマを適用
    return Scaffold(
      appBar: AppBar(
        title: const Text('成績'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _fetchGradeData,
              child: const Text('再読み込み', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildGpaSection(),
        const Divider(),
        Expanded(
          child: _buildTimetableSection(),
        ),
      ],
    );
  }

  // 上部のGPA表示セクション
  Widget _buildGpaSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'GPA: 予想 3.2 / 目標 3.5 / 累積 3.0',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              // W6 GPA目標設定画面への遷移
              debugPrint('W6 GPA目標設定画面へ遷移');
            },
            child: const Text(
              '詳細',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 中央の時間割表セクション（E4: 授業がない場合の処理も含む）
  Widget _buildTimetableSection() {
    if (_mockTimetable.isEmpty) {
      return const Center(
        child: Text('登録されている授業がありません。', style: TextStyle(fontSize: 16)),
      );
    }

    // 月〜金の1〜5限を想定したシンプルなグリッド表示
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text('時間割表', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 月・火・水・木・金
                childAspectRatio: 0.8,
              ),
              itemCount: 25, // 5日 x 5時限
              itemBuilder: (context, index) {
                final day = ['月', '火', '水', '木', '金'][index % 5];
                final period = (index ~/ 5) + 1;
                final cellKey = '$day$period';
                final subjectName = _mockTimetable[cellKey];

                return Card(
                  elevation: 1,
                  color: subjectName != null ? Colors.blue.shade50 : Colors.grey.shade100,
                  child: InkWell(
                    onTap: subjectName != null
                        ? () {
                            // W7 各授業の成績確認画面への遷移
                            debugPrint('W7 各授業の成績確認画面へ遷移: $subjectName');
                          }
                        : null,
                    child: Center(
                      child: Text(
                        subjectName ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // E3: 文字超過の省略表示(...)
                      ),
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