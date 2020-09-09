import 'package:intl/intl.dart';

class NotificationModal {
  final int id;
  final String content;
  final int typesEnum;
  final String date;
  final bool read;
  NotificationModal(
      {this.id, this.content, this.typesEnum, this.date, this.read});

  factory NotificationModal.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dateTime']);
    return NotificationModal(
      id: json['id'],
      content: json['message'],
      typesEnum: json['typesEnum'],
      date: DateFormat('dd/MM/yyyy hh:mm:ss a').format(dateTime),
      read: json['read'],
    );
  }
}
