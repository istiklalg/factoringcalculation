import 'package:faktoring_hesap/screens/about_app_screen.dart';
import 'package:faktoring_hesap/screens/cek_list_screen.dart';
import 'package:faktoring_hesap/screens/factoring_calculator_screen.dart';
import 'package:faktoring_hesap/screens/main_screen.dart';
import 'package:faktoring_hesap/screens/cek_add_screens.dart';
import 'package:faktoring_hesap/screens/payment_instrument_detail_screens.dart';
import 'package:faktoring_hesap/screens/payment_instrument_list_screens.dart';
import 'package:faktoring_hesap/screens/payment_instrument_use_screen.dart';
import 'package:faktoring_hesap/screens/portfolio_detail_screen.dart';
import 'package:faktoring_hesap/screens/portfolio_list_screen.dart';
import 'package:faktoring_hesap/screens/senet_add_screen.dart';
import 'package:faktoring_hesap/screens/senet_list_screen.dart';
import 'package:faktoring_hesap/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// @author : istiklal

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("tr"),
        const Locale("us")
      ],
      routes: {
        "/": (BuildContext context) => SplashScreen(),
        "/home": (BuildContext context) => MainScreen(),
        "/allinstruments": (BuildContext context) => PaymentInstrumentListScreen(),
        "/cek": (BuildContext context) => CekListScreen(),
        "/senet": (BuildContext context) => SenetListScreen(),
        "/portfolios": (BuildContext context) => PortfolioListScreen(),
        "/portfoliodetails": (BuildContext context) => PortfolioDetail(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/addingcek": (BuildContext context) => CekAddScreen(),
        "/addingsenet": (BuildContext context) => SenetAddScreen(),
        "/cekdetails" : (BuildContext context) => CekDetailsScreen(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/senetdetails": (BuildContext context) => SenetDetailsScreen(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/factoringCalculator": (BuildContext context) => FactoringCalculatorScreen(),
        "/cekuseform": (BuildContext context) => CekFactoringUsage(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/senetuseform": (BuildContext context) => SenetFactoringUsage(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/portfoliouseform": (BuildContext context) => PortfolioFactoringUsage(key:key, id:(ModalRoute.of(context).settings.arguments)),
        "/aboutappscreen": (BuildContext context) => AboutAppScreen(),
      }
    );
  }

}
