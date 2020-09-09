class Specialization {
  final int id;
  final String type;
  Specialization({this.id = null, this.type});

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return '$type $id'.toLowerCase() + ' $type $id'.toUpperCase();
  }
}
