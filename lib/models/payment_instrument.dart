import 'package:faktoring_hesap/utilities/object_utilities.dart';

/// @author : istiklal

class PaymentInstrument{
  int id, portfolioId;
  DateTime expirationDate;
  double amount, receivedPayment;
  bool isUsed = false;

  PaymentInstrument();

  double daysToExpiration() {
    return takeDaysToPayment(expirationDate);
  }

}