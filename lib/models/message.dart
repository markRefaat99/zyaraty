import 'package:intl/intl.dart';

class Message {
  final int id;
  final String content;
  final int typesEnum;
  final String date;
  final bool read;
  Message({this.id, this.content, this.typesEnum, this.date, this.read});

  factory Message.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dateTime']);
    return Message(
      id: json['id'],
      content: json['content'],
      typesEnum: json['typesEnum'],
      date: DateFormat('dd/MM/yyyy hh:mm:ss a').format(dateTime),
      read: json['read'],
    );
  }
}
