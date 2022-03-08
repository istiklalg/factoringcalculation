import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';

/// @author : istiklal

class Cek extends PaymentInstrument{
  int id, portfolioId, serialNumber, drawerTaxNumber, giverTaxNumber;
  String companyUsed, imgUrl, bankName,bankBrunchName, drawer, giver;
  DateTime usingDate, expirationDate, receiptDate;
  double daysToPayment, interestFee, commissionFee, interestRate, taxFee,
      commissionRate, receivedPayment, amount;
  bool isDeprecated=false, isPaid=false;

  Cek(this.expirationDate, this.amount);

  Cek.withDrawerAndGiver(
      this.expirationDate,
      this.amount,
      this.drawer,
      this.drawerTaxNumber,
      this.giver,
      this.giverTaxNumber);

  Cek.withAllDetails(
      this.serialNumber,
      this.drawerTaxNumber,
      this.giverTaxNumber,
      this.imgUrl,
      this.drawer,
      this.giver,
      this.bankName,
      this.bankBrunchName,
      this.expirationDate,
      this.receiptDate,
      this.amount);

  Map<String, dynamic> toMap() {
    daysToPayment = takeDaysToPayment(expirationDate);
    if (daysToPayment<0){
      isDeprecated = true;
      isPaid = true;
    }
    var map = {
      "id":id,
      "portfolioId":portfolioId,
      "serialNumber":serialNumber,
      "drawerTaxNumber":drawerTaxNumber,
      "giverTaxNumber":giverTaxNumber,
      "companyUsed":companyUsed,
      "imgUrl":imgUrl,
      "bankName":bankName,
      "bankBrunchName":bankBrunchName,
      "drawer":drawer,
      "giver":giver,
      "usingDate":usingDate.toString(),
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

  Cek.fromMap(dynamic o) {
    this.id=o["id"];
    this.portfolioId=o["portfolioId"];
    this.serialNumber=int.tryParse(o["serialNumber"].toString());
    this.drawerTaxNumber=int.tryParse(o["drawerTaxNumber"].toString());
    this.giverTaxNumber=int.tryParse(o["giverTaxNumber"].toString());
    this.companyUsed=o["companyUsed"];
    this.imgUrl=o["imgUrl"];
    this.bankName=o["bankName"];
    this.bankBrunchName=o["bankBrunchName"];
    this.drawer=o["drawer"];
    this.giver=o["giver"];
    this.usingDate = DateTime.tryParse(o["usingDate"]);
    this.expirationDate = DateTime.parse(o["expirationDate"]);
    this.daysToPayment = takeDaysToPayment(this.expirationDate);
    this.receiptDate = DateTime.tryParse(o["receiptDate"]);
    this.interestFee=double.tryParse(o["interestFee"].toString());
    this.commissionFee=double.tryParse(o["commissionFee"].toString());
    this.interestRate=double.tryParse(o["interestRate"].toString());
    this.commissionRate=double.tryParse(o["commissionRate"].toString());
    this.receivedPayment=double.tryParse(o["receivedPayment"].toString());
    this.amount=double.tryParse(o["amount"].toString());
    this.isUsed = booleanConvert(o["isUsed"]);
    this.isDeprecated = booleanConvert(o["isDeprecated"]);
    this.isPaid = booleanConvert(o["isPaid"]);
  }


}