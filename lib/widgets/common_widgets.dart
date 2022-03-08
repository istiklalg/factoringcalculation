//import 'dart:ui';

//import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/utilities/widget_condition_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

/// @author : istiklal

final localNumber = NumberFormat("###,###.0#", "en_US");


class GraphParts {
  double amount;
  Color lineColor;
  String rankKey;

  GraphParts(this.amount, this.lineColor, this.rankKey);

}

// List<CircularSegmentEntry>

Map<String, dynamic> generateGraphData(List<PaymentInstrument> list) {
  double older = 0;
  double today = 0;
  double future = 0;
  double usedAmount = 0;

  for (var object in list) {

    var conditions = expirationConditionControl(object);
    switch (conditions["filterVar"]) {
      case -1 :
        older = older + object.amount;
        break;
      case 0 :
        today = today + object.amount;
        break;
      case 1 :
        today = today + object.amount;
        break;
      default :
        future = future + object.amount;
    }
    if(object.isUsed && conditions["filterVar"] >= 0) {
      usedAmount = usedAmount + object.amount;
    }
  }
  var grandTotal = older + today + future;
  var olders = CircularSegmentEntry(older, Colors.grey, rankKey:"Vadesi Geçmiş");
  var todays = CircularSegmentEntry(today, Colors.red, rankKey: "Tahsil Oluyor");
  var futures = CircularSegmentEntry(future, Colors.blue, rankKey: "İleri Vadeli");
  var content = {
    "segmentEntries": [olders, todays, futures],
    "older": older, "today": today, "future": future,
    "totalAmount": grandTotal, "usedAmount":usedAmount
  };
  return content;
}

tableRowMaker(String title, var value,
    {Color rowColor = Colors.black, String symbol: ""}) {


  var result;
  if (value.runtimeType == double) {
    result = localNumber.format(value);
  } else if (value.runtimeType == DateTime) {
    result = makeLocalDate(value);
  } else if (value.runtimeType == int || value.runtimeType == String) {
    result = value;
  } else if (value.runtimeType == bool) {
    switch(value){
      case true:
        result = "EVET";
        break;
      case false:
        result = "HAYIR";
    }
  } else if (value == null) {
    result = "-";
  }

  return DataRow(cells: [
    DataCell(Text(
      title,
      style: TextStyle(color: rowColor),
    )),
    DataCell(Align(
        alignment: Alignment.centerRight,
        child: Text(
          "$result $symbol",
          style: TextStyle(color: rowColor),
        )))
  ]);
}

// date time picker builder;
buildFormDateTimePicker(
    GlobalKey<FormBuilderState> _formKey,
    String _attribute, String _labelText,
    {InputType inputType : InputType.date, List validatorList}){

  return FormBuilderDateTimePicker(
    validator: validatorList,
    name: _attribute,
    inputType: inputType,
    format: DateFormat("dd-MM-yyyy"),
    decoration: InputDecoration(labelText: _labelText),
    onChanged: (value) => _formKey.currentState.value[_attribute] = value,
  );
}

buildFormTextFields(GlobalKey<FormBuilderState> _formKey, String labelText,
    String _attribute, TextInputType keyboardType,
    {List<String Function(dynamic)> validateWith, var initValue}) {
  return FormBuilderTextField(
    initialValue: initValue == null ? "" : initValue.toString(),
    name: _attribute,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: labelText,
    ),
    onChanged: (value) => _formKey.currentState.value[_attribute] = value,
  );
}
