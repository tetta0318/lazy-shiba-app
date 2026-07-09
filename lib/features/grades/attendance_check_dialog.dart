import 'package:flutter/material.dart';

import 'grade_main.dart';

const _weekdayLabels = ['月', '火', '水', '木', '金', '土', '日'];

/// 出席確認ダイアログ。未確認のコマを1件ずつ「出席/欠席/休講だった」で
/// 確認してもらう。ホーム画面(HomeScreen)表示時に[showIfNeeded]から呼び出す。
class AttendanceCheckDialog extends StatefulWidget {
  const AttendanceCheckDialog({
    super.key,
    required this.checks,
    this.gradeMain,
  });

  final List<PendingAttendanceCheck> checks;
  final GradeMain? gradeMain;

  /// 要確認リストを取得し、1件以上あればダイアログを表示する。
  /// 0件なら何もしない。
  static Future<void> showIfNeeded(
    BuildContext context, {
    GradeMain? gradeMain,
  }) async {
    final main = gradeMain ?? GradeMain();
    final checks = await main.loadPendingAttendanceChecks();
    if (checks.isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceCheckDialog(
        checks: checks,
        gradeMain: main,
      ),
    );
  }

  @override
  State<AttendanceCheckDialog> createState() => _AttendanceCheckDialogState();
}

class _AttendanceCheckDialogState extends State<AttendanceCheckDialog> {
  late final GradeMain _gradeMain = widget.gradeMain ?? GradeMain();
  int _currentIndex = 0;
  bool _isSaving = false;

  Future<void> _onAnswer(int status) async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });

    await _gradeMain.answerAttendanceCheck(
      check: widget.checks[_currentIndex],
      status: status,
    );

    if (!mounted) {
      return;
    }

    if (_currentIndex == widget.checks.length - 1) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentIndex++;
      _isSaving = false;
    });
  }

  String _formatDate(DateTime date) {
    final weekday = _weekdayLabels[date.weekday - 1];
    return '${date.month}月${date.day}日($weekday)';
  }

  @override
  Widget build(BuildContext context) {
    final check = widget.checks[_currentIndex];

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('出席確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(check.date)} ${check.subjectName}\n'
              'に出席しましたか？',
            ),
            const SizedBox(height: 12),
            Text(
              '残り ${_currentIndex + 1} / ${widget.checks.length} 件',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () => _onAnswer(AttendanceStatus.cancelled),
            child: const Text('休講だった'),
          ),
          TextButton(
            onPressed:
                _isSaving ? null : () => _onAnswer(AttendanceStatus.absent),
            child: const Text('欠席'),
          ),
          FilledButton(
            onPressed:
                _isSaving ? null : () => _onAnswer(AttendanceStatus.present),
            child: const Text('出席'),
          ),
        ],
      ),
    );
  }
}