import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zyaraty/models/government.dart';
import 'package:zyaraty/models/city.dart';
import 'package:zyaraty/models/lastActivity.dart';
import 'package:zyaraty/staticData.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastActivitiesPage extends StatefulWidget {
  @override
  _LastActivitiesPageState createState() => _LastActivitiesPageState();
}

class _LastActivitiesPageState extends State<LastActivitiesPage> {
  List<Government> governments = [];
  List<City> cities = [];
  bool cityReadOnly = true;
  Government selectedGov = Government(gov: "Government");
  City selectedCity = City(cityName: "Brick");
  List<LastActivity> lastActivities = [];

  var jwt, jwtRefresh, payload;
  @override
  void initState() {
    fetchGov();
    super.initState();
  }

  Future<http.Response> likeAndDislike(LastActivity lastActivity, val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    if (lastActivity.isLiker) {
      if (val) {
        final response = await http.delete(
          URL +
              'api/Evaluation?visitid=${lastActivity.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            fetchActivities(selectedCity.id);
          });
        } else if (response.statusCode == 401) {
          if (refreshToken() == 200) likeAndDislike(lastActivity, val);
        }
      } else {
        final response = await http.put(
          URL +
              'api/Evaluation?visitid=${lastActivity.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            fetchActivities(selectedCity.id);
          });
        } else if (response.statusCode == 401) {
          if (refreshToken() == 200) likeAndDislike(lastActivity, val);
        }
      }
    } else if (lastActivity.isDisLiker) {
      if (val) {
        final response = await http.put(
          URL +
              'api/Evaluation?visitid=${lastActivity.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            fetchActivities(selectedCity.id);
          });
        } else if (response.statusCode == 401) {
          if (refreshToken() == 200) likeAndDislike(lastActivity, val);
        }
      } else {
        final response = await http.delete(
          URL +
              'api/Evaluation?visitid=${lastActivity.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            fetchActivities(selectedCity.id);
          });
        } else if (response.statusCode == 401) {
          if (refreshToken() == 200) likeAndDislike(lastActivity, val);
        }
      }
    } else {
      Map data = {
        'EvaluatorId': int.parse(payload['id']),
        'visitId': lastActivity.id,
        'type': val,
      };
      //encode Map to JSON
      var body = json.encode(data);

      final response = await http.post(URL + 'api/Evaluation',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
          body: body);
      if (response.statusCode == 200) {
        setState(() {
          fetchActivities(selectedCity.id);
        });
      } else if (response.statusCode == 401) {
        if (refreshToken() == 200) likeAndDislike(lastActivity, val);
      }
    }
  }

  fetchGov() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(URL + 'api/Gov', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((government) {
          List<City> governmentCities = [];
          government['cities'].forEach((city) {
            governmentCities.add(City.fromJson(city));
          });
          governments.add(Government.fromJson(government, governmentCities));
        });
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchGov();
    } else {
      throw Exception('Failed to load govs');
    }
  }

  List<City> getAllCities(Government government) {
    setState(() {
      cities = government.cities;
      selectedCity = cities[0];
    });
  }

  fetchActivities(cityID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    lastActivities = [];
    final response = await http.get(
        URL +
            'api/visit/GetVisitsInCity?cityId=${cityID.toString()}&userId=${payload['id']}&pageNumber=1&pageSize=100',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((doctor) {
          lastActivities.add(LastActivity.fromJson(doctor));
        });
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchActivities(cityID);
    } else {
      throw Exception('Failed to load activities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 40.0,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: primaryColor2),
                    ),
                    child: Material(
                      elevation: 10.0,
                      shadowColor: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        child: Text(selectedGov.gov),
                        onPressed: () {
                          SelectDialog.showModal<Government>(
                            context,
                            label: "Governorate",
                            selectedValue: selectedGov,
                            items: governments,
                            itemBuilder: (BuildContext context, Government item,
                                bool isSelected) {
                              return Container(
                                child: ListTile(
                                  title: Text(item.gov),
                                ),
                              );
                            },
                            onChange: (selected) {
                              setState(() {
                                selectedGov = selected;
                                cityReadOnly = false;
                              });
                              fetchActivities(selectedGov.cities[0].id);
                              getAllCities(selectedGov);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: Container(
                    height: 40.0,
                    decoration: new BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: primaryColor2),
                    ),
                    child: Material(
                      elevation: 10.0,
                      shadowColor: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      child: MaterialButton(
                        child: Text(selectedCity.cityName),
                        onPressed: cityReadOnly == false
                            ? () {
                                SelectDialog.showModal<City>(
                                  context,
                                  label: "Brick",
                                  selectedValue: selectedCity,
                                  items: cities,
                                  itemBuilder: (BuildContext context, City item,
                                      bool isSelected) {
                                    return Container(
                                      child: ListTile(
                                        title: Text(item.cityName),
                                      ),
                                    );
                                  },
                                  onChange: (selected) {
                                    setState(() {
                                      selectedCity = selected;
                                      fetchActivities(selectedCity.id);
                                    });
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: lastActivities.length != 0
                ? ListView.builder(
                    itemCount: lastActivities.length,
                    itemBuilder: (context, index) {
                      var lastActivity = lastActivities[index];
                      return Card(
                        child: new ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                lastActivity.date,
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 2),
                              InkWell(
                                onTap: () {
//                          showDialog(
//                            context: context,
//                            builder: (BuildContext context) =>
//                                CustomDialog(
//                              name: "Mark Refaat",
//                              description:
//                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                              buttonText: "Close",
//                            ),
//                          );
                                },
                                child: Text(
                                  lastActivity.repFname +
                                      " " +
                                      lastActivity.repLname,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('Dr.' +
                                  lastActivity.docFname +
                                  ' ' +
                                  lastActivity.docLname +
                                  ', Batna'),
                              Text(lastActivity.content),
//                        Text(
//                          'تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق تعليق ',
//                          textAlign: TextAlign.end,
//                        )
                            ],
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: lastActivity.isActive
                                            ? (lastActivity.isLiker
                                                ? Colors.green
                                                : Colors.grey)
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        likeAndDislike(lastActivity, true);
                                      },
                                    ),
                                    InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 4.0, right: 4.0),
                                          child: Text(lastActivity.likesCount
                                              .toString()),
                                        ),
                                        onTap: () {
                                          if (lastActivity.likesCount > 0) {
//                                            return displayBottomSheet(context,
//                                                snapshot.data[index].id, true);
                                          }
                                        }),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
//                              Text("غير مفيد"),
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_down,
                                        color: lastActivity.isActive
                                            ? (lastActivity.isDisLiker
                                                ? Colors.red
                                                : Colors.grey)
                                            : Colors.black,
                                      ),
                                      onPressed: () {
                                        likeAndDislike(lastActivity, false);
                                      },
                                    ),
                                    InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 4.0, right: 4.0),
                                          child: Text(lastActivity.dislikesCount
                                              .toString()),
                                        ),
                                        onTap: () {
                                          if (lastActivity.dislikesCount > 0) {
//                                            return displayBottomSheet(context,
//                                                snapshot.data[index].id, false);
                                          }
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text('No activites')),
          ),
        ],
      ),
    );
  }
}
