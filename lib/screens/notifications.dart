import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/models/message.dart';
import 'package:zyaraty/models/notification.dart';
import 'package:zyaraty/staticData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int responseCodeNoti = 0, responseCodeMessages = 0;
  var daily, monthly;
  var jwt, jwtRefresh, payload;
  List<Message> messages = [];
  List<Message> notifications = [];

  fetchmessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(
        URL +
            'api/message/GetMessages?repId=${payload["id"]}&pageNumber=1&pageSize=100',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((notification) {
          messages.add(Message.fromJson(notification));
        });
      });
      setState(() {
        responseCodeMessages = 200;
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchmessages();
    } else {
      setState(() {
        responseCodeMessages = 400;
      });
      throw Exception('Failed to load notis');
    }
  }

  fetchnotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(
        URL +
            'api/Notification/getevents?repId=${payload["id"]}&pageNumber=1&pageSize=100',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });
    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      setState(() {
        list.forEach((notification) {
          notification.add(NotificationModal.fromJson(notification));
        });
      });
      setState(() {
        responseCodeNoti = 200;
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchnotifications();
    } else {
      setState(() {
        responseCodeNoti = 400;
      });
      throw Exception('Failed to load notis');
    }
  }

  @override
  void initState() {
    fetchnotifications();
    fetchmessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TabBarView(
        children: [
          responseCodeMessages == 200
              ? messages.length > 0
                  ? ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var notification = messages[index];
                        return Card(
                          color: notification.read == false
                              ? Colors.grey[300]
                              : null,
                          child: new ListTile(
                            title: Text(
                              notification.date,
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(notification.content),
                          ),
                        );
                      },
                    )
                  : Center(child: Text("No Messages"))
              : responseCodeMessages == 400
                  ? Center(child: Text("No Messages"))
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: primaryColor1,
                      ),
                    ),
          responseCodeNoti == 200
              ? notifications.length > 0
                  ? ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notification = notifications[index];
                        return Card(
                          color: notification.read == false
                              ? Colors.grey[300]
                              : null,
                          child: new ListTile(
                            title: Text(
                              notification.date,
                              style: TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(notification.content),
                          ),
                        );
                      },
                    )
                  : Center(child: Text("No Notifications"))
              : responseCodeNoti == 400
                  ? Center(child: Text("No Notifications"))
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: primaryColor1,
                      ),
                    ),
        ],
      ),
    );
  }
}
