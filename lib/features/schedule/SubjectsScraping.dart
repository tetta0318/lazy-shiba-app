import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

import '../../core/database/repositories/subject_repository.dart';

class SubjectsScraping {
  SubjectsScraping({
    SubjectRepository? subjectRepository,
  }) : _subjectRepository = subjectRepository ?? SubjectRepository();

  final SubjectRepository _subjectRepository;
  // 通信を行うためにDioを追加
  final dio.Dio timetableDio = dio.Dio();
  // 抽出した科目名を格納するシンプルなリスト
  List<String> subjectNames = [];

  // 本番通信を行うため async 処理に変更
  Future<void> getSubjectNames() async {
    subjectNames.clear();

    try {
      print('【通信開始】ScombZの時間割ページを取得しています...');
      // 🚀 実際のScombZサーバーの時間割ページにアクセス
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

      // 🚀 【新規追加】解析した科目データをSQLiteデータベースに登録/同期する
      await _saveSubjectsToDatabase();

    } on dio.DioException catch (e) {
      print('❌ 時間割のHTTP通信に失敗しました: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ 時間割のパース処理中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 🚀 科目リストをSQLiteデータベースに保存・同期する内部メソッド
  Future<void> _saveSubjectsToDatabase() async {
    print('💾 科目データのデータベース同期を開始します...');

    for (final name in subjectNames) {
      final existingSubject = await _subjectRepository.getSubjectByName(name);

      if (existingSubject == null) {
        await _subjectRepository.findOrCreateSubject(subjectName: name);
        print(' ➕ 新しい科目を登録しました: $name');
      } else {
        print(' 🔄 科目はすでに登録済みです: $name');
      }
    }
    print('✨ すべての科目データの同期が完了しました！');
  }
}
