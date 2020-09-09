import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/register.dart';
import 'package:zyaraty/staticData.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  Future<Map<String, dynamic>> sigin(String email, String password) async {
    var dio = Dio(BaseOptions(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (_) => true,
    ));
    dio.options.baseUrl = URL;
    var body = new Map<String, dynamic>();
//    body['email'] = 'engamaeae@gmail.com';
//    body['password'] = '15304560am';
//    body['email'] = 'mark@mm.com';
//    body['password'] = 'qwerty';
    body['email'] = _emailController.text;
    body['password'] = _passwordController.text;

    FormData formData = new FormData.fromMap(body);
    final response = await dio.post(
      URL + 'api/rep/login',
      data: formData,
    );

    if (response.statusCode == 400) {
      print("error");
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
      return {'success': true, 'message': 'Successfuly login!'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey[100]),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400]),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400]),
                                      ),
                                    ),
                                  )
                                ],
                              ),
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
                                sigin(_emailController.text,
                                    _passwordController.text);
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          Row(
                            children: [
                              new Text("Don't have an account ? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Register()),
                                  );
                                },
                                child: Text(
                                  "Signup",
                                  style: TextStyle(color: primaryColor1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
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
