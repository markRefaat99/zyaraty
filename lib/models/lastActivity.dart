import 'package:intl/intl.dart';

class LastActivity {
  final int id;
  final bool type;
  final int repID;
  final String repFname;
  final String repLname;
  final String repProfileURL;
  final String repUsername;
  final String content;
  final int likesCount;
  final int dislikesCount;
  final bool isLiker;
  final bool isDisLiker;
  final bool isActive;
  final String date;
  final int docID;
  final String docFname;
  final String docLname;
  final String docCity;
  final String docAddingDate;
  final String dovMedicalSpecialized;
  final String docAdderMedicalRep;

  LastActivity({
    this.id,
    this.type,
    this.repID,
    this.repFname,
    this.repLname,
    this.repProfileURL,
    this.repUsername,
    this.content,
    this.likesCount,
    this.dislikesCount,
    this.isLiker,
    this.isDisLiker,
    this.isActive,
    this.date,
    this.docID,
    this.docFname,
    this.docLname,
    this.docCity,
    this.docAddingDate,
    this.dovMedicalSpecialized,
    this.docAdderMedicalRep,
  });

  factory LastActivity.fromJson(Map<String, dynamic> json) {
    DateTime dateTime = DateTime.parse(json['dateTime']);
    return LastActivity(
      id: json['id'],
      type: json['type'],
      repID: json['rep']['id'],
      repFname: json['rep']['fName'],
      repLname: json['rep']['lName'],
      repProfileURL: json['rep']['profileUrl'],
      repUsername: json['rep']['userName'],
      content: json['content'],
      likesCount: json['likes'],
      dislikesCount: json['disLikes'],
      isLiker: json['isLiker'],
      isDisLiker: json['isDisLiker'],
      docID: json['doctorDto']['id'],
      docFname: json['doctorDto']['fName'],
      docLname: json['doctorDto']['lName'],
      docCity: json['doctorDto']['city'],
      docAddingDate: json['doctorDto']['addingDate'],
      dovMedicalSpecialized: json['doctorDto']['medicalSpecialized'],
      docAdderMedicalRep: json['doctorDto']['adderMedicalRep'],
      isActive: json['isActive'],
      date: DateFormat('dd/MM/yyyy hh:mm:ss a').format(dateTime),
    );
  }
}
