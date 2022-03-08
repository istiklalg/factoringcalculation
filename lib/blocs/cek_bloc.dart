import 'dart:async';

import 'package:faktoring_hesap/data/dbHelper.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/portfolio.dart';

/// @author : istiklal

class CekBloc {
  final dbHelper = DbHelper();
  //var cekler = List<Cek>();
  var cekler = [];
  var cek = Cek(DateTime.now(), 0);

  // stream to handle list;
  final cekStreamController = StreamController.broadcast();
  Sink get _inAdd => cekStreamController.sink;
  Stream get outCek => cekStreamController.stream;
  // stream to handle details;
  StreamController<Cek> detailStreamController = StreamController<Cek>.broadcast();
  Sink get _inCekDetails => detailStreamController.sink;
  Stream get cekDetails => detailStreamController.stream;


  CekBloc() {
    cekler = getAll();
    outCek.listen((cekler) {cekler = getAll();});
  }


  List<Cek> getAll() {
    dbHelper.getCeks().then((data) { cekler = data; _inAdd.add(cekler); });
    return cekler;
  }

  void addCek(Cek cek) {
    var dbResult = dbHelper.insertCek(cek);
    _inAdd.add(getAll());
  }

  void deleteCek(Cek cek) {
    var dbResult = dbHelper.deleteCek(cek.id);
    _inAdd.add(getAll());
  }

  Cek getDetails(String id) {
    var i = int.tryParse(id);
    var futureCek = dbHelper.getCek(i);
    futureCek.then((data) { cek = data; _inCekDetails.add(cek); });
    return cek;
  }

  void updateCek(Cek selected) {
    int dbResult;
    dbHelper.updateCek(selected).then((value) {
      dbResult = value;
      _inCekDetails.add(selected);
      _inAdd.add(cekler);
    });
  }

  void addToPortfolio(Cek selected, int portfolioId) {
    selected.portfolioId = portfolioId;
    Portfolio portfolio;

    dbHelper.getPortfolio(portfolioId).then((value) {
      portfolio = value;
      portfolio.totalVolume += selected.amount;
      dbHelper.updatePortfolio(portfolio);
    });
    int dbResult;
    dbHelper.updateCek(selected).then((value) {
      dbResult = value;
      _inCekDetails.add(selected);
      _inAdd.add(cekler);
    });
  }

  void discardFromPortfolio(Cek selected) {
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
    dbHelper.updateCek(selected).then((value) {
      dbResult = value;
      _inCekDetails.add(selected);
      _inAdd.add(cekler);
    });
  }


  void dispose() {
    cekStreamController.close();
    detailStreamController.close();
  }
}

final cekBloc = CekBloc();
