class User {
  final int id;
  final String fname;
  final String lname;
  final String pictureURL;
  final String workedOnCompany;
  final String email;
  final String phone;
  final String userName;
  final int cityID;
  final String cityName;
  final int medicalRepPositionID;
  final String medicalRepPositionTitle;
  final int visitsCount;
  final int likeCount;
  final int disLikeCount;
  final int uniqueUsers;
  User({
    this.id,
    this.fname,
    this.lname,
    this.pictureURL,
    this.workedOnCompany,
    this.email,
    this.phone,
    this.userName,
    this.cityID,
    this.cityName,
    this.medicalRepPositionID,
    this.medicalRepPositionTitle,
    this.visitsCount,
    this.likeCount,
    this.disLikeCount,
    this.uniqueUsers,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fName'],
      lname: json['lName'],
      pictureURL: json['profileUrl'],
      workedOnCompany: json['workedOnCompany'],
      email: json['email'],
      phone: json['phone'],
      userName: json['userName'],
      cityName: json['city']['cityName'],
      cityID: json['city']['id'],
      medicalRepPositionID: json['medicalRepPosition']['id'],
      medicalRepPositionTitle: json['medicalRepPosition']['title'],
      visitsCount: json['visitsCount'],
      likeCount: json['likeCount'],
      disLikeCount: json['disLikeCount'],
      uniqueUsers: json['uniqueUsers'],
    );
  }
}
