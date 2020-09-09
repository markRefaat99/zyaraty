import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/models/comment.dart';
import 'package:zyaraty/models/doctor.dart';
import 'package:zyaraty/models/user.dart';
import 'package:zyaraty/staticData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:signalr_client/signalr_client.dart';

class DoctorProfilePage extends StatefulWidget {
  final Doctor doctor;
  DoctorProfilePage({key, @required this.doctor}) : super(key: key);
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  joinGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print("THIS IS TOKEN" + jwt);
    final hubConnection = HubConnectionBuilder()
        .withUrl("http://api.zyaratmedical.com/notification",
            options: HttpConnectionOptions(
              accessTokenFactory: () => Future.value(jwt),
            ))
        .build();
    await hubConnection.start();
    await hubConnection
        .invoke("JoinGroup", args: <Object>["Doctor${widget.doctor.id}Group"]);
  }

  TextEditingController _commentTextFieldController =
      new TextEditingController();
  String selectedOpen;
  String selectedAvailability;
  String selectedNoOfPatients;
  final List openOptions = ["Open", "Closed"];
  final List availabilityOptions = ["Available", "Not available"];
  final List noOfPatientsOptions = ["1", "2", "3", "4", "5", "6", "7+"];
  int responseCode = 0;
  Future<List<Comment>> allComments;
  var jwt, jwtRefresh, payload;

  Future<List<Comment>> fetchVisits() async {
    List<Comment> _comments = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response = await http.get(
        URL +
            'api/visit/GetVisitsInDoctor?doctorId=' +
            widget.doctor.id.toString() +
            '&userId=${payload['id']}&pageNumber=1&pageSize=100',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer " + jwt,
          'Accept': 'application/json'
        });

    if (response.statusCode == 200) {
      List list = json.decode(response.body);
      if (list.length == 0) {
        setState(() {
          responseCode = 400;
        });
      } else {
        setState(() {
          list.forEach((comment) {
            _comments.add(Comment.fromJson(comment));
          });
          responseCode = 200;
        });
        return _comments;
      }
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchVisits();
    } else if (response.statusCode == 400) {
      setState(() {
        responseCode = 400;
      });
    } else {
      throw Exception('Failed to load commnets');
    }
  }

//  notifiLike(id) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    jwt = prefs.getString('jwt');
////    print("THIS IS TOKEN" + jwt);
//    final hubConnection = HubConnectionBuilder()
//        .withUrl("http://api.zyaratmedical.com/notification",
//            options: HttpConnectionOptions(
//              accessTokenFactory: () => Future.value(jwt),
//            ))
//        .build();
//    await hubConnection.start();
//    var result = await hubConnection.invoke("SendEvaluation",
//        args: <Object>["Doctor${widget.doctor.id}Group", id]);
//  }

  Future<http.Response> likeAndDislike(Comment comment, val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    if (comment.isLiker) {
      if (val) {
        final response = await http.delete(
          URL + 'api/Evaluation?visitid=${comment.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            allComments = fetchVisits();
          });
//          notifiLike(comment.id);
        } else if (response.statusCode == 401) {
          if (refreshToken() == 200) likeAndDislike(comment, val);
        }
      } else {
        final response = await http.put(
          URL + 'api/Evaluation?visitid=${comment.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            allComments = fetchVisits();
          });
//          notifiLike(comment.id);
        }
        if (refreshToken() == 200) likeAndDislike(comment, val);
      }
    } else if (comment.isDisLiker) {
      if (val) {
        final response = await http.put(
          URL + 'api/Evaluation?visitid=${comment.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            allComments = fetchVisits();
          });
//          notifiLike(comment.id);
        }
        if (refreshToken() == 200) likeAndDislike(comment, val);
      } else {
        final response = await http.delete(
          URL + 'api/Evaluation?visitid=${comment.id}&repId=${payload["id"]}',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            allComments = fetchVisits();
          });
//          notifiLike(comment.id);
        }
        if (refreshToken() == 200) likeAndDislike(comment, val);
      }
    } else {
      Map data = {
        'EvaluatorId': int.parse(payload['id']),
        'visitId': comment.id,
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
          allComments = fetchVisits();
        });
//        notifiLike(comment.id);
      }
    }
  }

//  listen() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    jwt = prefs.getString('jwt');
//    print("THIS IS TOKEN" + jwt);
//    final hubConnection = HubConnectionBuilder()
//        .withUrl("http://api.zyaratmedical.com/notification",
//            options: HttpConnectionOptions(
//              accessTokenFactory: () => Future.value(jwt),
//            ))
//        .build();
//    await hubConnection.start();
//    hubConnection.on("ReceiveEvaluation", (List<Object> parameters) {
//      setState(() {
//        allComments = fetchVisits();
//      });
//    });
//  }

  @override
  void initState() {
    allComments = fetchVisits();
    joinGroup();
//    listen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //    WHO LIKES OR DISLIKES POPUP
    void displayBottomSheet(BuildContext context, visitID, type) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      jwt = prefs.getString('jwt');
      print(jwt);
      jwtRefresh = prefs.getString('jwtRefresh');
      payload = json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
      final response = await http.get(
          URL + 'api/Evaluation/getevaluators/' + visitID.toString(),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + jwt,
            'Accept': 'application/json'
          });
      if (response.statusCode == 401) {
        if (refreshToken() == 200) {
          final response = await http.get(
              URL + 'api/Evaluation/getevaluators/' + visitID.toString(),
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader: "Bearer " + jwt,
                'Accept': 'application/json'
              });
        }
      }
      List<dynamic> users = [];
      for (Map user in jsonDecode(response.body)) {
        if (user['type'] == type) users.add(user);
      }
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  title: InkWell(
                    child: Text("${users[index]['name'].toString()}"),
                    onTap: () {
                      fetchUser(users[index]['evaluatorId']).then((user) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => CustomDialog(
                            name: user.fname + " " + user.lname,
                            pictureURL: user.pictureURL,
                            email: user.email,
                            title: user.medicalRepPositionTitle,
                            companyName: user.workedOnCompany,
                            visitsCount: user.visitsCount,
                            likeCount: user.likeCount,
                            disLikeCount: user.disLikeCount,
                            buttonText: "Close",
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: new Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              widget.doctor.fname + " " + widget.doctor.lname,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
              ),
            ),
            Text(
              widget.doctor.speicalName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.doctor.cityName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Column(
                        children: [
                          new Text('Clinc'),
                          new DropdownButton<String>(
                            underline: new Container(),
                            items: openOptions
                                .map<DropdownMenuItem<String>>((location) {
                              return DropdownMenuItem(
                                child: new Text(location),
                                value: location,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedOpen = value;
                              });
                            },
                            value: selectedOpen,
                            hint: Text("open/close"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Column(
                        children: [
                          new Text("Visit"),
                          new DropdownButton<String>(
                            underline: new Container(),
                            items: availabilityOptions
                                .map<DropdownMenuItem<String>>((location) {
                              return DropdownMenuItem(
                                child: new Text(location),
                                value: location,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAvailability = value;
                              });
                            },
                            value: selectedAvailability,
                            hint: Text(
                              "Available/Not",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Column(
                        children: [
                          new Text("Patients remaining"),
                          new DropdownButton<String>(
                            underline: new Container(),
                            items: noOfPatientsOptions
                                .map<DropdownMenuItem<String>>((location) {
                              return DropdownMenuItem(
                                child: new Text(location),
                                value: location,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedNoOfPatients = value;
                              });
                            },
                            value: selectedNoOfPatients,
                            hint: Text('0'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Material(
                elevation: 10.0,
                shadowColor: Colors.black,
                borderRadius: BorderRadius.circular(10),
                child: TextField(
                  controller: _commentTextFieldController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    hintText: 'Add Comment',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: primaryColor2,
              ),
              margin: const EdgeInsets.only(top: 20.0),
              child: MaterialButton(
                child: new Text(
                  'Add Comment',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  addComment();
                },
              ),
            ),
            Divider(),
            responseCode == 200
                ? Expanded(
                    child: FutureBuilder<List<Comment>>(
                      future: allComments,
                      builder:
                          (context, AsyncSnapshot<List<Comment>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Text(
                                snapshot.data.length.toString() + ' Comments',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) => Card(
                                    child: new ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text(
                                            snapshot.data[index].date,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          SizedBox(height: 2),
                                          InkWell(
                                            onTap: () {
                                              if (snapshot.data[index].repId !=
                                                  int.parse(payload['id']))
                                                fetchUser(snapshot
                                                        .data[index].repId)
                                                    .then((user) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        CustomDialog(
                                                      name: user.fname +
                                                          " " +
                                                          user.lname,
                                                      pictureURL:
                                                          user.pictureURL,
                                                      email: user.email,
                                                      title: user
                                                          .medicalRepPositionTitle,
                                                      companyName:
                                                          user.workedOnCompany,
                                                      visitsCount:
                                                          user.visitsCount,
                                                      likeCount: user.likeCount,
                                                      disLikeCount:
                                                          user.disLikeCount,
                                                      buttonText: "Close",
                                                    ),
                                                  );
                                                });
                                            },
                                            child: Text(
                                              snapshot.data[index].fname +
                                                  " " +
                                                  snapshot.data[index].lname,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(snapshot.data[index].content),
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
                                                    color: snapshot.data[index]
                                                            .isActive
                                                        ? (snapshot.data[index]
                                                                .isLiker
                                                            ? Colors.green
                                                            : Colors.grey)
                                                        : Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    likeAndDislike(
                                                        snapshot.data[index],
                                                        true);
                                                  },
                                                ),
                                                InkWell(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              left: 4.0,
                                                              right: 4.0),
                                                      child: Text(snapshot
                                                          .data[index]
                                                          .likesCount
                                                          .toString()),
                                                    ),
                                                    onTap: () {
                                                      if (snapshot.data[index]
                                                              .likesCount >
                                                          0) {
                                                        return displayBottomSheet(
                                                            context,
                                                            snapshot
                                                                .data[index].id,
                                                            true);
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
                                                    color: snapshot.data[index]
                                                            .isActive
                                                        ? (snapshot.data[index]
                                                                .isDisLiker
                                                            ? Colors.red
                                                            : Colors.grey)
                                                        : Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    likeAndDislike(
                                                        snapshot.data[index],
                                                        false);
                                                  },
                                                ),
                                                InkWell(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              left: 4.0,
                                                              right: 4.0),
                                                      child: Text(snapshot
                                                          .data[index]
                                                          .dislikesCount
                                                          .toString()),
                                                    ),
                                                    onTap: () {
                                                      if (snapshot.data[index]
                                                              .dislikesCount >
                                                          0) {
                                                        return displayBottomSheet(
                                                            context,
                                                            snapshot
                                                                .data[index].id,
                                                            false);
                                                      }
                                                    }),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.report,
                                                color: snapshot
                                                        .data[index].isActive
                                                    ? Colors.red
                                                    : Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  )
                : Center(child: Text('No Visits')),
          ],
        ),
      ),
    );
  }

  Future<http.Response> addComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));

    Map data = {
      "content": _commentTextFieldController.text,
      "medicalRepId": int.parse(payload['id']),
      "DoctorId": widget.doctor.id,
      "type": true
    };
    //encode Map to JSON
    var body = json.encode(data);

    final response = await http.post(
      URL + 'api/visit/',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer " + jwt,
        'Accept': 'application/json',
        "Content-Type": "application/json"
      },
      body: body,
    );
    if (response.statusCode == 200) {
      setState(() {
        allComments = fetchVisits();
      });
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) addComment();
    }
  }

  Future<User> fetchUser(userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    print(jwt);
    jwtRefresh = prefs.getString('jwtRefresh');
    payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
    final response =
        await http.get(URL + 'api/rep/' + userID.toString(), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer " + jwt,
      'Accept': 'application/json'
    });
    if (response.statusCode == 200) {
      User user = User.fromJson(json.decode(response.body));
      return user;
    } else if (response.statusCode == 401) {
      if (refreshToken() == 200) fetchUser(userID);
    } else {
      throw Exception('Failed to load user');
    }
  }
}

// USER POPUP
class CustomDialog extends StatelessWidget {
  final String name, pictureURL, email, title, companyName, buttonText;
  final int visitsCount, likeCount, disLikeCount;

//  final Image image;

  CustomDialog({
    @required this.name,
    @required this.pictureURL,
    @required this.email,
    @required this.title,
    @required this.companyName,
    @required this.visitsCount,
    @required this.likeCount,
    @required this.disLikeCount,
    @required this.buttonText,
//    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
          padding: EdgeInsets.only(
            top: 70.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 66.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
              if (companyName != Null)
                Text(
                  "Company: " + companyName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              if (email != Null)
                Text(
                  "Email: " + email,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          color: primaryColor1,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Text(
                            'Visits Count',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            visitsCount.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          color: primaryColor2,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: Colors.white,
                                size: 16.0,
                              ),
                              Text(
                                ' Count',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            likeCount.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          color: primaryColor1,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thumb_down,
                                color: Colors.white,
                                size: 16.0,
                              ),
                              Text(
                                ' Count',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            disLikeCount.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
        //...top circlular image part,
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
//            backgroundImage: AssetImage('assets/images/user.png'),
            backgroundColor: Colors.white,
            radius: 66.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: pictureURL == null
                  ? Image.asset('assets/images/user.png')
                  : Image.network(URL + pictureURL),
            ),
          ),
        ),
      ],
    );
  }
}
