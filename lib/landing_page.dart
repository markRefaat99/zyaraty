import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/login.dart';
import 'package:zyaraty/staticData.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Image.asset(
              'assets/images/logo_white.png',
              width: 25.0,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/frontImage.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
//            Flexible(flex: 2, child: SizedBox(height: 400)),
            Flexible(
              flex: 4,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 700,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1600),
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 1.0,
                ),
                items: [
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/landing_page/1.png',
                          height: 200.0,
                        ),
                        Text(
                          "The first software specially designed for medical reps to facilitate their visits.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: primaryColor3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/landing_page/2.png',
                          height: 200.0,
                        ),
                        Text(
                          "Search our database for a Doctor , Hospital and Medical center.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: primaryColor3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/landing_page/3.png',
                          height: 200.0,
                        ),
                        Text(
                          "Add a real time feedback about visit status.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: primaryColor3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 50,
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/landing_page/4.png',
                          height: 200.0,
                        ),
                        Text(
                          "Participate in daily / monthly competitions, follow your ranking and win our prizes.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: primaryColor3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor2,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35.0, vertical: 10.0),
                      child: Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
