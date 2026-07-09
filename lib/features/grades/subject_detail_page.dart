import 'package:flutter/material.dart';

import 'grade_main.dart';
import 'model/subject_data.dart';
import 'subject_db_access.dart';
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
  final SubjectDbAccess _subjectDbAccess = SubjectDbAccess();
  final GradeMain _gradeMain = GradeMain();
  double _attendanceRate = 0;
  bool _isLoadingAttendance = true;
  List<TaskGradeItem> _taskGrades = [];
  bool _isLoadingTaskGrades = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceRate();
    _loadTaskGrades();
  }

  Future<void> _loadAttendanceRate() async {
    final rate =
        await _subjectDbAccess.getAttendanceRate(widget.subjectName);
    if (!mounted) {
      return;
    }
    setState(() {
      _attendanceRate = rate;
      _isLoadingAttendance = false;
    });
  }

  Future<void> _loadTaskGrades() async {
    final taskGrades = await _gradeMain.loadTaskGrades(widget.subjectName);
    if (!mounted) {
      return;
    }
    setState(() {
      _taskGrades = taskGrades;
      _isLoadingTaskGrades = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 全体の成績はまだDBに保存先が無いため、
    // 引き続きインメモリのダミーデータ(SubjectStore)を使う。
    final subject = SubjectStore.getOrCreate(widget.subjectName);

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

            if (_isLoadingAttendance)
              const LinearProgressIndicator(minHeight: 20)
            else ...[
              LinearProgressIndicator(
                value: _attendanceRate / 100,
                minHeight: 20,
              ),

              const SizedBox(height: 10),

              Text(
                '出席率 '
                '${_attendanceRate.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily:
                      'sans-serif-cjk',
                ),
              ),
            ],

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

            if (_isLoadingTaskGrades)
              const LinearProgressIndicator(minHeight: 20)
            else if (_taskGrades.isEmpty)
              const Text(
                '課題はまだ登録されていません。',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'sans-serif-cjk',
                ),
              )
            else
              for (final taskGrade in _taskGrades)
                _taskGradeRow(taskGrade),

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

  Widget _taskGradeRow(TaskGradeItem taskGrade) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              taskGrade.taskName,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'sans-serif-cjk',
              ),
            ),
          ),
          Text(
            taskGrade.isCompleted
                ? '${taskGrade.feeling}%'
                : '未完了',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'sans-serif-cjk',
              color: taskGrade.isCompleted
                  ? Colors.black
                  : Colors.grey,
            ),
          ),
          if (taskGrade.isCompleted)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _onEditTaskGrade(taskGrade),
            ),
        ],
      ),
    );
  }

  Future<void> _onEditTaskGrade(TaskGradeItem taskGrade) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectGoalPage(
          subjectName: widget.subjectName,
          taskId: taskGrade.taskId,
          taskName: taskGrade.taskName,
          initialValue: taskGrade.feeling.toDouble(),
        ),
      ),
    );
    await _loadTaskGrades();
  }
}