import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zyaraty/packages/CustomDrawer.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/staticData.dart';
import 'package:http/http.dart' as http;

class PageStructure extends StatefulWidget {
  final String title;
  final Widget child;
  final Color backgroundColor;
  final double elevation;

  const PageStructure({
    Key key,
    this.title,
    this.child,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  _PageStructureState createState() => _PageStructureState();
}

class _PageStructureState extends State<PageStructure> {
  var jwt, jwtRefresh, payload;
  int count = 0;
  countUnreadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http
        .get(URL + 'api/message/CountUnRead/${payload["id"]}', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    final response2 = await http
        .get(URL + 'api/Notification/CountUnRead/${payload["id"]}', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });

    if (response.statusCode == 401 || response2.statusCode == 401) {
      if (refreshToken() == 200) countUnreadNotifications();
    }
    setState(() {
      count = int.parse(response.body) + int.parse(response2.body);
    });
  }

  @override
  void initState() {
    countUnreadNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _currentPage =
        context.select<MenuProvider, int>((provider) => provider.currentPage);
    return WillPopScope(
//      onWillPop: () => Future.value(true),
//      onWillPop: () => Future.value(false),
      onWillPop: () {
        Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(0);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // Bottom Appbar for competition page
            bottom:
                HomeScreen.drawerMenu[_currentPage].title == "Competition" ||
                        HomeScreen.drawerMenu[_currentPage].title == "Winners"
                    ? new TabBar(
                        tabs: <Tab>[
                          new Tab(
                            child: new Text(
                              "Daily",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          new Tab(
                            child: new Text(
                              "Monthly",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : HomeScreen.drawerMenu[_currentPage].title == "Info"
                        ? new TabBar(
                            tabs: <Tab>[
                              new Tab(
                                child: new Text(
                                  "Competition Terms",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              new Tab(
                                child: new Text(
                                  "About",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : HomeScreen.drawerMenu[_currentPage].title ==
                                "Notifications"
                            ? new TabBar(
                                tabs: <Tab>[
                                  new Tab(
                                    child: new Text(
                                      "Messages",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  new Tab(
                                    child: new Text(
                                      "Notifications",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : null,
            titleSpacing: 0.0,
            backgroundColor: Color.fromRGBO(25, 188, 219, 1),
            title: Text(
              HomeScreen.drawerMenu[_currentPage].title,
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                ZoomDrawer.of(context).toggle();
              },
            ),
            actions: [
              Image.asset(
                'assets/images/logo_white.png',
                width: 25.0,
              ),
              InkWell(
                onTap: () {
                  Provider.of<MenuProvider>(context, listen: false)
                      .updateCurrentPage(7);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      count != null && count != 0
                          ? Positioned(
                              top: 2,
                              right: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.red),
                                alignment: Alignment.center,
                                child: Text(
                                  '${count}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: HomeScreen.drawerMenu[_currentPage].page,
        ),
      ),
    );
  }
}
