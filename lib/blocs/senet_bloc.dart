import 'dart:async';

import 'package:faktoring_hesap/data/dbHelper.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/senet.dart';

/// @author : istiklal

class SenetBloc{
  final dbHelper = DbHelper();
  var senetler = []; //List<Senet>();
  var senet = Senet(DateTime.now(), 0);
  var senetCount = 0;

  // Stream to handle list;
  final senetStreamController = StreamController.broadcast();
  Stream get outSenet => senetStreamController.stream;
  Sink get _inAdd => senetStreamController.sink;
  // Stream to handle details;
  StreamController<Senet> detailStreamController = StreamController<Senet>.broadcast();
  Stream get senetDetails => detailStreamController.stream;
  Sink get _inSenetDetails => detailStreamController.sink;


  SenetBloc() {
    senetler = getAll();
    outSenet.listen((senetler) { senetler = getAll(); });
  }


  List<Senet> getAll() {
    dbHelper.getSenets().then((data) { senetler = data; senetCount = data.length; _inAdd.add(senetler);});
    return senetler;
  }

  void addSenet(Senet senet) {
    var dbResult = dbHelper.insertSenet(senet);
    _inAdd.add(getAll());
  }

  void deleteSenet(Senet senet) {
    var dbResult = dbHelper.deleteSenet(senet.id);
    _inAdd.add(getAll());
  }

  Senet getDetails(String id) {
    var i = int.tryParse(id);
    var futureSenet = dbHelper.getSenet(i);
    futureSenet.then((data) { senet = data; _inSenetDetails.add(senet);});
    return senet;
  }

  void updateSenet(Senet selected) {
    int dbResult;
    dbHelper.updateSenet(selected).then((value) {
      dbResult = value;
      _inSenetDetails.add(selected);
      _inAdd.add(senetler);
    });
  }

  void addToPortfolio(Senet selected, int portfolioId) {
    selected.portfolioId = portfolioId;
    Portfolio portfolio;

    dbHelper.getPortfolio(portfolioId).then((value) {
      portfolio = value;
      portfolio.totalVolume += selected.amount;
      dbHelper.updatePortfolio(portfolio);
    });
    int dbResult;
    dbHelper.updateSenet(selected).then((value) {
      dbResult = value;
      _inSenetDetails.add(selected);
      _inAdd.add(senetler);
    });
  }

  void discardFromPortfolio(Senet selected) {
    Portfolio portfolio;

    dbHelper.getPortfolio(selected.portfolioId).then((value) {
      portfolio = value;
      portfolio.totalVolume -= selected.amount;
      if(portfolio.totalVolume>0.0) {
        dbHelper.updatePortfolio(portfolio);
      }else{
        portfolio.totalVolume = 0.0;
        dbHelper.updatePortfolio(portfolio);
      }
    });
    selected.portfolioId = null;
    int dbResult;
    dbHelper.updateSenet(selected).then((value) {
      dbResult = value;
      _inSenetDetails.add(selected);
      _inAdd.add(senetler);
    });
  }



  void dispose() {
    senetStreamController.close();
    detailStreamController.close();
  }

}


final senetBloc = SenetBloc();
