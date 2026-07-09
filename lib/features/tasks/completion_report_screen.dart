import 'package:flutter/material.dart';

import 'task_main.dart';

class CompletionReportScreen extends StatefulWidget {
  final int taskId;

  const CompletionReportScreen({super.key, required this.taskId});

  @override
  State<CompletionReportScreen> createState() => _CompletionReportScreenState();
}

class _CompletionReportScreenState extends State<CompletionReportScreen> {
  final TaskMain _taskMain = TaskMain();
  double _satisfactionLevel = 55.0; // 初期値55%
  bool _isSubmitting = false;

  Future<void> _onConfirmPressed() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _taskMain.reportCompletion(
        taskId: widget.taskId,
        feeling: _satisfactionLevel.round(),
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
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送信に失敗しました。接続を確認してください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('完了報告', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '課題の出来具合（％）を入力してください',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),

            Slider(
              value: _satisfactionLevel,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: '${_satisfactionLevel.round()}%',
              onChanged: (double value) {
                setState(() {
                  _satisfactionLevel = value;
                });
              },
            ),

            Text(
              '${_satisfactionLevel.round()}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 16sp
            ),

            const SizedBox(height: 48),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: _isSubmitting ? null : _onConfirmPressed,
              child: const Text('確定', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
