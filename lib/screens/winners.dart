import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/models/winner.dart';
import 'package:zyaraty/staticData.dart';
import 'package:shimmer/shimmer.dart';

class WinnersPage extends StatefulWidget {
  @override
  _WinnersPageState createState() => _WinnersPageState();
}

class _WinnersPageState extends State<WinnersPage> {
  Future winnersDaily;
  Future winnersMonthly;
  int responseCodeDaily = 0;
  int responseCodeMonthly = 0;
  var jwt, jwtRefresh, payload;
  Future<List<Winner>> fetchWinnersDaily() async {
    List<Winner> _winners = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response =
        await http.get(URL + 'api/Competition/gethackers/daily/6', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      if (list.length == 0) {
        setState(() {
          responseCodeDaily = 400;
        });
      } else {
        setState(() {
          list.forEach((winner) {
            _winners.add(Winner.fromJson(winner));
          });
          responseCodeDaily = 200;
        });
        return _winners;
      }
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchWinnersDaily();
    } else if (response.statusCode == 400) {
      setState(() {
        responseCodeDaily = 400;
      });
    } else {
      throw Exception('Failed to load winners');
    }
  }

  Future<List<Winner>> fetchWinnersMonthly() async {
    List<Winner> _winners = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response =
        await http.get(URL + 'api/Competition/gethackers/monthly/6', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      if (list.length == 0) {
        setState(() {
          responseCodeMonthly = 400;
        });
      } else {
        setState(() {
          list.forEach((winner) {
            _winners.add(Winner.fromJson(winner));
          });
          responseCodeMonthly = 200;
        });
        return _winners;
      }
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchWinnersMonthly();
    } else if (response.statusCode == 400) {
      setState(() {
        responseCodeMonthly = 400;
      });
    } else {
      throw Exception('Failed to load winners');
    }
  }

  @override
  void initState() {
    winnersDaily = fetchWinnersDaily();
    winnersMonthly = fetchWinnersMonthly();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 275) / 2;
    final double itemWidth = size.width / 2;
    return new Scaffold(
      body: TabBarView(
        children: [
          // DAILY
          responseCodeDaily == 200
              ? FutureBuilder<List<Winner>>(
                  future: winnersDaily,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Winner>> snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: (itemWidth / itemHeight),
                        ),
                        itemCount: snapshot.data.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          var winner = snapshot.data[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: index == 0 || index == 3 || index == 4
                                  ? primaryColor1
                                  : primaryColor2,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      "assets/home_images/user.png",
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  child: new Text(
                                    winner.firstName.length +
                                                winner.lastName.length >
                                            20
                                        ? winner.firstName
                                        : winner.firstName +
                                            " " +
                                            winner.lastName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                                new Text(
                                  winner.dateTime,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return LoadingListPage();
                    }
                  },
                )
              : Center(child: Text('No winners!')),

          // MONTHLY
          responseCodeMonthly == 200
              ? FutureBuilder<List<Winner>>(
                  future: winnersMonthly,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Winner>> snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: (itemWidth / itemHeight),
                        ),
                        itemCount: snapshot.data.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          var winner = snapshot.data[index];
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: index == 0 || index == 3 || index == 4
                                  ? primaryColor1
                                  : primaryColor2,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      "assets/home_images/user.png",
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  child: new Text(
                                    winner.firstName.length +
                                                winner.lastName.length >
                                            20
                                        ? winner.firstName
                                        : winner.firstName +
                                            " " +
                                            winner.lastName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                                new Text(
                                  winner.dateTime,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return LoadingListPage();
                    }
                  },
                )
              : Center(child: Text('No winners!')),
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
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 275) / 2;
    final double itemWidth = size.width / 2;
    return Container(
      height: 100.0,
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[400],
        enabled: true,
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (itemWidth / itemHeight),
          ),
          itemCount: 6,
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
    );
  }
}
