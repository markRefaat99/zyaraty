import 'package:intl/intl.dart';

class Winner {
  final int competitionId;
  final String competitionType;
  final String dateTime;
  final int id;
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String username;

  Winner({
    this.competitionId,
    this.competitionType,
    this.dateTime,
    this.id,
    this.firstName,
    this.lastName,
    this.imageUrl,
    this.username,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dateTime']);
    return Winner(
      competitionId: json['competitionId'],
      competitionType: json['competitionType'],
      dateTime: DateFormat('dd-MM-yyyy').format(dateTime),
      id: json['hacker']['id'],
      firstName: json['hacker']['fName'],
      lastName: json['hacker']['lName'],
      imageUrl: json['hacker']['imageUrl'],
      username: json['hacker']['userName'],
    );
  }
}
