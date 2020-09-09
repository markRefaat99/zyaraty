import 'package:intl/intl.dart';

class Comment {
  final int id;
  final bool type;
  final int repId;
  final String fname;
  final String lname;
  final String pictureURL;
  final String username;
  final String content;
  final int likesCount;
  final int dislikesCount;
  final bool isLiker;
  final bool isDisLiker;
  final bool isActive;
  final String date;
  Comment(
      {this.id,
      this.type,
      this.repId,
      this.fname,
      this.lname,
      this.pictureURL,
      this.username,
      this.content,
      this.likesCount,
      this.dislikesCount,
      this.isLiker,
      this.isDisLiker,
      this.isActive,
      this.date});

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dateTime']);
    return Comment(
      id: json['id'],
      type: json['typ'],
      repId: json['rep']['id'],
      fname: json['rep']['fName'],
      lname: json['rep']['lName'],
      pictureURL: json['rep']['profileUrl'],
      username: json['rep']['userName'],
      content: json['content'],
      likesCount: json['likes'],
      dislikesCount: json['disLikes'],
      isLiker: json['isLiker'],
      isDisLiker: json['isDisLiker'],
      isActive: json['isActive'],
      date: DateFormat('dd/MM/yyyy hh:mm:ss a').format(dateTime),
    );
  }
}
