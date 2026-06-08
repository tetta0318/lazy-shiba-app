import 'package:flutter/material.dart';
import 'model/subject_data.dart';

class SubjectGoalPage extends StatefulWidget {
  final SubjectData subject;
  final int assignmentNumber;

  const SubjectGoalPage({
    super.key,
    required this.subject,
    required this.assignmentNumber,
  });

  @override
  State<SubjectGoalPage> createState() =>
      _SubjectGoalPageState();
}

class _SubjectGoalPageState
    extends State<SubjectGoalPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    final value = widget.assignmentNumber == 1
        ? widget.subject.assignment1
        : widget.subject.assignment2;

    controller = TextEditingController(
      text: value.toStringAsFixed(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade100,
        title: Text(
          subject.subjectName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'sans-serif-cjk',
          ),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 課題名
            Text(
              '課題${widget.assignmentNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 20),

            // 現在の点数
            Text(
              '${controller.text} %',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 入力欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '点数を入力',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 修正ボタン
            ElevatedButton(
              onPressed: () {
                final value =
                    double.tryParse(controller.text) ?? 0;

                if (widget.assignmentNumber == 1) {
                  subject.assignment1 = value;
                } else {
                  subject.assignment2 = value;
                }

                subject.totalScore =
                    (subject.assignment1 +
                            subject.assignment2) /
                        2;

                Navigator.pop(context);
              },
              child: const Text('修正'),
            ),
          ],
        ),
      ),
    );
  }
}