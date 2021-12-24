import 'package:flutter/material.dart';

extension DateTimeExt on DateTime {
  int get daysFromNow => difference(DateTime.now()).inDays;

  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  bool isSameDate(DateTime otherDateTime) {
    return year == otherDateTime.year &&
        month == otherDateTime.month &&
        day == otherDateTime.day;
  }

  DateTime withTime(int hour, [int minutes = 0, int seconds = 0]) {
    return DateTime(year, month, day, hour, minutes, seconds, 0, 0);
  }
}

extension DateTimeRangeExt on DateTimeRange {
  bool isInRange(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
