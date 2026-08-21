class DateKey {
  const DateKey._();

  static String today() => fromDate(DateTime.now());

  static String fromDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static List<DateTime> lastSevenDays([DateTime? anchor]) {
    final value = anchor ?? DateTime.now();
    final today = DateTime(value.year, value.month, value.day);
    return List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
  }

  static String shortWeekdayEs(DateTime date) {
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return names[date.weekday - 1];
  }
}
