import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/a/home_screen.dart';
import 'package:zyaraty/staticData.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/frontImage.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _customCard(
                  imageUrl: "latest_activites.png",
                  item: "Latest Activities",
                  context: context,
                  index: 2,
                ),
                _customCard(
                  imageUrl: "visits.png",
                  item: "Visits",
                  context: context,
                  index: 1,
                ),
                _customCard(
                  imageUrl: "winners.png",
                  item: "Winners",
                  context: context,
                  index: 4,
                ),
                _customCard(
                  imageUrl: "competition.png",
                  item: "Competition",
                  context: context,
                  index: 3,
                ),
                _customCard(
                  imageUrl: "about.png",
                  item: "Info",
                  context: context,
                  index: 5,
                ),
                _customCard(
                  imageUrl: "contact_us.png",
                  item: "Contact Us",
                  context: context,
                  index: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

_customCard({String imageUrl, String item, StatefulElement context, index}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 1.0),
    child: Material(
      elevation: 5.0,
      shadowColor: primaryColor3,
      child: MaterialButton(
        onPressed: () {
          Provider.of<MenuProvider>(context, listen: false)
              .updateCurrentPage(index);
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width / 4.5),
              Image.asset(
                "assets/home_images/" + imageUrl,
                width: 50,
                height: 50,
                color: primaryColor1,
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 15),
              Center(
                child: Text(
                  item,
                  style: TextStyle(fontSize: 20, color: primaryColor3),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
