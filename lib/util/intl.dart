import 'package:intl/intl.dart';

String formatDateTime(DateTime dt) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH시 mm분');
  return formatter.format(dt);
}