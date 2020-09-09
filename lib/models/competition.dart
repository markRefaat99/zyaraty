class Competition {
  final int id;
  final int ranking;
  final String firstName;
  final String lastName;
  final String gov;
  final String cityName;
  final int uniqueVisits;
  final int uniqueEvaluators;

  Competition({
    this.id,
    this.ranking,
    this.firstName,
    this.lastName,
    this.gov,
    this.cityName,
    this.uniqueVisits,
    this.uniqueEvaluators,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['Id'],
      ranking: json['Ranking'],
      firstName: json['FName'],
      lastName: json['LName'],
      gov: json['Gov'],
      cityName: json['CityName'],
      uniqueVisits: json['UniqueVisits'],
      uniqueEvaluators: json['UniqueEvaluators'],
    );
  }
}
