import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart' as dio;
import 'package:html/dom.dart' as html_dom;

import '../../core/database/models/subject.dart';
import '../../core/database/repositories/subject_repository.dart';

/// 時間割の1コマ分の情報。
/// dayOfWeek/period は固定コマがない科目（卒業研究など）では null になる。
/// termType は科目名の「(１Q)」「(２Q)」表記から判定したクォーター区分
/// （[SubjectTerm.q1]/[SubjectTerm.q2]）で、通期・前期/後期科目では
/// [SubjectTerm.full] になる。
class _TimetableEntry {
  _TimetableEntry({
    required this.subjectName,
    this.dayOfWeek,
    this.period,
    this.periodCount = 1,
    this.termType,
    this.termStartDate,
    this.termEndDate,
  });

  final String subjectName;
  final int? dayOfWeek;
  final int? period;

  /// [period] から連続して何コマ分を占有するか（2コマ連続授業なら2）。
  final int periodCount;
  final String? termType;
  final DateTime? termStartDate;
  final DateTime? termEndDate;
}

/// ページ上部の「前期:2026年04月01日 ～ 2026年09月30日」
/// 「１Q:2026年04月11日 ～ 2026年06月04日」のような表示から取得した期間。
class _TermRange {
  _TermRange({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
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

  // 科目名ごとの曜日・時限（同一曜日で連続するコマはperiodCountにまとめる）
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

      for (final entry in _mergeConsecutivePeriods(_parseTimetable(document)).values) {
        _entriesByName[entry.subjectName] = entry;
        subjectNames.add(entry.subjectName);
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
    final termRanges = _parseTermRanges(document);

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
          entries.add(_buildEntry(
            subjectName: name,
            dayOfWeek: dayOfWeek,
            period: period,
            termRanges: termRanges,
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
      entries.add(_buildEntry(subjectName: name, termRanges: termRanges));
    }

    return entries;
  }

  /// ScombZの時間割表は2コマ連続の授業を「同じ科目要素を各時限の行に
  /// 重複して埋め込む」形で表現している。そのため科目名ごとにグループ化し、
  /// 同じ曜日で連続する時限をひとつのエントリ（period=開始時限,
  /// periodCount=コマ数）にまとめる。
  Map<String, _TimetableEntry> _mergeConsecutivePeriods(
    List<_TimetableEntry> rawEntries,
  ) {
    final grouped = <String, List<_TimetableEntry>>{};
    for (final entry in rawEntries) {
      grouped.putIfAbsent(entry.subjectName, () => []).add(entry);
    }

    final merged = <String, _TimetableEntry>{};
    for (final entry in grouped.entries) {
      final occurrences = entry.value;
      final scheduled = occurrences
          .where((e) => e.dayOfWeek != null && e.period != null)
          .toList();

      if (scheduled.isEmpty) {
        merged[entry.key] = occurrences.first;
        continue;
      }

      final representative = scheduled.first;
      final periodsOnSameDay = scheduled
          .where((e) => e.dayOfWeek == representative.dayOfWeek)
          .map((e) => e.period!)
          .toSet()
          .toList()
        ..sort();

      merged[entry.key] = _TimetableEntry(
        subjectName: entry.key,
        dayOfWeek: representative.dayOfWeek,
        period: periodsOnSameDay.first,
        periodCount: periodsOnSameDay.length,
        termType: representative.termType,
        termStartDate: representative.termStartDate,
        termEndDate: representative.termEndDate,
      );
    }

    return merged;
  }

  /// 科目名の「(１Q)」「(２Q)」表記からクォーター区分を判定し、
  /// ページヘッダーで取得した期間情報と組み合わせてエントリを組み立てる。
  _TimetableEntry _buildEntry({
    required String subjectName,
    int? dayOfWeek,
    int? period,
    required Map<String, _TermRange> termRanges,
  }) {
    final termType = _parseTermTypeFromName(subjectName) ?? SubjectTerm.full;
    final range = termRanges[termType];

    return _TimetableEntry(
      subjectName: subjectName,
      dayOfWeek: dayOfWeek,
      period: period,
      termType: termType,
      termStartDate: range?.startDate,
      termEndDate: range?.endDate,
    );
  }

  /// "Java応用プログラミング(１Q)" のような科目名からクォーター区分を取り出す。
  /// 全角/半角の数字・括弧・Qのどちらにも対応する。該当しなければ null（通期扱い）。
  String? _parseTermTypeFromName(String subjectName) {
    final match = RegExp(
      r'[(（]\s*([12１２])\s*[QqＱｑ]\s*[)）]',
    ).firstMatch(subjectName);
    if (match == null) {
      return null;
    }
    return _normalizeDigits(match.group(1)!) == '1' ? SubjectTerm.q1 : SubjectTerm.q2;
  }

  /// "前期:2026年04月01日 ～ 2026年09月30日" や
  /// "１Q:2026年04月11日 ～ 2026年06月04日" のような表示から
  /// [SubjectTerm.full]/[SubjectTerm.q1]/[SubjectTerm.q2] ごとの期間を取り出す。
  Map<String, _TermRange> _parseTermRanges(html_dom.Document document) {
    final ranges = <String, _TermRange>{};

    for (final element in document.querySelectorAll('.selected-display-date')) {
      final text = element.text.trim();
      final colonIndex = text.indexOf(':');
      if (colonIndex == -1) {
        continue;
      }

      final label = _normalizeDigits(text.substring(0, colonIndex));
      final dateRangeParts = text.substring(colonIndex + 1).split('～');
      if (dateRangeParts.length != 2) {
        continue;
      }

      final startDate = _parseJapaneseDate(dateRangeParts[0]);
      final endDate = _parseJapaneseDate(dateRangeParts[1]);
      if (startDate == null || endDate == null) {
        continue;
      }

      final String termType;
      if (label.contains('1Q')) {
        termType = SubjectTerm.q1;
      } else if (label.contains('2Q')) {
        termType = SubjectTerm.q2;
      } else {
        termType = SubjectTerm.full;
      }

      ranges[termType] = _TermRange(startDate: startDate, endDate: endDate);
    }

    return ranges;
  }

  /// "2026年04月01日" のような表記を [DateTime] に変換する。
  DateTime? _parseJapaneseDate(String text) {
    final match = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日')
        .firstMatch(_normalizeDigits(text));
    if (match == null) {
      return null;
    }
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
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

      final periodCount = entry?.periodCount ?? 1;

      if (existingSubject == null) {
        await _subjectRepository.findOrCreateSubject(
          subjectName: name,
          dayOfWeek: entry?.dayOfWeek,
          period: entry?.period,
          periodCount: periodCount,
          termType: entry?.termType,
          termStartDate: entry?.termStartDate,
          termEndDate: entry?.termEndDate,
        );
        print(' ➕ 新しい科目を登録しました: $name');
      } else {
        final hasChanged = existingSubject.dayOfWeek != entry?.dayOfWeek ||
            existingSubject.period != entry?.period ||
            existingSubject.periodCount != periodCount ||
            existingSubject.termType != entry?.termType ||
            existingSubject.termStartDate != entry?.termStartDate ||
            existingSubject.termEndDate != entry?.termEndDate;

        if (existingSubject.id != null && hasChanged) {
          await _subjectRepository.updateSchedule(
            id: existingSubject.id!,
            dayOfWeek: entry?.dayOfWeek,
            period: entry?.period,
            periodCount: periodCount,
            termType: entry?.termType,
            termStartDate: entry?.termStartDate,
            termEndDate: entry?.termEndDate,
          );
        }
        print(' 🔄 科目はすでに登録済みです: $name');
      }
    }
    print('✨ すべての科目データの同期が完了しました！');
  }
}