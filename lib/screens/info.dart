import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/staticData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int responseCode = 0;
  var daily, monthly;
  var jwt, jwtRefresh, payload;
  fetchCompetitionTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response =
        await http.get(URL + 'api/Competition/getNext/daily', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    final response2 =
        await http.get(URL + 'api/Competition/getNext/monthly', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    if (response.statusCode == 200 && response2.statusCode == 200) {
      setState(() {
        responseCode = 200;
        daily = json.decode(response.body);
        monthly = json.decode(response2.body);
      });
    } else if (response.statusCode == 401 || response2.statusCode == 401) {
      if (refreshToken() == 200) fetchCompetitionTerms();
    } else if (response.statusCode == 400 || response2.statusCode == 400) {
      setState(() {
        responseCode = 400;
      });
    } else {
      throw Exception('Failed to load terms');
    }
  }

  @override
  void initState() {
    fetchCompetitionTerms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TabBarView(
        children: [
          responseCode == 200
              ? Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Daily Competition Terms',
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w600,
                                color: primaryColor1,
                                decoration: TextDecoration.underline),
                          ),
                          Text(
                            "Role: ${daily['roles']}",
                            style: TextStyle(fontSize: 25.0),
                          ),
                          Text(
                            "Minimum Unique Users: ${daily['minUniqueUsers']}",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "Minimum Unique Visits: ${daily['minUniqueVisits']}",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                    ),
                    Divider(color: Colors.black),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Monthly Competition Terms',
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w600,
                                color: primaryColor1,
                                decoration: TextDecoration.underline),
                          ),
                          Text(
                            "Role: ${monthly['roles']}",
                            style: TextStyle(fontSize: 25.0),
                          ),
                          Text(
                            "Minimum Unique Users: ${monthly['minUniqueUsers']}",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "Minimum Unique Visits: ${monthly['minUniqueVisits']}",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                    ),
                  ],
                )
              : responseCode == 400
                  ? Center(child: Text("No Competition Terms"))
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: primaryColor1,
                      ),
                    ),
          // About
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                  child: Text(
                    "ZYARAT",
                    style: TextStyle(fontSize: 28.0, color: primaryColor1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(children: [
                    TextSpan(
                        text: "“ZYARAT medical”",
                        style: TextStyle(
                            color: primaryColor1, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            " Is a unique Android application & website of its own that serve as a time management tool designed specifically for workers in the field of medical promotion to facilitate their work during visiting clinics, medical centers and hospitals in Egypt.",
                        style: TextStyle(color: primaryColor3))
                  ]),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'The application depends on exchange of real time feedback concerning visiting status in clinics between colleagues who already exist inside clinic or have an accurate data about it and other colleagues seeking for these data in real time.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: primaryColor3),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'The application has strict terms to ensure accurate data that’ll benefit those who seek it and provide a professional work environment through enabling rating option & taking decisive actions against accounts that provide a specific limit of inaccurate data & get negative rating.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: primaryColor3),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  'The application encourages positive participants who provide plenty of accurate, updated and reliable data and hence get positive rating, through providing financial incentives to the daily and monthly winners of competitions that are announced on our formal channels (the App., Website, Facebook page).',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: primaryColor3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
