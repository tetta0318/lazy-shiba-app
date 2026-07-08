import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

import '../../core/database/repositories/subject_repository.dart';

/// 時間割の1コマ分の情報。
/// dayOfWeek/period は固定コマがない科目（卒業研究など）では null になる。
class _TimetableEntry {
  _TimetableEntry({
    required this.subjectName,
    this.dayOfWeek,
    this.period,
  });

  final String subjectName;
  final int? dayOfWeek;
  final int? period;
}

class SubjectsScraping {
  SubjectsScraping({
    SubjectRepository? subjectRepository,
  }) : _subjectRepository = subjectRepository ?? SubjectRepository();

  final SubjectRepository _subjectRepository;
  // 通信を行うためにDioを追加
  final dio.Dio timetableDio = dio.Dio();
  // 抽出した科目名を格納するシンプルなリスト
  List<String> subjectNames = [];

  // 科目名ごとの曜日・時限（初出のコマを採用）
  final Map<String, _TimetableEntry> _entriesByName = {};

  // 本番通信を行うため async 処理に変更
  Future<void> getSubjectNames() async {
    subjectNames.clear();
    _entriesByName.clear();

    try {
      print('【通信開始】ScombZの時間割ページを取得しています...');
      // 🚀 実際のScombZサーバーの時間割ページにアクセス
      final dio.Response response = await timetableDio.get('https://scombz.shibaura-it.ac.jp/lms/timetable');
      final String htmlString = response.data.toString();

      // HTMLをパース
      html_dom.Document document = html_parser.parse(htmlString);

      for (final entry in _parseTimetable(document)) {
        if (!_entriesByName.containsKey(entry.subjectName)) {
          _entriesByName[entry.subjectName] = entry;
          subjectNames.add(entry.subjectName);
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

  /// 時間割表（曜日×時限の固定コマ）と、曜日時限不定の科目欄の両方を解析する。
  List<_TimetableEntry> _parseTimetable(html_dom.Document document) {
    final entries = <_TimetableEntry>[];

    for (final row in document.querySelectorAll('.div-table-data-row')) {
      final periodText = row.querySelector('.div-table-colomn-period')?.text.trim() ?? '';
      final period = _parsePeriod(periodText);

      for (final cell in row.querySelectorAll('.div-table-cell')) {
        final dayOfWeek = _parseDayOfWeek(cell.classes);

        for (final courseElement in cell.querySelectorAll('.timetable-course-top-btn')) {
          final name = courseElement.text.trim();
          if (name.isEmpty) {
            continue;
          }
          entries.add(_TimetableEntry(
            subjectName: name,
            dayOfWeek: dayOfWeek,
            period: period,
          ));
        }
      }
    }

    // 「その他（曜日時限不定など）」欄の科目は曜日・時限を持たない
    for (final courseElement in document.querySelectorAll('.timetable-other-course .timetable-course-top-btn')) {
      final name = courseElement.text.trim();
      if (name.isEmpty) {
        continue;
      }
      entries.add(_TimetableEntry(subjectName: name));
    }

    return entries;
  }

  /// "１限" のような表記から時限番号を取り出す（全角数字対応）。
  int? _parsePeriod(String text) {
    final normalized = _normalizeDigits(text.replaceAll('限', ''));
    return int.tryParse(normalized);
  }

  /// "3-yobicol" のようなクラス名から曜日番号を取り出す。
  /// DateTime.weekday と同じ表現（1: 月曜日 〜 7: 日曜日）。
  int? _parseDayOfWeek(Set<String> classes) {
    for (final className in classes) {
      final match = RegExp(r'^(\d+)-yobicol$').firstMatch(className);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    return null;
  }

  String _normalizeDigits(String input) {
    const fullWidthDigits = '０１２３４５６７８９';
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final index = fullWidthDigits.indexOf(char);
      buffer.write(index >= 0 ? index.toString() : char);
    }
    return buffer.toString();
  }

  /// 🚀 科目リストをSQLiteデータベースに保存・同期する内部メソッド
  Future<void> _saveSubjectsToDatabase() async {
    print('💾 科目データのデータベース同期を開始します...');

    for (final name in subjectNames) {
      final entry = _entriesByName[name];
      final existingSubject = await _subjectRepository.getSubjectByName(name);

      if (existingSubject == null) {
        await _subjectRepository.findOrCreateSubject(
          subjectName: name,
          dayOfWeek: entry?.dayOfWeek,
          period: entry?.period,
        );
        print(' ➕ 新しい科目を登録しました: $name');
      } else {
        if (existingSubject.id != null &&
            (existingSubject.dayOfWeek != entry?.dayOfWeek ||
                existingSubject.period != entry?.period)) {
          await _subjectRepository.updateSchedule(
            id: existingSubject.id!,
            dayOfWeek: entry?.dayOfWeek,
            period: entry?.period,
          );
        }
        print(' 🔄 科目はすでに登録済みです: $name');
      }
    }
    print('✨ すべての科目データの同期が完了しました！');
  }
}