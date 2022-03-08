import 'package:faktoring_hesap/utilities/object_utilities.dart';

/// @author : istiklal

class Portfolio{
  int id, elementCount = 0;
  String portfolioName, companyUsed;
  DateTime usingDate, lastDayOfPayment;
  double interestFee, commissionFee, interestRate, commissionRate, totalCostRate,
      receivedPayment = 0.0, totalVolume = 0.0, currentRiskVolume = 0.0,
      averageExpiration = 0.0, leftPayment = 0.0, processFee = 100.0;
  bool isUsed=false, isDeprecated=false;

  Portfolio(this.portfolioName);

  Map<String, dynamic> toMap() {
    if(lastDayOfPayment!=null) {
      var daysToPayment = lastDayOfPayment.difference(DateTime.now());
      if (daysToPayment.inDays < 0) {
        isDeprecated = true;
      }
    }
    var map = {
      "id":id,
      "portfolioName":portfolioName,
      "companyUsed":companyUsed,
      "usingDate":usingDate.toString(),
      "interestFee":interestFee,
      "commissionFee":commissionFee,
      "interestRate":interestRate,
      "commissionRate":commissionRate,
      "receivedPayment":receivedPayment,
      "totalVolume":totalVolume,
      "currentRiskVolume":currentRiskVolume,
      "isUsed":boolToInt(isUsed),
      "isDeprecated":boolToInt(isDeprecated)
    };
    return map;
  }

  Portfolio.fromMap(dynamic o) {
    this.id=o["id"];
    this.portfolioName=o["portfolioName"];
    this.companyUsed=o["companyUsed"];
    this.usingDate=DateTime.tryParse(o["usingDate"]);
    this.interestFee=double.tryParse(o["interestFee"].toString());
    this.commissionFee=double.tryParse(o["commissionFee"].toString());
    this.interestRate=double.tryParse(o["interestRate"].toString());
    this.commissionRate=double.tryParse(o["commissionRate"].toString());
    this.receivedPayment=double.tryParse(o["receivedPayment"].toString());
    this.totalVolume=double.tryParse(o["totalVolume"].toString());
    this.currentRiskVolume=double.tryParse(o["currentRiskVolume"].toString());
    this.isUsed=booleanConvert(o["isUsed"]);
    this.isDeprecated=booleanConvert(o["isDeprecated"]);
  }

}