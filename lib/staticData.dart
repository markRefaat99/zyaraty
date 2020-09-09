import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final String URL = "http://api.zyaratmedical.com/";

Map<int, Color> color = {
  50: Color.fromRGBO(25, 188, 219, .1),
  100: Color.fromRGBO(25, 188, 219, .2),
  200: Color.fromRGBO(25, 188, 219, .3),
  300: Color.fromRGBO(25, 188, 219, .4),
  400: Color.fromRGBO(25, 188, 219, .5),
  500: Color.fromRGBO(25, 188, 219, .6),
  600: Color.fromRGBO(25, 188, 219, .7),
  700: Color.fromRGBO(25, 188, 219, .8),
  800: Color.fromRGBO(25, 188, 219, .9),
  900: Color.fromRGBO(25, 188, 219, 1),
};
Map<int, Color> whiteColor = {
  50: Color.fromRGBO(255, 255, 255, .1),
  100: Color.fromRGBO(255, 255, 255, .2),
  200: Color.fromRGBO(255, 255, 255, .3),
  300: Color.fromRGBO(255, 255, 255, .4),
  400: Color.fromRGBO(255, 255, 255, .5),
  500: Color.fromRGBO(255, 255, 255, .6),
  600: Color.fromRGBO(255, 255, 255, .7),
  700: Color.fromRGBO(255, 255, 255, .8),
  800: Color.fromRGBO(255, 255, 255, .9),
  900: Color.fromRGBO(255, 255, 255, 1),
};
final MaterialColor primaryColor1 = MaterialColor(0xFF19bcdb, color);
final MaterialColor primaryWhite = MaterialColor(0xFFFFFF, whiteColor);
final Color primaryColor2 = Color.fromRGBO(236, 92, 66, 1);
final Color primaryColor3 = Color.fromRGBO(103, 117, 120, 1);

Future<int> refreshToken() async {
  var jwt, jwtRefresh;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  jwt = prefs.getString('jwt');
  print(jwt);
  jwtRefresh = prefs.getString('jwtRefresh');
  final response = await http.post(URL + 'api/rep/RefreshToken', headers: {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer " + jwt,
    'Accept': 'application/json'
  }, body: {
    'token': jwt,
    'refreshToken': jwtRefresh
  });
  if (response.statusCode == 200) {
    return response.statusCode;
  }
}
