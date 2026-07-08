import 'package:flutter/material.dart';

import '../../core/database/models/subject.dart';
import 'gpa_goal_page.dart';
import 'subject_db_access.dart';
import 'subject_detail_page.dart';
import 'model/gpa_data.dart';

// 曜日は Subject.dayOfWeek（DateTime.weekday と同じ表現）に合わせて月〜金のみ表示する。
const _weekdays = [1, 2, 3, 4, 5];
const _weekdayLabels = {1: '月', 2: '火', 3: '水', 4: '木', 5: '金'};
const _periodTimeLabels = {
  1: '09:00\n10:40',
  2: '10:50\n12:30',
  3: '13:20\n15:00',
  4: '15:10\n16:50',
};

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final SubjectDbAccess _subjectDbAccess = SubjectDbAccess();
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _subjectDbAccess.getSubjects();
    if (!mounted) {
      return;
    }
    setState(() {
      _subjects = subjects;
      _isLoading = false;
    });
  }

  // periodCountが2以上の科目（2コマ連続授業）は、開始コマだけでなく
  // 占有する全コマにマッチさせる。同じコマにQ1科目・Q2科目が両方
  // 登録されていることがあるため、その場合は両方とも返す
  // （呼び出し側で上下に分けて表示する）。
  List<Subject> _subjectsAt({required int dayOfWeek, required int period}) {
    return _subjects
        .where((s) =>
            s.dayOfWeek == dayOfWeek &&
            s.period != null &&
            period >= s.period! &&
            period < s.period! + s.periodCount)
        .toList();
  }

  List<Subject> get _unscheduledSubjects {
    return _subjects
        .where((s) => s.dayOfWeek == null || s.period == null)
        .toList();
  }

  String _periodLabel(int period) {
    final time = _periodTimeLabels[period];
    return time != null ? '$period限\n$time' : '$period限';
  }

  // 1コマに複数科目（Q1科目・Q2科目など）がある場合は上下に分けて表示する。
  // Table自体には高さを揃える仕組みを持たせず、行の高さを事前に計算して
  // 全セルに明示的に渡すことで、列ごとに高さがズレる崩れを防ぐ。
  Widget _timetableCell(
    BuildContext context,
    List<Subject> subjects,
    double height,
  ) {
    if (subjects.isEmpty) {
      return emptyCell(height: height);
    }
    return Container(
      height: height,
      color: const Color(0xFFD7DCDC),
      child: Column(
        children: [
          for (final subject in subjects)
            Expanded(child: subjectButton(context, subject)),
        ],
      ),
    );
  }

  TableRow _buildPeriodRow(BuildContext context, int period) {
    final subjectsByDay = {
      for (final day in _weekdays)
        day: _subjectsAt(dayOfWeek: day, period: period),
    };

    var maxSubjectsInRow = 1;
    for (final subjects in subjectsByDay.values) {
      if (subjects.length > maxSubjectsInRow) {
        maxSubjectsInRow = subjects.length;
      }
    }
    final rowHeight = 90.0 * maxSubjectsInRow;

    return TableRow(
      children: [
        periodCell(_periodLabel(period), height: rowHeight),
        for (final day in _weekdays)
          _timetableCell(context, subjectsByDay[day]!, rowHeight),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final periodsWithData =
        _subjects.map((s) => s.period).whereType<int>().toSet();
    final maxPeriod = periodsWithData.isEmpty
        ? 4
        : periodsWithData.reduce((a, b) => a > b ? a : b);
    final periods = List<int>.generate(
      maxPeriod < 4 ? 4 : maxPeriod,
      (i) => i + 1,
    );
    final unscheduledSubjects = _unscheduledSubjects;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade100,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'GPA: 予想${GpaData.expectedGpa}'
                ' / 目標${GpaData.targetGpa}'
                ' / 累積${GpaData.cumulativeGpa}',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'sans-serif',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GpaGoalPage(),
                  ),
                );

                setState(() {});
              },
              child: const Text(
                '詳細',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontFamily: 'sans-serif-cjk',
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
              ),
              columnWidths: const {
                0: FixedColumnWidth(80),
              },
              children: [
                TableRow(
                  children: [
                    const HeaderCell('時限'),
                    for (final day in _weekdays)
                      HeaderCell(_weekdayLabels[day]!),
                  ],
                ),
                for (final period in periods) _buildPeriodRow(context, period),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade300,
              child: const Text(
                'その他の授業',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'sans-serif-cjk',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (unscheduledSubjects.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'その他の授業はありません。',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'sans-serif-cjk',
                  ),
                ),
              )
            else
              for (final subject in unscheduledSubjects)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailPage(
                            subjectName: subject.subjectName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        subject.subjectName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'sans-serif-cjk',
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class HeaderCell extends StatelessWidget {
  final String text;

  const HeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: const Color(0xFFE8D3A3),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'sans-serif-cjk',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Widget periodCell(String text, {double height = 90}) {
  return Container(
    height: height,
    color: const Color(0xFFE6A39B),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'sans-serif',
        ),
      ),
    ),
  );
}

Widget emptyCell({double height = 90}) {
  return Container(
    height: height,
    color: const Color(0xFFD7DCDC),
  );
}

Widget subjectButton(
  BuildContext context,
  Subject subject,
) {
  return Container(
    padding: const EdgeInsets.all(4),
    color: const Color(0xFFD7DCDC),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailPage(
              subjectName: subject.subjectName,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        subject.subjectName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9,
          fontFamily: 'sans-serif-cjk',
        ),
      ),
    ),
  );
}