import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/landing_page.dart';
import 'package:zyaraty/staticData.dart';
import 'package:zyaraty/packages/CustomSplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zyaraty',
      theme: ThemeData(
        fontFamily: 'Bahij',
        primaryColor: primaryColor1,
        primarySwatch: primaryWhite,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplash(
        imagePath: 'assets/images/logo.png',
        home: LandingPage(),
        duration: 3000,
      ),
    );
  }
}

getNavigation(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var jwt = prefs.getString('jwt');
  if (jwt == null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => MenuProvider(),
          child: HomeScreen(),
        ),
      ),
    );
  }
}
