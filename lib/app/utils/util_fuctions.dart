import 'package:intl/intl.dart';

String getCurrentDateAsString() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy.MM.dd'); // You can change the format as needed
  final String formattedDate = formatter.format(now);
  return formattedDate;
}