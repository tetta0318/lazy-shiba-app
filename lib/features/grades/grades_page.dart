import 'package:flutter/material.dart';

import 'gpa_goal_page.dart';
import 'subject_detail_page.dart';
import 'model/gpa_data.dart';


class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  Widget build(BuildContext context) {
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
                const TableRow(
                  children: [
                    HeaderCell('時限'),
                    HeaderCell('月'),
                    HeaderCell('火'),
                    HeaderCell('水'),
                    HeaderCell('木'),
                    HeaderCell('金'),
                  ],
                ),

                TableRow(
                  children: [
                    periodCell('1限\n09:00\n10:40'),
                    emptyCell(),
                    emptyCell(),
                    emptyCell(),
                    emptyCell(),
                    emptyCell(),
                  ],
                ),

                TableRow(
                  children: [
                    periodCell('2限\n10:50\n12:30'),
                    emptyCell(),
                    subjectButton(context, 'ソフトウェア工学'),
                    emptyCell(),
                    subjectButton(context, '組込みシステム'),
                    emptyCell(),
                  ],
                ),

                TableRow(
                  children: [
                    periodCell('3限\n13:20\n15:00'),
                    subjectButton(
                      context,
                      'Java応用プログラミング',
                    ),
                    subjectButton(
                      context,
                      'ソフトウェア開発演習',
                    ),
                    subjectButton(
                      context,
                      '人工知能',
                    ),
                    subjectButton(
                      context,
                      'コンピュータビジョン',
                    ),
                    emptyCell(),
                  ],
                ),

                TableRow(
                  children: [
                    periodCell('4限\n15:10\n16:50'),
                    subjectButton(
                      context,
                      '人工知能プログラミング',
                    ),
                    subjectButton(
                      context,
                      'ソフトウェア開発演習',
                    ),
                    emptyCell(),
                    subjectButton(
                      context,
                      '集積回路工学',
                    ),
                    emptyCell(),
                  ],
                ),
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

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubjectDetailPage(
                        subjectName: '卒業研究1',
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '卒業研究1',
                    style: TextStyle(
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

Widget periodCell(String text) {
  return Container(
    height: 90,
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

Widget emptyCell() {
  return Container(
    height: 90,
    color: const Color(0xFFD7DCDC),
  );
}

Widget subjectButton(
  BuildContext context,
  String subject,
) {
  return Container(
    height: 90,
    padding: const EdgeInsets.all(4),
    color: const Color(0xFFD7DCDC),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailPage(
              subjectName: subject,
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
      ),
      child: Text(
        subject,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'sans-serif-cjk',
        ),
      ),
    ),
  );
}