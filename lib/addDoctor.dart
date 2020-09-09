import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/models/city.dart';
import 'package:zyaraty/models/government.dart';
import 'package:zyaraty/models/specialization.dart';
import 'package:zyaraty/staticData.dart';
import 'package:dio/dio.dart';

class AddDoctorPage extends StatefulWidget {
  final List<Government> governments;
  final List<Specialization> specializations;
  AddDoctorPage({this.governments, this.specializations});

  @override
  _AddDoctorPageState createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  bool cityReadOnly = true;
  bool specializationReadOnly = true;
  bool textFieldEnabled = false;

  List<City> cities = [];

  Government selectedGov = Government(gov: "Governorate");
  City selectedCity = City(cityName: "Brick");
  Specialization selectedSpecial = Specialization(type: "Specialty");
  var jwt, jwtRefresh, payload;

  addDoctor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));

//    BaseOptions(
//      contentType: Headers.jsonContentType,
//      responseType: ResponseType.json,
//      validateStatus: (_) => true,
//    )
    var dio = Dio(BaseOptions(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
    var body = new Map<String, dynamic>();
    body["fname"] = "mark";
    body["lname"] = "mark";
    body['cityId'] = 105;
    body['adderMedicalRepId'] = int.parse(payload['id']);
    body['medicalSpecializedId'] = 1;

    FormData formData = new FormData.fromMap(body);
    final response = await dio.post(
      URL + 'api/Doctor',
      data: formData,
    );

    if (response.statusCode == 401) {
      if (refreshToken() == 200) addDoctor();
    }
    print(response.statusCode);
    print(response.data);
  }

  List<City> getAllCities(Government government) {
    setState(() {
      cities = government.getCities();
      selectedCity = cities[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0,
        title: Text('Add Doctor'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/frontImage.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10))
                      ]),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[100]),
                          ),
                        ),
                        child: TextField(
                          textDirection: TextDirection.rtl,
                          inputFormatters: [
                            new FilteringTextInputFormatter.allow(
                              RegExp("[ء-ي]+"),
                            )
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person),
                            hintText: "Doctor name",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            helperText: "Use Arabic letters only",
                            helperStyle: TextStyle(
                              color: primaryColor2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width,
                        child: MaterialButton(
                          child: Row(
                            children: [
                              Text(selectedGov.gov),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          onPressed: () {
                            SelectDialog.showModal<Government>(
                              context,
                              label: "Government",
                              selectedValue: selectedGov,
                              items: widget.governments,
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
                                getAllCities(selectedGov);
                              },
                            );
                          },
                        ),
                      ),
                      Divider(),
                      Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width,
                        child: MaterialButton(
                          child: Row(
                            children: [
                              Text(selectedCity.cityName),
                              Icon(Icons.arrow_drop_down)
                            ],
                          ),
                          onPressed: cityReadOnly == false
                              ? () {
                                  SelectDialog.showModal<City>(
                                    context,
                                    label: "City",
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
                                      });
                                    },
                                  );
                                }
                              : null,
                        ),
                      ),
                      Divider(),
                      Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width,
                        child: MaterialButton(
//                        disabledColor: Colors.grey,
                          child: Row(
                            children: [
                              Text(
                                selectedSpecial.type,
                                textAlign: TextAlign.start,
                              ),
                              new Icon(Icons.arrow_drop_down)
                            ],
                          ),
                          onPressed: specializationReadOnly == false
                              ? () {
                                  SelectDialog.showModal<Specialization>(
                                    context,
                                    label: "Special",
                                    selectedValue: selectedSpecial,
                                    items: widget.specializations,
                                    itemBuilder: (BuildContext context,
                                        Specialization item, bool isSelected) {
                                      return Container(
                                        child: ListTile(
                                          title: Text(item.type),
                                        ),
                                      );
                                    },
                                    onChange: (selected) {
                                      setState(() {
                                        selectedSpecial = selected;
                                      });
                                    },
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
//                Container(
//                  padding: EdgeInsets.all(5),
//                  decoration: BoxDecoration(
//                      color: Colors.white,
//                      borderRadius: BorderRadius.circular(10),
//                      boxShadow: [
//                        BoxShadow(
//                            color: Color.fromRGBO(143, 148, 251, .2),
//                            blurRadius: 20.0,
//                            offset: Offset(0, 10))
//                      ]),
//                  child:
//                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor2,
                      borderRadius: BorderRadius.circular(50.0),
                      //                              gradient: new LinearGradient(
//                                colors: [
//                                  primaryColor1,
//                                  primaryColor2,
//                                ],
//                                begin: FractionalOffset.centerLeft,
//                                end: FractionalOffset.centerRight,
//                              ),
//                              borderRadius: BorderRadius.circular(50.0),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: MaterialButton(
                      onPressed: () {
                        addDoctor();
                      },
                      child: Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
