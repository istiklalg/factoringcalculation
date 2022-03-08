import 'dart:async';

import 'package:faktoring_hesap/data/dbHelper.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';

import 'senet_bloc.dart';
import 'cek_bloc.dart';

/// @author : istiklal

class PortfolioBloc{
  final dbHelper = DbHelper();
  var portfolios = []; //List<Portfolio>();
  var portfolio;
  var portfolioElements = []; //List<PaymentInstrument>();
  var elements;

  // Stream to handle portfolio list;
  final portfolioStreamController = StreamController.broadcast();
  Stream get outPortfolio => portfolioStreamController.stream;
  Sink get _inAdd => portfolioStreamController.sink;
  // Stream to handle portfolio elements;
  StreamController<List<PaymentInstrument>> elementsStreamController = StreamController<List<PaymentInstrument>>.broadcast();
  Stream get outElements => elementsStreamController.stream;
  Sink get _inElements => elementsStreamController.sink;
  // Stream to handle portfolio details;
  final detailStreamController = StreamController.broadcast();
  Stream get outDetails => detailStreamController.stream;
  Sink get _inDetails => detailStreamController.sink;


  PortfolioBloc() {
    portfolios = getAll();
    outPortfolio.listen((portfolios) { portfolios = getAll(); });
  }


  List<Portfolio> getAll() {
    dbHelper.getPortfolios().then((data) {
      portfolios = data;
      _inAdd.add(portfolios);
    });
    return portfolios;
  }

  Portfolio getDetails(String id) {
    var i = int.tryParse(id);
    dbHelper.getPortfolio(i).then((data) {
      portfolio = data;
      _inDetails.add(portfolio);
    });
    return portfolio;
  }

  List<PaymentInstrument> getAllElements(String id) {
    var i = int.tryParse(id);
    dbHelper.getPortfolioElements(i).then((data) {
      portfolioElements = data;
      _inElements.add(portfolioElements);
    });
    return portfolioElements;
  }

  List<PaymentInstrument> getElementsWithoutStream(String id) {
    var i = int.tryParse(id);
    dbHelper.getPortfolioElements(i).then((data) => elements = data);
    return elements;
  }

  void createPortfolio(Portfolio portfolio) {
    var dbResult = dbHelper.insertPortfolio(portfolio);
    _inAdd.add(getAll());
  }

  void updatePortfolio(Portfolio selected) {
    int dbResult;
    dbHelper.updatePortfolio(selected).then((value) {
        dbResult = value;
        _inDetails.add(getDetails(selected.id.toString()));
      }
    );
  }

  void discardElementFromPortfolio(PaymentInstrument selected, int id) {
    if(selected is Cek){
      cekBloc.discardFromPortfolio(selected);
    }else if(selected is Senet) {
      senetBloc.discardFromPortfolio(selected);
    }
    _inDetails.add(getDetails(id.toString()));
    _inElements.add(getAllElements(id.toString()));
  }

  void deletePortfolioOnly(Portfolio selected) {
    var list = getAllElements(selected.id.toString());
    var result = 1;
    if(list!=null && list.length!=0) {
      for(var i=0;i<list.length;i++){
        if(list[i] is Cek){
          cekBloc.discardFromPortfolio(list[i]);
        } else if(list[i] is Senet) {
          senetBloc.discardFromPortfolio(list[i]);
        }
      }
    } else {
    }
    var dbResult = dbHelper.deletePortfolioOnly(selected.id);
    _inAdd.add(portfolios);
  }

  int deletePortfolioWithContent(Portfolio selected) {
    var list = getAllElements(selected.id.toString());
    var result = 1;
    if(list!=null && list.length!=0) {
      for(var i=0;i<list.length;i++){
        if(list[i] is Cek){
          dbHelper.deleteCek(list[i].id).then((data) {
            if(data==0){print("**** ${list[i].id} id'li çek silinemedi, hata oluştu : $data");}
            result = data*result;
          });
        } else if(list[i] is Senet) {
          dbHelper.deleteSenet(list[i].id).then((data) {
            if(data==0){print("**** ${list[i].id} id'li senet silinemedi, hata oluştu : $data");}
            result = data*result;
          });
        }
      }
    } else {
      print("**** PortfolioBloc deletePortfolioWithContent : PORTFÖY BOŞ");
    }
    dbHelper.deletePortfolioOnly(selected.id).then((value) {
      result = value*result;
    });
    _inAdd.add(portfolios);
    return result;
  }

  Map<String, dynamic>calculatePortfolioDetails(Portfolio object){
    var elements;
    var content;
    dbHelper.getPortfolioElements(object.id).then((data) {
      elements = data;
      var weightedDay = 0.0;
      var totalVolume = 0.0;
      var deprecatedVolume = 0.0;
      if(elements.length==0) {
        object.elementCount = 0;
        object.averageExpiration = 0.0;
      }else if(elements == null) {
        object.elementCount = 0;
        object.averageExpiration = 0.0;
      }else {

        object.elementCount = elements.length;
        for (var element in elements) {

          if(element.isDeprecated) {
            deprecatedVolume += element.amount;
          }else {
            if (element is Cek) {
              weightedDay +=
                  element.amount * getDaysToExpiration(element.expirationDate);
            } else if (element is Senet) {
              weightedDay += element.amount *
                  (getDaysToExpiration(element.expirationDate) + 2.0);
            }
          }
          totalVolume += element.amount;
        }
        object.averageExpiration =
            roundDouble(weightedDay / (totalVolume - deprecatedVolume), 2);
        object.totalVolume = totalVolume;
        object.lastDayOfPayment = elements[0].expirationDate;
        object.leftPayment = (totalVolume-deprecatedVolume);
      }
      content = {
        "portfolio": object, "averageExpiration": object.averageExpiration,
        "elementsList": elements,
      };
      _inDetails.add(object);
    });
    if(object.totalVolume == 0 && (object.averageExpiration == null)) {
      dbHelper.updatePortfolio(object);
    }

    return content;
  }

  void dispose() {
    portfolioStreamController.close();
    elementsStreamController.close();
    detailStreamController.close();
  }


}


final portfolioBloc = PortfolioBloc();