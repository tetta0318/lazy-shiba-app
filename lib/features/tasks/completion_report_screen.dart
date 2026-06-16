import 'package:flutter/material.dart';

class CompletionReportScreen extends StatefulWidget {
  const CompletionReportScreen({super.key});

  @override
  State<CompletionReportScreen> createState() => _CompletionReportScreenState();
}

class _CompletionReportScreenState extends State<CompletionReportScreen> {
  double _satisfactionLevel = 55.0; // 初期値55%

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
              '課題の手応え（％）を入力してください',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            Slider(
              value: _satisfactionLevel,
              min: 1.0,
              max: 100.0,
              divisions: 99,
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
              onPressed: () {
                // TODO: 完了報告の送信処理 (M3-4)
                Navigator.pop(context);
              },
              child: const Text('確定', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}