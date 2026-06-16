import 'package:flutter/material.dart';

import 'model/subject_data.dart';
import 'subject_goal_page.dart';

class SubjectDetailPage extends StatefulWidget {
  final String subjectName;

  const SubjectDetailPage({
    super.key,
    required this.subjectName,
  });

  @override
  State<SubjectDetailPage> createState() =>
      _SubjectDetailPageState();
}

class _SubjectDetailPageState
    extends State<SubjectDetailPage> {

  @override
  Widget build(BuildContext context) {

    final subject =
        SubjectStore.subjects[
            widget.subjectName]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.red.shade100,
        title: Text(
          subject.subjectName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily:
                'sans-serif-cjk',
          ),
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              '出席率',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value:
                  subject.attendanceRate /
                      100,
              minHeight: 20,
            ),

            const SizedBox(height: 10),

            Text(
              '出席率 '
              '${subject.attendanceRate.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              '課題成績予想',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 15),

            _assignmentRow(
              context,
              subject,
              1,
            ),

            _assignmentRow(
              context,
              subject,
              2,
            ),

            const SizedBox(height: 30),

            const Text(
              '全体の成績',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value:
                  subject.totalScore /
                      100,
              minHeight: 20,
            ),

            const SizedBox(height: 10),

            Text(
              '全体の成績 '
              '${subject.totalScore.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentRow(
    BuildContext context,
    SubjectData subject,
    int assignmentNumber,
  ) {

    final score =
        assignmentNumber == 1
            ? subject.assignment1
            : subject.assignment2;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              '課題$assignmentNumber '
              '${score.toStringAsFixed(0)}%',
              style:
                  const TextStyle(
                fontSize: 14,
                fontFamily:
                    'sans-serif-cjk',
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SubjectGoalPage(
                    subject: subject,
                    assignmentNumber:
                        assignmentNumber,
                  ),
                ),
              );

              setState(() {});
            },
            child: const Text(
              '修正',
            ),
          ),
        ],
      ),
    );
  }
}