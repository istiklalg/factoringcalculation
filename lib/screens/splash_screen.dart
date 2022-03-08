
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

/// @author : istiklal

class SplashScreen extends StatefulWidget {

  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>{

  var _screenSize;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 6000), () => Navigator.pushReplacementNamed(context, "/home"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: allContent(context),
    );
  }

  allContent(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.grey,
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          finestImage(context),
          appImage(context),
          brandImage(context),
        ],
      ),
    );
  }

  appImage(BuildContext context) {
    return Container(
      width: _screenSize.width,
      height: _screenSize.height*0.30,
      color: Colors.white,
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Image.asset("assets/images/app_icon_design.png")),
    );
  }

  finestImage(BuildContext context) {
    return Container(
      width: _screenSize.width,
      height: _screenSize.height*0.30,
      color: Colors.white,
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Image.asset("assets/images/finest_logo.png")),
    );
  }

  brandImage(BuildContext context) {
    return Container(
      width: _screenSize.width,
      height: _screenSize.height*0.30,
      color: Colors.white,
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Image.asset("assets/images/brand_logo.png")),
    );
  }

}
// -----------------------------------------------------------------------------
