

import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';

/// @author : istiklal

Map<String, double> valueOnToday(
    var amount,
    double interestRate,
    DateTime expirationDate,
    {
      var commissionRate:0.0,
      var processFee:0.0,
      var valor:1.0,
      double taxRate:0.05,
      DateTime usingDate}) {

  double daysToPayment;
  // delay for fridays
  if (usingDate != null) {
    daysToPayment = getDaysToExpiration(expirationDate, usingDate: usingDate);
    print("faktoring usingDate : $usingDate");
  }else{
    daysToPayment = getDaysToExpiration(expirationDate);
    print("faktoring usingDate : $usingDate");
  }

  if(expirationDate.weekday == 5) {
    daysToPayment = daysToPayment + 3 + valor;
  } else {
    daysToPayment = daysToPayment + valor;  // for payment delay on banking operations
  }


  // taxRate = 0.05 => BSMV Rate in Turkey
  interestRate = interestRate/100;
  commissionRate = commissionRate/100;


  var interestPerDay = interestRate/360;
  var commissionPerDay = commissionRate/daysToPayment;
  var feePerDay = processFee/daysToPayment;
  var totalPerDay = interestPerDay+commissionPerDay+feePerDay;

  var interestFee = amount*interestPerDay*daysToPayment;
  var commissionFee = amount*commissionPerDay*daysToPayment;
  var taxFee = (interestFee+commissionFee+processFee)*taxRate;
  var totalCost = (interestFee+commissionFee+processFee+taxFee);
  var totalCostRate = ((totalCost/amount)*100)*(360/daysToPayment);

  var totalPayment = amount - totalCost;

  var content = {
    "amount":roundDouble(amount, 2),
    "daysToPayment":daysToPayment,
    "interestFee":roundDouble(interestFee, 2),
    "commissionFee":roundDouble(commissionFee, 2),
    "taxFee":roundDouble(taxFee, 2),
    "totalCost":roundDouble(totalCost, 2),
    "totalCostRate":roundDouble(totalCostRate, 2),
    "totalPayment":roundDouble(totalPayment, 2),
  };

  return content;

}

Map<String, double> interestRateForPayment(
    var amount,
    DateTime expirationDate,
    double totalPayment,
    {double taxRate:0.05, var processFee:0.0, var valor:2.0}) {

  // taxRate = 0.05 BSMV Rate in Turkey
  var daysToPayment = getDaysToExpiration(expirationDate);
  daysToPayment = daysToPayment + valor;  // for payment delay on banking operations

  var totalCost = amount - totalPayment;
  var baseAmount = (totalCost/1.05);
  var taxFee = totalCost - baseAmount;
  var totalRatePerYear = (((baseAmount - processFee)/amount)*100)*(360/daysToPayment);


  var content = {
    "taxRate":roundDouble(taxRate, 2),
    "taxFee":roundDouble(taxFee, 2),
    "totalCost":roundDouble(totalCost, 2),
    "totalRatePerYear":roundDouble(totalRatePerYear, 2),
  };

  return content;
}

Map<String, dynamic> portfolioValueOnToday(
    Portfolio object, List<PaymentInstrument> elements,
    double interestRate,
    {
      var commissionRate:0.0,
      var processFee:0.0,
      var valor:1.0,
      double taxRate:0.05,
      DateTime usingDate}) {

  var result;
  var count = elements.length;
  var elementProcessFee = roundDouble(processFee/count, 2);
  var amount = object.totalVolume;

  var dayDifference = DateTime.now().difference(usingDate).inDays;
  var daysToPayment = object.averageExpiration + dayDifference + valor;

  var interestFee = 0.0;
  var commissionFee = 0.0;
  var taxFee = 0.0;
  var totalCost = 0.0;
  var totalPayment = 0.0;

  for(var element in elements) {

    if(element is Cek) {

      result = valueOnToday(
          element.amount, interestRate, element.expirationDate,
          commissionRate: commissionRate, processFee: elementProcessFee,
          usingDate: usingDate
      );
      element.usingDate = usingDate;
      element.interestRate = interestRate;
      element.interestFee = result["interestFee"];
      element.commissionRate = commissionRate;
      element.commissionFee = result["commissionFee"];
      element.daysToPayment = result["daysToPayment"];
      element.taxFee = result["taxFee"];
      element.receivedPayment = result["totalPayment"];
      element.isUsed = true;

    }else if(element is Senet) {

      result = valueOnToday(
          element.amount, interestRate, element.expirationDate,
          commissionRate: commissionRate, processFee: elementProcessFee,
          valor: 3.0, usingDate: usingDate
      );
      element.usingDate = usingDate;
      element.interestRate = interestRate;
      element.interestFee = result["interestFee"];
      element.commissionRate = commissionRate;
      element.commissionFee = result["commissionFee"];
      element.daysToPayment = result["daysToPayment"];
      element.taxFee = result["taxFee"];
      element.receivedPayment = result["totalPayment"];
      element.isUsed = true;

    }
    interestFee += result["interestFee"];
    commissionFee += result["commissionFee"];
    taxFee += result["taxFee"];
    totalCost += result["totalCost"];
    totalPayment += result["totalPayment"];

  }

  var totalCostRate = ((totalCost/amount)*100)*(360/daysToPayment);


  var content = {
    "elements":elements,
    "elementCount":count,
    "amount":roundDouble(amount, 2),
    "daysToPayment":daysToPayment,
    "interestRate":interestRate,
    "interestFee":roundDouble(interestFee, 2),
    "commissionRate":commissionRate,
    "commissionFee":roundDouble(commissionFee, 2),
    "taxFee":roundDouble(taxFee, 2),
    "totalCost":roundDouble(totalCost, 2),
    "totalCostRate":roundDouble(totalCostRate, 2),
    "totalPayment":roundDouble(totalPayment, 2),
  };

  return content;

}

void savePortfolioUsageInfo(
    Portfolio object,
    Map<String, dynamic> formMap,
    Map<String, dynamic> result) {
  object.usingDate = formMap["usingDate"];
  object.interestFee = result["interestFee"];
  object.interestRate = result["interestRate"];
  object.commissionFee = result["commissionFee"];
  object.commissionRate = result["commissionRate"];
  object.totalCostRate = result["totalCostRate"];
  object.receivedPayment = result["totalPayment"];
  object.processFee = double.tryParse(formMap["processFee"]);
  object.isUsed = true;
  portfolioBloc.updatePortfolio(object);
}