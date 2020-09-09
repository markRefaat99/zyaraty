import 'city.dart';

class Government {
  final int id;
  final String gov;
  final List<City> cities;
  Government({this.id = null, this.gov, this.cities = null});

  factory Government.fromJson(Map<String, dynamic> json, cities) {
    return Government(
      id: json['id'],
      gov: json['gov'],
      cities: cities,
    );
  }

  getCities() => cities;

  @override
  String toString() {
    return '$gov $id'.toLowerCase() + ' $gov $id'.toUpperCase();
  }
}
