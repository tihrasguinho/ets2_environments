extension DateTimeExtension on DateTime {
  String get ddmmyyyy => '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  String get hhmm => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
