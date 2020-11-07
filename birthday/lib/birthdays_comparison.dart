import 'package:dataclass/dataclass.dart';

int compareBirthdays(Map x, Map y) {
  int diffTodayX =
      nextBirthday(extractDayMonth(x)).difference(DateTime.now()).inDays;
  int diffTodayY =
      nextBirthday(extractDayMonth(y)).difference(DateTime.now()).inDays;
  return diffTodayX - diffTodayY;
}

DayMonth extractDayMonth(Map<dynamic, dynamic> x) {
  String rawDateX = x.values.first;
  List<String> split = rawDateX.split('-');
  return DayMonth(day: int.parse(split.first), month: int.parse(split.last));
}

// Calculate the next birthday occurrence for a birthday. Is it this year or (if already passed) next year?
DateTime nextBirthday(DayMonth dayMonth) {
  final DateTime today = DateTime.now();
  if (dayMonth.month > today.month ||
      (dayMonth.month == today.month && dayMonth.day > today.day)) {
    //This year
    return new DateTime(today.year, dayMonth.month, dayMonth.day);
  }
  // Next year
  return new DateTime(today.year + 1, dayMonth.month, dayMonth.day);
}

@dataClass
class DayMonth {
  final int day;
  final int month;

  DayMonth({this.day, this.month});
}
