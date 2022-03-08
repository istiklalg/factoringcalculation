
import 'package:faktoring_hesap/widgets/common_widgets.dart';
import 'package:faktoring_hesap/utilities/factoring_functions.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// @author : istiklal

class FactoringCalculatorScreen extends StatelessWidget {
  final GlobalKey<FormBuilderState> _factoringCalculateFormKey =
      GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calculate_outlined),
            Text("  Faktoring Hesaplama", style: TextStyle(fontSize: 18.0))
          ],
        )
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: factoringArgumentsForm(context),
      ),
    );
  }

  factoringArgumentsForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          FormBuilder(
              key: _factoringCalculateFormKey,
              initialValue: {"expirationDate": DateTime.now()},
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    validator: [FormBuilderValidators.required(context)],
                    name: "expirationDate",
                    inputType: InputType.date,
                    helpText: "Ödeme Aracı İçin Vade Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Vade"),
                    onChanged: (value) => _factoringCalculateFormKey
                        .currentState.value["expirationDate"] = value,
                  ),
                  buildFormTextFields(_factoringCalculateFormKey, "Tutar (TL)",
                      "amount", TextInputType.number,
                      validateWith: [FormBuilderValidators.required()]),
                  buildFormTextFields(
                      _factoringCalculateFormKey,
                      "Yıllık Faiz Oranı (%)",
                      "interestRate",
                      TextInputType.number),
                  buildFormTextFields(
                      _factoringCalculateFormKey,
                      "Komisyon Oranı (%)",
                      "commissionRate",
                      TextInputType.number,
                      initValue: 0),
                  buildFormTextFields(_factoringCalculateFormKey,
                      "İşlem Masrafı (TL)", "processFee", TextInputType.number,
                      initValue: 100),
                ],
              )),
          ElevatedButton(
            child: Text("HESAPLA"),
            onPressed: () => openResultPopUp(context),
          )
        ],
      ),
    );
  }

  openResultPopUp(BuildContext context) {
    var result = Map<String, double>();
    if (_factoringCalculateFormKey.currentState.saveAndValidate()) {
      if (_factoringCalculateFormKey.currentState.value["amount"] != "") {
        result = valueOnToday(
            double.tryParse(
                _factoringCalculateFormKey.currentState.value["amount"]),
            double.tryParse(
                _factoringCalculateFormKey.currentState.value["interestRate"]),
            _factoringCalculateFormKey.currentState.value["expirationDate"],
            commissionRate: double.tryParse(_factoringCalculateFormKey
                .currentState.value["commissionRate"]),
            processFee: double.tryParse(
                _factoringCalculateFormKey.currentState.value["processFee"]));
      }
    }
    Alert(
        context: context,
        title: "Faktoring Detayları",
        content: Column(
          children: [
            Center(
              child: Column(
              children: [
                DataTable(
                    horizontalMargin: 3.0,
                    headingRowHeight: 15.0,
                    dataRowHeight: 20.0,
                    dividerThickness: 0.5,
                    columnSpacing: 40.0,
                    columns: [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text(""))
                    ],
                    rows: [
                      tableRowMaker(
                          "Alacak Vadesi",
                          _factoringCalculateFormKey
                              .currentState.value["expirationDate"]),
                      tableRowMaker("İşlem Tutarı", result["amount"],
                          symbol: "TL"),
                      tableRowMaker(
                          "İşlem Vadesi",
                          getPaymentDay(_factoringCalculateFormKey
                              .currentState.value["expirationDate"])),
                      // tableRowMaker("Risk Vadesi", result["paymentDate"]),
                      tableRowMaker("Vadeye Kalan", result["daysToPayment"],
                          symbol: "GÜN"),
                      tableRowMaker("Faiz", result["interestFee"],
                          symbol: "TL"),
                      tableRowMaker("Komisyon", result["commissionFee"],
                          symbol: "TL"),
                      tableRowMaker("BSMV", result["taxFee"], symbol: "TL"),
                      tableRowMaker("Toplam Maliyet", result["totalCostRate"],
                          symbol: "%"),
                      tableRowMaker("NET ÖDEME", result["totalPayment"],
                          symbol: "TL"),
                    ])
              ],
            ))
          ],
        ),
        buttons: [
          DialogButton(
            child: Text(
              "KAPAT",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ]).show();
  }

  openResultPop(BuildContext context) {
    return AlertDialog(
      title: Text("Faktoring Detayları"),
      content: Column(
        children: [Center(child: CircularProgressIndicator())],
      ),
    );
  }
}
