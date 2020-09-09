class Doctor {
  final int id;
  final String fname;
  final String lname;
  final int speical;
  final String speicalName;
  final String cityName;
  Doctor(
      {this.id,
      this.fname,
      this.lname,
      this.speical,
      this.cityName,
      this.speicalName});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
        id: json['id'],
        fname: json['fName'],
        lname: json['lName'],
        speical: json['medicalSpecialized']['id'],
        speicalName: json['medicalSpecialized']['type'],
        cityName: json['adderMedicalRep']['cityDto']['cityName']);
  }
}
