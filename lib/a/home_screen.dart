import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:zyaraty/a/menu_page.dart';
import 'package:zyaraty/a/page_structure.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zyaraty/packages/CustomDrawer.dart';
import 'package:provider/provider.dart';
import 'package:zyaraty/screens/contactUs.dart';
import 'package:zyaraty/editProfile.dart';
import 'package:zyaraty/screens/home.dart';
import 'package:zyaraty/screens/competition.dart';
import 'package:zyaraty/screens/info.dart';
import 'package:zyaraty/screens/lastActivites.dart';
import 'package:zyaraty/screens/notifications.dart';
import 'package:zyaraty/screens/visits.dart';
import 'package:zyaraty/screens/winners.dart';
import 'package:zyaraty/models/menuItem.dart';

class HomeScreen extends StatefulWidget {
  static List<MenuItem> drawerMenu = [
    MenuItem("Home", Icons.home, 0, HomePage()),
    MenuItem("Visits", Icons.format_list_bulleted, 1, VisitsPage()),
    MenuItem("Latest Activities", MdiIcons.history, 2, LastActivitiesPage()),
    MenuItem("Competition", Icons.verified_user, 3, CompetitionPage()),
    MenuItem("Winners", MdiIcons.trophy, 4, WinnersPage()),
    MenuItem("Info", Icons.info, 5, InfoPage()),
    MenuItem("Contact us", Icons.call, 6, ContactPage()),
    MenuItem("Notifications", Icons.call, 7, NotificationsPage()),
  ];

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drawerController = ZoomDrawerController();

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _drawerController.close();
      },
      onPanUpdate: (details) {
        if (details.delta.dx < 0) {
          _drawerController.close();
        }
      },
      child: ZoomDrawer(
        controller: _drawerController,
        menuScreen: MenuScreen(
          HomeScreen.drawerMenu.sublist(0, 7),
          callback: _updatePage,
          current: _currentPage,
        ),
        mainScreen: GestureDetector(
          child: PageStructure(),
//          onPanUpdate: (details) {
//            if (details.delta.dx < 6) {
//              _drawerController.toggle();
//            }
//          },
        ),
        borderRadius: 20.0,
        showShadow: true,
        angle: 0.0,
        slideWidth: MediaQuery.of(context).size.width * 0.65,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.easeInQuad,
      ),
    );
  }

  void _updatePage(index) {
    Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(index);
    _drawerController.toggle();
  }
}

class MenuProvider extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void updateCurrentPage(int index) {
    if (index != currentPage) {
      _currentPage = index;
      notifyListeners();
    }
  }
}
