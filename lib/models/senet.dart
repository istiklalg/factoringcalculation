import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';

/// @author : istiklal

class Senet extends PaymentInstrument{
  int id, portfolioId, registerNumber, drawerTaxNumber, giverTaxNumber;
  String companyUsed, imgUrl, drawer, giver;
  DateTime usingDate, issuedDate, expirationDate, receiptDate;
  double daysToPayment, interestFee, commissionFee, interestRate, taxFee,
      commissionRate, receivedPayment, amount;
  bool isDeprecated=false, isPaid=false;

  Senet(this.expirationDate, this.amount);

  Senet.withDrawerAndGiver(
    this.expirationDate,
    this.amount,
    this.drawer,
    this.drawerTaxNumber,
    this.giver,
    this.giverTaxNumber);

  Senet.withAllDetails(
    this.registerNumber,
    this.drawerTaxNumber,
    this.giverTaxNumber,
    this.imgUrl,
    this.drawer,
    this.giver,
    this.expirationDate,
    this.receiptDate,
    this.amount);

  Map<String, dynamic> toMap() {
    daysToPayment = takeDaysToPayment(expirationDate);
    if (daysToPayment<-3){
      isDeprecated = true;
      isPaid = true;
    }
    var map = {
      "id":id,
      "portfolioId":portfolioId,
      "registerNumber":registerNumber,
      "drawerTaxNumber":drawerTaxNumber,
      "giverTaxNumber":giverTaxNumber,
      "companyUsed":companyUsed,
      "imgUrl":imgUrl,
      "drawer":drawer,
      "giver":giver,
      "usingDate":usingDate.toString(),
      "issuedDate":issuedDate.toString(),
      "expirationDate":expirationDate.toString(),
      "receiptDate":receiptDate.toString(),
      "interestFee":interestFee,
      "commissionFee":commissionFee,
      "interestRate":interestRate,
      "commissionRate":commissionRate,
      "receivedPayment":receivedPayment,
      "amount":double.tryParse(amount.toString()),
      "isUsed":boolToInt(isUsed),
      "isDeprecated":boolToInt(isDeprecated),
      "isPaid":boolToInt(isPaid)
    };
    return map;
  }

  Senet.fromMap(dynamic o) {
    this.id=o["id"];
    this.portfolioId=o["portfolioId"];
    this.registerNumber=int.tryParse(o["registerNumber"].toString());
    this.drawerTaxNumber=int.tryParse(o["drawerTaxNumber"].toString());
    this.giverTaxNumber=int.tryParse(o["giverTaxNumber"].toString());
    this.companyUsed=o["companyUsed"];
    this.imgUrl=o["imgUrl"];
    this.drawer=o["drawer"];
    this.giver=o["giver"];
    this.usingDate=DateTime.tryParse(o["usingDate"]);
    this.issuedDate=DateTime.tryParse(o["issuedDate"]);
    this.expirationDate=DateTime.tryParse(o["expirationDate"]);
    this.receiptDate=DateTime.tryParse(o["receiptDate"]);
    this.interestFee=double.tryParse(o["interestFee"].toString());
    this.commissionFee=double.tryParse(o["commissionFee"].toString());
    this.interestRate=double.tryParse(o["interestRate"].toString());
    this.commissionRate=double.tryParse(o["commissionRate"].toString());
    this.receivedPayment=double.tryParse(o["receivedPayment"].toString());
    this.amount=double.tryParse(o["amount"].toString());
    this.isUsed=booleanConvert(o["isUsed"]);
    this.isDeprecated=booleanConvert(o["isDeprecated"]);
    this.isPaid=booleanConvert(o["isPaid"]);
    this.daysToPayment = takeDaysToPayment(this.expirationDate);
  }

}