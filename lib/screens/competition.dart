import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/models/competition.dart';
import 'package:zyaraty/models/winner.dart';
import 'package:zyaraty/staticData.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

class CompetitionPage extends StatefulWidget {
  @override
  _CompetitionPageState createState() => _CompetitionPageState();
}

class _CompetitionPageState extends State<CompetitionPage> {
  var headerController = new TextEditingController();
  var bodyController = new TextEditingController();

  var allData;
  Future competitionMembersDaily;
  Future competitionMembersMonthly;
  int responseCodeDaily = 0;
  int responseCodeMonthly = 0;
  var jwt, jwtRefresh, payload;

  Widget memberWidget(index, Competition winner) {
    return Card(
      child: Container(
        color: winner.id == payload['id'] ? primaryColor2 : null,
        child: new ListTile(
          leading: new CircleAvatar(
            backgroundColor: index == 4 ? primaryColor1 : primaryColor2,
            child: new Text(
              winner.ranking.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: new Text(
            winner.firstName + " " + winner.lastName,
            style: TextStyle(color: index == 4 ? Colors.white : null),
          ),
          subtitle: new Text(
            winner.gov + ", " + winner.cityName,
            style: TextStyle(color: index == 4 ? Colors.white : null),
          ),
          trailing: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: new Text(
                  winner.uniqueVisits.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: index == 4 ? Colors.white : null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: new Text(
                  winner.uniqueEvaluators.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: index == 4 ? Colors.white : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Competition>> fetchcompetitionMembersDaily() async {
    List<Competition> _competitionMembers = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(URL + 'api/Competition/daily', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        responseCodeDaily = 200;
        list.forEach((winner) {
          _competitionMembers.add(Competition.fromJson(winner));
        });
      });
      return _competitionMembers;
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchcompetitionMembersDaily();
    } else if (response.statusCode == 400) {
      setState(() {
        responseCodeDaily = 400;
      });
    } else {
      throw Exception('Failed to load competitionMembers');
    }
  }

  Future<List<Competition>> fetchcompetitionMembersMonthly() async {
    List<Competition> _competitionMembers = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(URL + 'api/Competition/monthly', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        responseCodeMonthly = 200;
        list.forEach((winner) {
          _competitionMembers.add(Competition.fromJson(winner));
        });
      });
      return _competitionMembers;
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchcompetitionMembersMonthly();
    } else if (response.statusCode == 400) {
      setState(() {
        responseCodeMonthly = 400;
      });
    } else {
      throw Exception('Failed to load competitionMembers');
    }
  }

  @override
  void initState() {
    competitionMembersDaily = fetchcompetitionMembersDaily();
    competitionMembersMonthly = fetchcompetitionMembersMonthly();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TabBarView(
        children: [
          // DAILY PAGE
          RefreshIndicator(
            onRefresh: () {
              setState(() {
                competitionMembersDaily = fetchcompetitionMembersDaily();
              });
              return competitionMembersDaily;
            },
            color: primaryColor1,
            child: Column(
              children: [
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Terms And Conditions",
                      style: TextStyle(
                          color: primaryColor1,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  onTap: () {
                    Provider.of<MenuProvider>(context, listen: false)
                        .updateCurrentPage(5);
                  },
                ),
                responseCodeDaily == 200 ? headerWidget() : Container(),
                responseCodeDaily == 200
                    ? FutureBuilder<List<Competition>>(
                        future: competitionMembersDaily,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Competition>> snapshot) {
                          if (snapshot.hasData) {
                            return Expanded(
                              child: new ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  var winner = snapshot.data[index];
                                  return memberWidget(index, winner);
                                },
                              ),
                            );
                          } else {
                            return LoadingListPage();
                          }
                        },
                      )
                    : new Center(child: new Text("No Competition!")),
              ],
            ),
          ),

          // MONTHLY PAGE
          RefreshIndicator(
            onRefresh: () {
              setState(() {
                competitionMembersMonthly = fetchcompetitionMembersMonthly();
              });
              return competitionMembersMonthly;
            },
            color: primaryColor1,
            child: Column(
              children: [
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Terms And Conditions",
                      style: TextStyle(
                          color: primaryColor1,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  onTap: () {
                    Provider.of<MenuProvider>(context, listen: false)
                        .updateCurrentPage(5);
                  },
                ),
                responseCodeMonthly == 200 ? headerWidget() : Container(),
                responseCodeMonthly == 200
                    ? FutureBuilder<List<Competition>>(
                        future: competitionMembersMonthly,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Competition>> snapshot) {
                          if (snapshot.hasData) {
                            return Expanded(
                              child: new ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  var winner = snapshot.data[index];
                                  return memberWidget(index, winner);
                                },
                              ),
                            );
                          } else {
                            return LoadingListPage();
                          }
                        },
                      )
                    : Center(child: Text('No Competition!')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingListPage extends StatefulWidget {
  @override
  _LoadingListPageState createState() => _LoadingListPageState();
}

class _LoadingListPageState extends State<LoadingListPage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100.0,
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[400],
          enabled: true,
          child: ListView.builder(
            itemCount: 21,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Card(
                child: ListTile(
                  title: Text(""),
                  subtitle: Text(""),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget headerWidget() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text('Rank'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 35.0),
            child: Text('Name'),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: Text('Visits'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: Text('Evaluators'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
