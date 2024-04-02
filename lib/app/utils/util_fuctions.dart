import 'package:intl/intl.dart';

String getCurrentDateAsString() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy.MM.dd');
  final String formattedDate = formatter.format(now);
  return formattedDate;
}

String getCurrentDateAndTimeAsString() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm:ss');
  final String formattedDate = formatter.format(now);
  return formattedDate;
}

String dateTimeToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy.MM.dd');
  final String formattedDate = formatter.format(dateTime);
  return formattedDate;
}