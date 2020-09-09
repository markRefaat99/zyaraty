class City {
  final int id;
  final String cityName;
  City({this.id = 0, this.cityName});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      cityName: json['cityName'],
    );
  }

  @override
  String toString() {
    return '$cityName $id'.toLowerCase() + ' $cityName $id'.toUpperCase();
  }
}
