import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;
import '../../core/database/models/subject.dart';
import '../../core/database/providers/subject_providers.dart';

class SubjectsScraping {
  // コンストラクタで SubjectProvider を受け取る設計に統合
  SubjectsScraping({required this.subjectProvider});

  final SubjectProvider subjectProvider;
  final dio.Dio timetableDio = dio.Dio();
  List<String> subjectNames = [];

  Future<void> getSubjectNames() async {
    subjectNames.clear();

    try {
      print('【通信開始】ScombZの時間割ページを取得しています...');
      final dio.Response response = await timetableDio.get('https://scombz.shibaura-it.ac.jp/lms/timetable');
      final String htmlString = response.data.toString();

      // HTMLをパース
      html_dom.Document document = html_parser.parse(htmlString);

      // 時間割のマス（ボタン）を全取得
      List<html_dom.Element> timetableElements = document.querySelectorAll('.timetable-course-top-btn');

      for (final html_dom.Element element in timetableElements) {
        String name = element.text.trim();
        if (name.isNotEmpty && !subjectNames.contains(name)) {
          subjectNames.add(name);
        }
      }

      print('🎉 【解析成功】時間割登録科目数: ${subjectNames.length} 件');

      // 🚀 Provider を使ってデータを保存・同期する
      await _saveSubjectsToDatabase();

    } on dio.DioException catch (e) {
      print('❌ 時間割のHTTP通信に失敗しました: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 時間割のパース処理中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 🚀 SubjectProvider を介してデータベースに保存・同期する
  Future<void> _saveSubjectsToDatabase() async {
    print('💾 科目データのデータベース同期を開始します...');

    // 1. まず現在の最新データをProviderから取得（ロード）しておく
    await subjectProvider.loadSubjects();
    
    // 2. 現在Provider（DB）が持っている科目名のリストを作る
    final List<String> existingNames = subjectProvider.subjects
        .map((subject) => subject.subjectName)
        .toList();

    for (final name in subjectNames) {
      if (!existingNames.contains(name)) {
        // 3. Subjectを作成する「前」に現在時刻を変数に入れる
        final now = DateTime.now(); 

        // 4. モデルの型（boolやDateTime）に合わせて正しくインスタンス化
        final newSubject = Subject(
          subjectName: name,
          isOnline: false,            // bool型に修正
          attendanceCount: 0,
          totalClassCount: 0,
          createdAt: now,             // 必須項目を追加
          updatedAt: now,             // 必須項目を追加
        );

        // 5. Provider経由でDBへ保存
        await subjectProvider.createSubject(newSubject);
        print(' ➕ 新しい科目を登録しました: $name');
      } else {
        print(' 🔄 科目はすでに登録済みです: $name');
      }
    }
    print('✨ すべての科目データの同期が完了しました！');
  }
}