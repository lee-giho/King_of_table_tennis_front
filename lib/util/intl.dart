import 'package:intl/intl.dart';

String formatDateTime(DateTime dt) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH시 mm분');
  return formatter.format(dt);
}

String formatSimpleDateTime(DateTime dt) {
  final hour = dt.hour;
  final minute = dt.minute;

  final isAm = hour < 12;
  final period = isAm 
    ? "오전"
    : "오후";
  
  final displayHour = hour == 0
    ? 12
    : hour > 12
      ? hour - 12
      : hour;

  return "$period $displayHour:${minute.toString().padLeft(2, '0')}";
}