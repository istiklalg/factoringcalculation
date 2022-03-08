import 'dart:async';

import 'package:faktoring_hesap/data/dbHelper.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';

/// @author : istiklal

class PaymentInstrumentBloc{

  final dbHelper = DbHelper();
  // var _list = List<PaymentInstrument>();
  var _list = [];

  // ignore: close_sinks
  final instrumentStreamController = StreamController.broadcast();

  Stream get outInstrument => instrumentStreamController.stream;
  Sink get _inAdd => instrumentStreamController.sink;

  PaymentInstrumentBloc() {
    _list = getAll();
    outInstrument.listen((_list) { _list = getAll(); });
  }

  List<PaymentInstrument> getAll() {
    dbHelper.getAllInstrument().then((data) { _list = data; _inAdd.add(_list);});
    return _list;
  }

  void sortInstrumentList() {
    _list.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  List<PaymentInstrument> filteredInstrumentList(List<PaymentInstrument> _liste) {
    if (_liste.length > 0) {
      for (var element in _liste) {
        if(element.daysToExpiration() < -1) {
          _liste.remove(element);
        }
      }
      _liste.sort((a, b) => a.daysToExpiration().compareTo(b.daysToExpiration()));
    }
    return _liste;
  }


}

final paymentInstrumentBloc = PaymentInstrumentBloc();