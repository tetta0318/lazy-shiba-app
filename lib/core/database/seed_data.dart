import 'models/schedule.dart';
import 'models/task.dart';
import 'repositories/schedule_repository.dart';
import 'repositories/subject_repository.dart';
import 'repositories/task_repository.dart';

class SeedData {
  SeedData._();

  static final _subjectRepository = SubjectRepository();
  static final _taskRepository = TaskRepository();
  static final _scheduleRepository = ScheduleRepository();

  static Future<void> insertIfEmpty() async {
    await _seedSubjects();
    await _seedTasks();
    await _seedSchedules();
  }

  static Future<void> _seedSubjects() async {
    final subjects = await _subjectRepository.getSubjects();
    if (subjects.isNotEmpty) {
      return;
    }

    const seedSubjects = [
      '情報セキュリティ',
      'Java応用プログラミング（1Q）',
      '人工知能プログラミング（2Q）',
      'ソフトウェア工学',
      'ソフトウェア開発演習',
      '人工知能',
      'データ解析法',
      '組込みシステム',
    ];

    for (final subjectName in seedSubjects) {
      await _subjectRepository.findOrCreateSubject(
        subjectName: subjectName,
        attendanceCount: subjectName == '情報セキュリティ' ? 12 : 8,
        totalClassCount: 15,
        isOnline: subjectName == 'Java応用プログラミング（1Q）',
      );
    }
  }

  static Future<void> _seedTasks() async {
    final tasks = await _taskRepository.getTasks();
    if (tasks.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final reportSubjectId = await _subjectRepository.findOrCreateSubject(
      subjectName: '情報セキュリティ',
      attendanceCount: 12,
      totalClassCount: 15,
    );
    final javaSubjectId = await _subjectRepository.findOrCreateSubject(
      subjectName: 'Java応用プログラミング（1Q）',
      isOnline: true,
      attendanceCount: 10,
      totalClassCount: 15,
    );
    final aiSubjectId = await _subjectRepository.findOrCreateSubject(
      subjectName: '人工知能プログラミング（2Q）',
      attendanceCount: 8,
      totalClassCount: 15,
    );

    final seedTasks = [
      Task(
        subjectId: reportSubjectId,
        taskName: 'レポート課題２',
        deadline: now.add(const Duration(days: 7)),
        url: 'https://example.com/report',
        feeling: 3,
        status: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        subjectId: javaSubjectId,
        taskName: '課題（４）',
        deadline: now.add(const Duration(days: 3)),
        url: null,
        feeling: 2,
        status: 0,
        createdAt: now,
        updatedAt: now,
      ),
      Task(
        subjectId: aiSubjectId,
        taskName: '課題1 （事前課題）',
        deadline: now.add(const Duration(days: 14)),
        url: 'https://example.com/flutter',
        feeling: 4,
        status: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final task in seedTasks) {
      await _taskRepository.createTask(task);
    }
  }

  static Future<void> _seedSchedules() async {
    final schedules = await _scheduleRepository.getSchedules();
    if (schedules.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final seedSchedules = [
      ('2026-04-02', '入学式', '大学行事'),
      ('2026-04-14', '春学期授業開始', '授業'),
      ('2026-05-17', '大宮祭', '大学行事'),
      ('2026-06-23', '学生大会（休講）', '休講'),
      ('2026-07-29', 'TOEIC IP試験', '試験'),
      ('2026-08-21', '春学期成績公開', '成績'),
      ('2026-09-26', '秋学期授業開始', '授業'),
      ('2026-10-31', '芝浦祭', '大学行事'),
      ('2026-11-04', '創立記念日', '大学行事'),
      ('2026-11-21', '秋2ターム授業開始', '授業'),
      ('2027-01-26', 'TOEIC IP試験', '試験'),
      ('2027-02-12', '秋学期成績公開', '成績'),
      ('2027-03-18', '学位記授与式', '大学行事'),
    ];

    for (final (date, title, genre) in seedSchedules) {
      await _scheduleRepository.createSchedule(
        Schedule(
          date: DateTime.parse(date),
          title: title,
          genre: genre,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}
