import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Widget _home;
String _imagePath;
int _duration;

Map<dynamic, Widget> _outputAndHome = {};

class AnimatedSplash extends StatefulWidget {
  AnimatedSplash(
      {@required String imagePath,
      @required Widget home,
      int duration,
      Map<dynamic, Widget> outputAndHome}) {
    assert(duration != null);
    assert(home != null);
    assert(imagePath != null);

    _home = home;
    _duration = duration;
    _imagePath = imagePath;
    _outputAndHome = outputAndHome;
  }

  @override
  _AnimatedSplashState createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  AnimationController _animationBackgroundController;
  Animation _animationBackground;

  @override
  void initState() {
    super.initState();
    if (_duration < 1000) _duration = 2000;

    _animationBackgroundController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animationBackground = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationBackgroundController, curve: Curves.easeInCirc),
    );
    _animationBackgroundController.forward();

    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInCirc),
    );

    _animationBackgroundController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _animationBackgroundController.dispose();
  }

  navigator(home, context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => home));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: _duration)).then((value) {
      navigator(_home, context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animationBackground,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/splashBackground.jpg'),
            ),
          ),
          child: FadeTransition(
            opacity: _animation,
            child: Center(
              child: SizedBox(
                height: 400.0,
                child: Image.asset(_imagePath),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
