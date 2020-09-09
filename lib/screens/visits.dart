import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/addDoctor.dart';
import 'package:zyaraty/doctorProfile.dart';
import 'package:http/http.dart' as http;
import 'package:zyaraty/models/city.dart';
import 'package:zyaraty/models/government.dart';
import 'package:zyaraty/models/specialization.dart';
import 'package:zyaraty/staticData.dart';
import 'package:zyaraty/models/doctor.dart';

class VisitsPage extends StatefulWidget {
  @override
  _VisitsPageState createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  bool cityReadOnly = true;
  bool specializationReadOnly = true;
  bool textFieldEnabled = false;

  List<Doctor> allDoctors = [];
  List<Doctor> specialDoctors = [];
  List<Doctor> filteredDoctors = [];
  List<Government> governments = [];
  List<City> cities = [];
  List<Specialization> specializations = [];
  var jwt, jwtRefresh, payload;

  Government selectedGov = Government(gov: "Governorate");
  City selectedCity = City(cityName: "Brick");
  Specialization selectedSpecial = Specialization(type: "Specialty");

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

  fetchSpecializations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response =
        await http.get(URL + 'api/DoctorsSpecialization', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((specialization) {
          specializations.add(Specialization.fromJson(specialization));
        });
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchSpecializations();
    } else {
      throw Exception('Failed to load specials');
    }
  }

  List<City> getAllCities(Government government) {
    setState(() {
      cities = government.cities;
      selectedCity = cities[0];
    });
  }

  fetchDoctors(cityID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(URL + 'api/Doctor/$cityID', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    allDoctors = [];
    print(response.body);
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((doctor) {
          allDoctors.add(Doctor.fromJson(doctor));
        });
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchDoctors(cityID);
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  @override
  void initState() {
    fetchGov();
    fetchSpecializations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
                              itemBuilder: (BuildContext context,
                                  Government item, bool isSelected) {
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
                                  specializationReadOnly = false;
                                });
//                                print(selectedGov.cities[0].id);
                                fetchDoctors(selectedGov.cities[0].id);
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
                                    itemBuilder: (BuildContext context,
                                        City item, bool isSelected) {
                                      return Container(
                                        child: ListTile(
                                          title: Text(item.cityName),
                                        ),
                                      );
                                    },
                                    onChange: (selected) {
                                      setState(() {
                                        selectedCity = selected;
                                        fetchDoctors(selectedCity.id);
                                      });
                                    },
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
//                  _dropDown(
//                    context: context,
//                    label: "Special",
//                    selectedObj: selectedSpecial,
//                    selectedObjName: selectedSpecial.type,
//                  ),
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
//                        disabledColor: Colors.grey,
                          child: Text(selectedSpecial.type),
                          onPressed: specializationReadOnly == false
                              ? () {
                                  SelectDialog.showModal<Specialization>(
                                    context,
                                    label: "Specialty",
                                    selectedValue: selectedSpecial,
                                    items: specializations,
                                    itemBuilder: (BuildContext context,
                                        Specialization item, bool isSelected) {
                                      return Container(
                                        child: ListTile(
                                          title: Text(item.type),
                                        ),
                                      );
                                    },
                                    onChange: (selected) {
                                      setState(
                                        () {
                                          selectedSpecial = selected;
                                          textFieldEnabled = true;
                                          specialDoctors = allDoctors
                                              .where((i) =>
                                                  i.speical == selected.id)
                                              .toList();
                                        },
                                      );
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
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                elevation: 10.0,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  onChanged: (text) {
                    setState(() {
                      filteredDoctors = specialDoctors.where((i) {
                        return (i.fname + i.lname).contains(text) && text != "";
                      }).toList();
                    });
                  },
                  decoration: InputDecoration(
                    enabled: textFieldEnabled,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintText: 'Doctor Name',
//                    border: new OutlineInputBorder(
//                      borderRadius: BorderRadius.circular(10),
//                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
//            Padding(
//              padding: const EdgeInsets.all(10.0),
//              child: Container(
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.circular(10),
//                  border: Border.all(color: primaryColor2),
//                ),
//                child: TextField(
//                  onChanged: (text) {
//                    setState(() {
//                      filteredDoctors = specialDoctors.where((i) {
//                        return (i.fname + i.lname).contains(text) && text != "";
//                      }).toList();
//                    });
//                  },
//                  decoration: InputDecoration(
//                    enabled: textFieldEnabled,
//                    contentPadding: EdgeInsets.symmetric(vertical: 12),
//                    hintText: 'Doctor Name',
//                    prefixIcon: Icon(Icons.search),
//                  ),
//                ),
//              ),
//            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DoctorProfilePage(
                                doctor: filteredDoctors[index])),
                      );
                    },
                    title: Text(filteredDoctors[index].fname +
                        " " +
                        filteredDoctors[index].lname),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
//                        Text('باطنة'),
                        Text(filteredDoctors[index].cityName == null
                            ? " "
                            : filteredDoctors[index].cityName),
                      ],
                    ),
                  ),
                  margin: const EdgeInsets.all(8.0),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDoctorPage(
                  governments: governments,
                  specializations: specializations,
                ),
              ),
            );
          },
          child: new Icon(Icons.add, color: Colors.white),
          tooltip: "Add new doctor",
          backgroundColor: primaryColor1,
        ),
      ),
    );
  }
}
