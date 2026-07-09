class SubjectData {
  final String subjectName;

  double attendanceRate;
  double totalScore;

  double assignment1;
  double assignment2;

  SubjectData({
    required this.subjectName,
    required this.attendanceRate,
    required this.totalScore,
    required this.assignment1,
    required this.assignment2,
  });
}

class SubjectStore {
  static final Map<String, SubjectData> subjects = {
    'ソフトウェア工学': SubjectData(
      subjectName: 'ソフトウェア工学',
      attendanceRate: 90,
      totalScore: 85,
      assignment1: 80,
      assignment2: 90,
    ),

    '組込みシステム': SubjectData(
      subjectName: '組込みシステム',
      attendanceRate: 95,
      totalScore: 88,
      assignment1: 85,
      assignment2: 90,
    ),

    'Java応用プログラミング': SubjectData(
      subjectName: 'Java応用プログラミング',
      attendanceRate: 92,
      totalScore: 87,
      assignment1: 88,
      assignment2: 86,
    ),

    'ソフトウェア開発演習': SubjectData(
      subjectName: 'ソフトウェア開発演習',
      attendanceRate: 98,
      totalScore: 94,
      assignment1: 95,
      assignment2: 93,
    ),

    '人工知能': SubjectData(
      subjectName: '人工知能',
      attendanceRate: 85,
      totalScore: 78,
      assignment1: 75,
      assignment2: 80,
    ),

    'コンピュータビジョン': SubjectData(
      subjectName: 'コンピュータビジョン',
      attendanceRate: 88,
      totalScore: 82,
      assignment1: 80,
      assignment2: 84,
    ),

    '人工知能プログラミング': SubjectData(
      subjectName: '人工知能プログラミング',
      attendanceRate: 91,
      totalScore: 89,
      assignment1: 90,
      assignment2: 88,
    ),

    '集積回路工学': SubjectData(
      subjectName: '集積回路工学',
      attendanceRate: 86,
      totalScore: 79,
      assignment1: 78,
      assignment2: 80,
    ),

    '卒業研究1': SubjectData(
      subjectName: '卒業研究1',
      attendanceRate: 100,
      totalScore: 95,
      assignment1: 95,
      assignment2: 95,
    ),
  };

  /// 既存のダミーデータがあればそれを返し、なければ
  /// [attendanceRate]（実際の出席率など）を初期値として新規登録する。
  /// これにより、上のリストにない科目（実DBから来た科目）でも
  /// 成績確認画面に遷移できるようになる。
  static SubjectData getOrCreate(
    String subjectName, {
    double attendanceRate = 0,
  }) {
    return subjects.putIfAbsent(
      subjectName,
      () => SubjectData(
        subjectName: subjectName,
        attendanceRate: attendanceRate,
        totalScore: 0,
        assignment1: 0,
        assignment2: 0,
      ),
    );
  }
}