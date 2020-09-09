import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zyaraty/models/user.dart';
import 'package:zyaraty/staticData.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User user = new User(id: null, fname: "", lname: "", pictureURL: null);
  var jwt, jwtRefresh, payload;
  fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');
    print(jwt);
    var jwtRefresh = prefs.getString('jwtRefresh');
    var payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(URL + 'api/rep/' + payload['id'], headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      setState(() {
        user = User.fromJson(json.decode(response.body));
        _phoneController.text = user.phone;
        _companyController.text = user.workedOnCompany;
        selectedTitle = user.medicalRepPositionID.toString();
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchUserData();
    } else {
      throw Exception('Failed to load user');
    }
  }

  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _companyController = new TextEditingController();
  var titleOptions = [];
  var selectedTitle;

  @override
  void initState() {
    fetchUserData();
    fetchTitles();
    super.initState();
  }

  fetchTitles() async {
    final response = await http.get(URL + 'api/MedicalRepPosition');
    if (response.statusCode == 200) {
      setState(() {
        titleOptions = json.decode(response.body);
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchTitles();
    } else {
      throw Exception('Failed to load titles');
    }
  }

  Future<Map<String, dynamic>> update(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.put(
        URL + 'api/rep/UpdatePhone/${payload['id']}/${_phoneController.text}',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });
    final response2 = await http.put(
        URL +
            'api/rep/UpdateCompany/${payload['id']}/${_companyController.text}',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });

    final response3 = await http.put(
        URL + 'api/rep/UpdatePosition/${payload['id']}/${selectedTitle}',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });
    if (_image != null) {
      var dio = Dio(BaseOptions(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          }));
      var body = new Map<String, dynamic>();
      body['image'] = await MultipartFile.fromFile(_image.path,
          filename: "${payload['id']}.jpeg");
      FormData formData = new FormData.fromMap(body);
      final response4 = await dio.put(
        URL + 'api/rep/UpdateImageProfile/${payload["id"]}',
        data: formData,
      );

      if (response.statusCode == 200 &&
          response2.statusCode == 200 &&
          response3.statusCode == 200 &&
          response4.statusCode == 200) {
        Navigator.pop(context);
      }
      if (response.statusCode == 200 ||
          response2.statusCode == 200 ||
          response3.statusCode == 200 ||
          response4.statusCode == 200) {
        if (refreshToken() == 200) update(context);
      }
    }

    if (response.statusCode == 200 &&
        response2.statusCode == 200 &&
        response3.statusCode == 200) {
      Navigator.pop(context);
    }
    if (response.statusCode == 200 ||
        response2.statusCode == 200 ||
        response3.statusCode == 200) {
      if (refreshToken() == 200) update(context);
    }
  }

  var _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Profile"),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 250.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/frontImage.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _image != null
                              ? Image.file(File(_image.path))
                              : user.pictureURL == null
                                  ? Image.asset("assets/home_images/user.png")
                                  : Image.network(URL + user.pictureURL),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: getImage,
                          child: new Text("Change Image"),
                        ),
                      ),
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
                                controller: _phoneController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Phone number *",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _companyController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Company (optional)",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: new DropdownButton<String>(
                                isExpanded: true,
                                underline: new Container(),
                                items: titleOptions
                                    .map<DropdownMenuItem<String>>((title) {
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
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor2,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: MaterialButton(
                          onPressed: () {
                            update(context);
                          },
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
