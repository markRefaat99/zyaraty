import 'dart:convert';
import 'dart:io';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/editProfile.dart';
import 'package:zyaraty/landing_page.dart';
import 'package:zyaraty/models/menuItem.dart';
import 'package:zyaraty/models/user.dart';
import 'package:zyaraty/staticData.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class MenuScreen extends StatefulWidget {
  final List<MenuItem> mainMenu;
  final Function(int) callback;
  final int current;

  MenuScreen(
    this.mainMenu, {
    Key key,
    this.callback,
    this.current,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  User user = new User(id: null, fname: "", lname: "", pictureURL: null);
  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');
    print(jwt);
    var jwtRefresh = prefs.getString('jwtRefresh');
    var dio = Dio(BaseOptions(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ));
    dio.post(
      URL + 'api/rep/logout',
      data: {'token': jwt, 'refreshToken': jwtRefresh},
    ).then((value) {
      prefs.remove("jwt");
      prefs.remove("jwtRefresh");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
        (Route<dynamic> route) => false,
      );
    });
  }

  fetchUsernameAndImage() async {
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
      });
      print("MARK" + user.pictureURL);
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchUsernameAndImage();
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  void initState() {
    fetchUsernameAndImage();
    super.initState();
  }

  final widthBox = SizedBox(
    width: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor1,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 5.0, left: 24.0, right: 24.0),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: user.pictureURL == null
                          ? Image.asset("assets/home_images/user.png")
                          : Image.network(URL + user.pictureURL),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 36.0, left: 40.0, right: 24.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                  child: Text(
                    user.fname + " " + user.lname,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Selector<MenuProvider, int>(
                selector: (_, provider) => provider.currentPage,
                builder: (_, index, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...widget.mainMenu.map((item) {
                      return _menuItemWidget(
                        item: item,
                        callback: widget.callback,
                        widthBox: widthBox,
                        style: style,
                        selected: index == item.index,
                      );
                    }).toList()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        MdiIcons.facebook,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _launchUrl('https://www.facebook.com/zyaratmedical');
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        MdiIcons.whatsapp,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _launchUrl('https://wa.me/message/5ZPUBEZXXB45N1');
                      },
                    )
                  ],
                ),
              ),
              Spacer(),
              Container(
                width: 180.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: OutlineButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(MdiIcons.logout),
                          Text(
                            "logout",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    onPressed: () {
                      logout();
                    },
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

_menuItemWidget({
  MenuItem item,
  Widget widthBox,
  TextStyle style,
  Function callback,
  bool selected,
}) {
  return FlatButton(
    onPressed: () => callback(item.index),
    color: selected ? primaryColor2 : null,
    child: Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            item.icon,
            color: Colors.white,
            size: 24,
          ),
          widthBox,
          Expanded(
            child: Text(
              item.title,
              style: style,
            ),
          )
        ],
      ),
    ),
  );
}

void _launchUrl(String s) async {
  if (await launcher.canLaunch(s)) await launcher.launch(s);
}
