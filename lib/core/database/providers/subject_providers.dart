import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

class SubjectProvider extends ChangeNotifier {
  SubjectProvider({
    SubjectRepository? repository,
  }) : _repository = repository ?? SubjectRepository();

  final SubjectRepository _repository;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  Future<void> loadSubjects() async {
    _subjects = await _repository.getSubjects();
    notifyListeners();
  }

  Future<void> createSubject(Subject subject) async {
    await _repository.createSubject(subject);
    await loadSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await _repository.updateSubject(subject);
    await loadSubjects();
  }

  Future<void> updateAttendanceCount({
    required int id,
    required int attendanceCount,
  }) async {
    await _repository.updateAttendanceCount(
      id: id,
      attendanceCount: attendanceCount,
    );
    await loadSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _repository.deleteSubject(id);
    await loadSubjects();
  }
}