import 'package:home_widget/home_widget.dart';

import '../core/database/models/schedule.dart';
import '../core/database/repositories/schedule_repository.dart';
import 'schedule_widget_config.dart';

/// 予定ウィジェット(W13)にDBの最新の予定・一番近い休校日を反映する。
class ScheduleWidgetService {
  ScheduleWidgetService({ScheduleRepository? scheduleRepository})
      : _scheduleRepository = scheduleRepository ?? ScheduleRepository();

  final ScheduleRepository _scheduleRepository;

  Future<void> refresh() async {
    final schedules = await _scheduleRepository.getSchedules();
    final today = _dateOnly(DateTime.now());

    final tomorrow = _firstInRange(
      schedules,
      today.add(const Duration(days: 1)),
      today.add(const Duration(days: 1)),
    );
    final week = _firstInRange(
      schedules,
      today.add(const Duration(days: 2)),
      today.add(const Duration(days: 7)),
    );
    final monthRangeStart = today.add(const Duration(days: 8));
    final monthRangeEnd = today.add(const Duration(days: 31));
    final month = _firstInRange(
      schedules,
      monthRangeStart,
      monthRangeEnd,
      where: _isTest,
    ) ??
        _firstInRange(schedules, monthRangeStart, monthRangeEnd);
    final nearestHoliday = _firstFrom(schedules, today, where: _isHoliday);

    await HomeWidget.saveWidgetData<String>(
      ScheduleWidgetConfig.tomorrowKey,
      tomorrow == null ? '明日　予定なし' : '明日　${tomorrow.title}',
    );
    await HomeWidget.saveWidgetData<String>(
      ScheduleWidgetConfig.weekKey,
      week == null ? '1週間　予定なし' : '1週間　${week.title}',
    );
    await HomeWidget.saveWidgetData<String>(
      ScheduleWidgetConfig.monthKey,
      month == null ? '1か月　予定なし' : '1か月　${month.title}',
    );
    await HomeWidget.saveWidgetData<String>(
      ScheduleWidgetConfig.nearestHolidayKey,
      nearestHoliday == null
          ? '一番近い休校日はありません'
          : '一番近い休校日　${_formatDate(nearestHoliday.date)} ${nearestHoliday.title}',
    );

    await HomeWidget.updateWidget(
      qualifiedAndroidName: ScheduleWidgetConfig.androidProviderName,
    );
  }

  Schedule? _firstInRange(
    List<Schedule> schedules,
    DateTime from,
    DateTime to, {
    bool Function(Schedule schedule)? where,
  }) {
    for (final schedule in schedules) {
      final date = _dateOnly(schedule.date);
      if (date.isBefore(from) || date.isAfter(to)) {
        continue;
      }
      if (where != null && !where(schedule)) {
        continue;
      }
      return schedule;
    }
    return null;
  }

  Schedule? _firstFrom(
    List<Schedule> schedules,
    DateTime from, {
    required bool Function(Schedule schedule) where,
  }) {
    for (final schedule in schedules) {
      if (_dateOnly(schedule.date).isBefore(from)) {
        continue;
      }
      if (where(schedule)) {
        return schedule;
      }
    }
    return null;
  }

  bool _isHoliday(Schedule schedule) {
    return schedule.genre.contains('休講') || schedule.title.contains('休');
  }

  bool _isTest(Schedule schedule) {
    return schedule.genre.contains('試験') || schedule.title.contains('テスト');
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}