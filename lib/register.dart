import 'dart:io';

import 'package:flutter/material.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/login.dart';
import 'package:zyaraty/models/city.dart';
import 'package:zyaraty/models/government.dart';
import 'package:zyaraty/packages/CustomStepper.dart';
import 'package:zyaraty/staticData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  int _currentStep = 0;
  String buttonText = 'Continue';
  var titleOptions = [];
  var selectedTitle;
  var jwt, jwtRefresh, payload;
  List<Government> governments = [];
  List<City> cities = [];
  Government selectedGov = Government(gov: "Governorate");
  City selectedCity = City(cityName: "Brick");
  bool cityReadOnly = true;

  TextEditingController _fname = new TextEditingController();
  TextEditingController _lname = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _company = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();

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

  Future<Map<String, dynamic>> signup(String email, String password) async {
    var dio = Dio(BaseOptions(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ));
    dio.options.baseUrl = URL;
    var body = new Map<String, dynamic>();
//    body['fname'] = 'mark';
//    body['lname'] = 'mark';
//    body['email'] = 'mm@m.com';
//    body['password'] = '123';
//    body['phone'] = '0122222222';
//    body['cityId'] = 0;
//    body['MedicalRepPositionId'] = 0;
//    body['WorkedOnCompany'] = '';
//    body['Image'] = null;
    body['fname'] = _fname.text;
    body['lname'] = _lname.text;
    body['email'] = _email.text;
    body['password'] = _password.text;
    body['phone'] = _password.text;
    body['cityId'] = selectedCity.id;
    body['MedicalRepPositionId'] =
        selectedTitle == null ? 0 : int.parse(selectedTitle);
    body['WorkedOnCompany'] = _company.text;
    body['Image'] = null;

    FormData formData = new FormData.fromMap(body);
    final response = await dio.post(
      URL + 'api/rep/register',
      data: formData,
    );
    print(response.statusCode);
    print(response.data);
    if (response.statusCode == 400) {
    } else if (response.statusCode == 200) {
      print(response.statusCode);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('jwt', response.data['token']);
      prefs.setString('jwtRefresh', response.data['refreshToken']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => MenuProvider(),
            child: HomeScreen(),
          ),
        ),
      );
      return {'success': true, 'message': 'Successfuly signup!'};
    }
  }

  @override
  void initState() {
    fetchTitles();
    fetchGov();
    super.initState();
  }

  fetchTitles() async {
    final response = await http.get(URL + 'api/MedicalRepPosition');
    if (response.statusCode == 200) {
      setState(() {
        titleOptions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load MedicalRepPosition');
    }
  }

  List<Step> _registerSteps() {
    List<Step> _steps = [
      Step(
        title: Container(),
        isActive: _currentStep >= 0,
        state: StepState.indexed,
        content: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(143, 148, 251, .2),
                  blurRadius: 20.0,
                  offset: Offset(0, 10))
            ],
          ),
          child: Column(
            children: <Widget>[
              // FIRST NAME
              _textField(
                  hintText: "First Name",
                  req: true,
                  textEditingController: _fname),
              // LAST NAME
              _textField(
                  hintText: "Last Name",
                  req: true,
                  textEditingController: _lname),
              // PHONE NUMBER
              _textField(
                  hintText: "Phone", req: true, textEditingController: _phone),
//              _textField(hintText: "Confirm Phone", req: true),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '* Your phone number will not be shown to others but it’s the formal way of communication in case you won  any of our prizes',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        isActive: _currentStep >= 1,
        state: StepState.indexed,
        title: Container(),
        content: Container(
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
//              _textField(
//                  hintText: "City (optional)", textEditingController: _city),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
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
                        getAllCities(selectedGov);
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedGov.gov),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: cityReadOnly == false
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
                              });
                            },
                          );
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCity.cityName,
                        style: TextStyle(
                            color: cityReadOnly ? Colors.grey : Colors.black),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: cityReadOnly ? Colors.grey : Colors.black)
                    ],
                  ),
                ),
              ),
              _textField(
                  hintText: "Company (optional)",
                  textEditingController: _company),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: new DropdownButton<String>(
                  isExpanded: true,
                  underline: new Container(),
                  items: titleOptions.map<DropdownMenuItem<String>>((title) {
                    return DropdownMenuItem(
                      child: new Text(title['title']),
                      value: title['id'].toString(),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTitle = value;
                    });
                  },
                  value: selectedTitle,
                  hint: Text("title"),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        state: StepState.indexed,
        title: Container(),
        content: Container(
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
              // EMAIL
              _textField(
                  hintText: "Email", req: true, textEditingController: _email),
              // PASSWORD
              _textField(
                  hintText: "Password",
                  req: true,
                  textEditingController: _password),
            ],
          ),
        ),
      ),
    ];
    return _steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 250.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/frontImage.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  CustomStepper(
                    steps: _registerSteps(),
                    currentStep: this._currentStep,
                    onStepContinue: () {
                      if (this._currentStep == 2) {
                        print("a");
                        signup("m", "m");
                      }
                      print(this._currentStep);
                      setState(() {
                        if (this._currentStep <
                            this._registerSteps().length - 1) {
                          this._currentStep = this._currentStep + 1;
                          buttonText = "Continue";
                          if (this._currentStep ==
                              this._registerSteps().length - 1)
                            buttonText = "Register";
                        } else
                          print("DONE");
                      });
                    },
                    controlsBuilder: (BuildContext context,
                        {VoidCallback onStepContinue,
                        VoidCallback onStepCancel}) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor2,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            onPressed: onStepContinue,
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _currentStep == 0
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            child: Text(
                              "I have an Account!",
                              style: TextStyle(color: primaryColor1),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (this._currentStep > 0) {
                    this._currentStep = this._currentStep - 1;
                    buttonText = "Continue";
                  } else
                    Navigator.pop(context);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

_textField({hintText, req: false, textEditingController}) {
  return Container(
    padding: EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey[100]),
      ),
    ),
    child: TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        suffixText: req ? '*' : '',
        suffixStyle: TextStyle(
          fontSize: 20.0,
          color: Colors.red,
        ),
        border: InputBorder.none,
        hintText: hintText + (req ? ' *' : ''),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    ),
  );
}
