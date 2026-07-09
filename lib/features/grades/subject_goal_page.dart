import 'package:flutter/material.dart';
import 'grade_main.dart';

class SubjectGoalPage extends StatefulWidget {
  final String subjectName;
  final int taskId;
  final String taskName;
  final double initialValue;

  const SubjectGoalPage({
    super.key,
    required this.subjectName,
    required this.taskId,
    required this.taskName,
    required this.initialValue,
  });

  @override
  State<SubjectGoalPage> createState() =>
      _SubjectGoalPageState();
}

class _SubjectGoalPageState
    extends State<SubjectGoalPage> {
  final GradeMain _gradeMain = GradeMain();
  late double _value;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(0, 100);
  }

  Future<void> _onConfirmPressed() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _gradeMain.updateTaskFeeling(
        taskId: widget.taskId,
        value: _value,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade100,
        title: Text(
          widget.subjectName,
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
              widget.taskName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'sans-serif-cjk',
              ),
            ),

            const SizedBox(height: 20),

            // 現在の点数
            Text(
              '${_value.round()} %',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 入力欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Slider(
                value: _value,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_value.round()}',
                onChanged: (newValue) {
                  setState(() {
                    _value = newValue;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // 修正ボタン
            ElevatedButton(
              onPressed: _isSaving ? null : _onConfirmPressed,
              child: const Text('修正'),
            ),
          ],
        ),
      ),
    );
  }
}