import 'package:intl/intl.dart';

abstract final class DateFormatters {
  static String lastUpdated(DateTime? date) {
    if (date == null) {
      return 'Sin datos guardados';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
