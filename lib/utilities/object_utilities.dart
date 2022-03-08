
import 'dart:math';


/// @author : istiklal

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

double takeDaysToPayment(DateTime expirationDate) {
  Duration difference;
  double daysToPayment, decimalDay, doubleDay;
  difference = expirationDate.difference(DateTime.now());
  decimalDay = difference.inHours/24;

  daysToPayment = roundDouble(decimalDay, 2);
  return daysToPayment;

}

double getDaysToExpiration(DateTime expirationDate, {DateTime usingDate}) {
  double daysToExpiration;
  if (usingDate!=null){
    daysToExpiration = (expirationDate.difference(usingDate).inDays + 1).toDouble();
  }else{
    daysToExpiration = (expirationDate.difference(DateTime.now()).inDays + 1).toDouble();
  }
  // delay for weekend;
  switch(expirationDate.weekday) {
    case 6 :
      daysToExpiration = daysToExpiration + 2;
      break;
    case 7 :
      daysToExpiration = daysToExpiration + 1;
  }
  return daysToExpiration;
}

DateTime getPaymentDay(DateTime expirationDate) {
  DateTime paymentDay;
  // delay for weekend;
  switch(expirationDate.weekday) {
    case 5 :
      paymentDay = expirationDate.add(Duration(days: 3));
      break;
    case 6 :
      paymentDay = expirationDate.add(Duration(days: 3));
      break;
    case 7 :
      paymentDay = expirationDate.add(Duration(days: 2));
      break;
    default :
      paymentDay = expirationDate.add(Duration(days: 1));
  }
  return paymentDay;
}

int boolToInt(bool value) {
  var result;
  switch(value){
    case true:
      result = 1;
      break;
    case false:
      result = 0;
  }
  return result;
}

bool booleanConvert(int value) {
  if(value==0) {
    return false;
  } else {
    return true;
  }
}

bool hasData(value) {
  if(value != null && value != ""){
    return true;
  } else {
    return false;
  }
}


