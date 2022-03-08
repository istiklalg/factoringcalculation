//import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/utilities/factoring_functions.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';
import 'package:faktoring_hesap/utilities/widget_condition_utilities.dart';
import 'package:faktoring_hesap/widgets/common_widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// @author : istiklal

class CekFactoringUsage extends StatelessWidget {
  final localNumber = NumberFormat("###,###.0#", "en_US");

  final String id;
  CekFactoringUsage({Key key, @required this.id}) : super(key: key);

  final GlobalKey<FormBuilderState> _cekFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calculate_outlined),
            Text(" Çek Faktoring Detayları", style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
      body: formScreenBuilder(context, id),
    );
  }

  formScreenBuilder(BuildContext context, String id) {
    final cek = cekBloc.getDetails(id);
    return streamCekForm(context, cek);
  }

  streamCekForm(BuildContext context, Cek cek) {
    return StreamBuilder(
        stream: cekBloc.cekDetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return cekUsageForm(context, snapshot.data);
        });
  }

  cekUsageForm(BuildContext context, Cek cek) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FormBuilder(
                key: _cekFormKey,
                initialValue: {
                  "usingDate":
                      cek.usingDate != null ? cek.usingDate : DateTime.now(),
                  "amount": cek.amount.toString(),
                  "expirationDate": cek.expirationDate,
                  "interestRate":
                      "${cek.interestRate != null ? cek.interestRate : "0"}",
                  "commissionRate":
                      "${cek.commissionRate != null ? cek.commissionRate : "0"}",
                  "processFee": "100",
                  "companyUsed":
                      "${cek.companyUsed != null ? cek.companyUsed : ""}",
                },
                child: Column(
                  children: [
                    FormBuilderDateTimePicker(
                      name: "usingDate",
                      inputType: InputType.date,
                      helpText: "Faktoring Kullandığınız Tarihi Seçin",
                      format: DateFormat("dd-MM-yyyy"),
                      decoration: InputDecoration(labelText: "Kullanım Tarihi"),
                      onChanged: (value) =>
                          _cekFormKey.currentState.value["usingDate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "amount",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Çek Tutarı (TL)",
                      ),
                      onChanged: (value) =>
                          _cekFormKey.currentState.value["amount"] = value,
                    ),
                    FormBuilderDateTimePicker(
                      name: "expirationDate",
                      inputType: InputType.date,
                      helpText: "Çek Vadesini Seçin",
                      format: DateFormat("dd-MM-yyyy"),
                      decoration: InputDecoration(labelText: "Çek Vadesi"),
                      onChanged: (value) => _cekFormKey
                          .currentState.value["expirationDate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "interestRate",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Yıllık Faiz Oranı (%)",
                      ),
                      onChanged: (value) => _cekFormKey
                          .currentState.value["interestRate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "commissionRate",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Komisyon Oranı (%)",
                      ),
                      onChanged: (value) => _cekFormKey
                          .currentState.value["commissionRate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "processFee",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "İşlem Ücreti (TL)",
                      ),
                      onChanged: (value) =>
                          _cekFormKey.currentState.value["processFee"] = value,
                    ),
                    FormBuilderTextField(
                      name: "companyUsed",
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Kullanılan Faktoring Şirketi",
                      ),
                      onChanged: (value) =>
                          _cekFormKey.currentState.value["companyUsed"] = value,
                    ),
                  ],
                )),
            ElevatedButton(
              child: Text("HESAPLA"),
              onPressed: () => openResultsInAlert(context, cek),
            )
          ],
        ),
      ),
    );
  }

  openResultsInAlert(BuildContext context, Cek cek) {
    var formMap = Map<String, dynamic>();
    var result = Map<String, double>();
    if (_cekFormKey.currentState.saveAndValidate()) {
      formMap = _cekFormKey.currentState.value;

      result = valueOnToday(double.tryParse(formMap["amount"]),
          double.tryParse(formMap["interestRate"]), formMap["expirationDate"],
          commissionRate: double.tryParse(formMap["commissionRate"]),
          processFee: double.tryParse(formMap["processFee"]),
          usingDate: formMap["usingDate"]);

    } else {
      print(
          "*** usage Form validation error: ${_cekFormKey.currentState.value}");
    }
    Alert(
        context: context,
        title: "Faktoring Detayları\nİşlem Tarihi : ${makeLocalDate(formMap["usingDate"])}",
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
                              formMap["expirationDate"]),
                          tableRowMaker("İşlem Tutarı", result["amount"],
                              symbol: "TL"),
                          tableRowMaker(
                              "İşlem Vadesi",
                              getPaymentDay(formMap["expirationDate"])),
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
            color: Colors.orange,
            child: Text(
              "DÜZELT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          DialogButton(
            color: Colors.green,
            child: Text(
              "KAYDET",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              saveUsingDetailsToCek(cek, formMap, result);
              Navigator.pop(context, true);
              Navigator.pop(context, true);
            },
          ),
        ]).show();
  }

  saveUsingDetailsToCek(Cek cek, Map<String, dynamic> formMap, Map<String, double> result) {
    if(formMap["companyUsed"] != null && formMap["companyUsed"] != "") {
      cek.companyUsed = formMap["companyUsed"];
    }
    cek.usingDate =  formMap["usingDate"];
    cek.interestRate = double.tryParse(formMap["interestRate"]);
    cek.interestFee = result["interestFee"];
    cek.commissionRate = double.tryParse(formMap["commissionRate"]);
    cek.commissionFee = result["commissionFee"];
    cek.receivedPayment = result["totalPayment"];
    cek.isUsed = true;

    cekBloc.updateCek(cek);

  }

}








class SenetFactoringUsage extends StatelessWidget {
  final localNumber = NumberFormat("###,###.0#", "en_US");

  final String id;
  SenetFactoringUsage({Key key, @required this.id}) : super(key: key);

  final GlobalKey<FormBuilderState> _senetFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calculate_outlined),
            Text(" Senet Faktoring Detayları", style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
      body: formScreenBuilder(context, id),
    );
  }

  formScreenBuilder(BuildContext context, String id) {
    final senet = senetBloc.getDetails(id);
    return streamSenetForm(context, senet);
  }

  streamSenetForm(BuildContext context, Senet senet) {
    return StreamBuilder(
        stream: senetBloc.senetDetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return senetUsageForm(context, snapshot.data);
        });
  }

  senetUsageForm(BuildContext context, Senet senet) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FormBuilder(
                key: _senetFormKey,
                initialValue: {
                  "usingDate":
                  senet.usingDate != null ? senet.usingDate : DateTime.now(),
                  "amount": senet.amount.toString(),
                  "expirationDate": senet.expirationDate,
                  "interestRate":
                  "${senet.interestRate != null ? senet.interestRate : "0"}",
                  "commissionRate":
                  "${senet.commissionRate != null ? senet.commissionRate : "0"}",
                  "processFee": "100",
                  "companyUsed":
                  "${senet.companyUsed != null ? senet.companyUsed : ""}",
                },
                child: Column(
                  children: [
                    FormBuilderDateTimePicker(
                      name: "usingDate",
                      inputType: InputType.date,
                      helpText: "Faktoring Kullandığınız Tarihi Seçin",
                      format: DateFormat("dd-MM-yyyy"),
                      decoration: InputDecoration(labelText: "Kullanım Tarihi"),
                      onChanged: (value) =>
                      _senetFormKey.currentState.value["usingDate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "amount",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Senet Tutarı (TL)",
                      ),
                      onChanged: (value) =>
                      _senetFormKey.currentState.value["amount"] = value,
                    ),
                    FormBuilderDateTimePicker(
                      name: "expirationDate",
                      inputType: InputType.date,
                      helpText: "Senet Vadesini Seçin",
                      format: DateFormat("dd-MM-yyyy"),
                      decoration: InputDecoration(labelText: "Senet Vadesi"),
                      onChanged: (value) => _senetFormKey
                          .currentState.value["expirationDate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "interestRate",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Yıllık Faiz Oranı (%)",
                      ),
                      onChanged: (value) => _senetFormKey
                          .currentState.value["interestRate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "commissionRate",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Komisyon Oranı (%)",
                      ),
                      onChanged: (value) => _senetFormKey
                          .currentState.value["commissionRate"] = value,
                    ),
                    FormBuilderTextField(
                      name: "processFee",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "İşlem Ücreti (TL)",
                      ),
                      onChanged: (value) =>
                      _senetFormKey.currentState.value["processFee"] = value,
                    ),
                    FormBuilderTextField(
                      name: "companyUsed",
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Kullanılan Faktoring Şirketi",
                      ),
                      onChanged: (value) =>
                      _senetFormKey.currentState.value["companyUsed"] = value,
                    ),
                  ],
                )),
            ElevatedButton(
              child: Text("HESAPLA"),
              onPressed: () => openResultsInAlert(context, senet),
            )
          ],
        ),
      ),
    );
  }

  openResultsInAlert(BuildContext context, Senet senet) {
    var formMap = Map<String, dynamic>();
    var result = Map<String, double>();
    if (_senetFormKey.currentState.saveAndValidate()) {
      formMap = _senetFormKey.currentState.value;

      result = valueOnToday(double.tryParse(formMap["amount"]),
          double.tryParse(formMap["interestRate"]), formMap["expirationDate"].add(Duration(days: 3)),
          commissionRate: double.tryParse(formMap["commissionRate"]),
          processFee: double.tryParse(formMap["processFee"]),
          valor: 3.0,
          usingDate: formMap["usingDate"]);

    } else {
      print(
          "*** usage Form validation error: ${_senetFormKey.currentState.value}");
    }
    Alert(
        context: context,
        title: "Faktoring Detayları\nİşlem Tarihi : ${makeLocalDate(formMap["usingDate"])}",
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
                              formMap["expirationDate"]),
                          tableRowMaker("İşlem Tutarı", result["amount"],
                              symbol: "TL"),
                          tableRowMaker(
                              "İşlem Vadesi",
                              getPaymentDay(formMap["expirationDate"]).add(Duration(days: 3))),
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
            color: Colors.orange,
            child: Text(
              "DÜZELT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          DialogButton(
            color: Colors.green,
            child: Text(
              "KAYDET",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              saveUsingDetailsToSenet(senet, formMap, result);
              Navigator.pop(context, true);
              Navigator.pop(context, true);
            },
          ),
        ]).show();
  }

  saveUsingDetailsToSenet(Senet senet, Map<String, dynamic> formMap, Map<String, double> result) {
    if(formMap["companyUsed"] != null && formMap["companyUsed"] != "") {
      senet.companyUsed = formMap["companyUsed"];
    }
    senet.usingDate =  formMap["usingDate"];
    senet.interestRate = double.tryParse(formMap["interestRate"]);
    senet.interestFee = result["interestFee"];
    senet.commissionRate = double.tryParse(formMap["commissionRate"]);
    senet.commissionFee = result["commissionFee"];
    senet.receivedPayment = result["totalPayment"];
    senet.isUsed = true;

    senetBloc.updateSenet(senet);

  }

}






class PortfolioFactoringUsage extends StatelessWidget {

  final blocPortfolio = PortfolioBloc();

  final localNumber = NumberFormat("###,###.0#", "en_US");

  final String id;
  PortfolioFactoringUsage({Key key, @required this.id}) : super(key: key);



  final GlobalKey<FormBuilderState> _portfolioFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calculate_outlined),
            Text(" Portföy Faktoring Detayları", style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
      body: formScreenBuilder(context, id),
    );
  }

  formScreenBuilder(BuildContext context, String id) {
    //final portfolio = blocPortfolio.getDetails(id);
    return streamPortfolioForm(context);
  }

  streamPortfolioForm(BuildContext context) {
    return StreamBuilder(
        stream: blocPortfolio.outDetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return portfolioUsageForm(context, snapshot.data);
        });
  }

  portfolioUsageForm (
      BuildContext context,
      Portfolio object,) {
    var elements = blocPortfolio.getElementsWithoutStream(object.id.toString());
    blocPortfolio.calculatePortfolioDetails(object);

    if(object.averageExpiration == 0.0) {
        return Center(child: CircularProgressIndicator(),);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FormBuilder(
              key: _portfolioFormKey,
              initialValue: {
                "usingDate": object.usingDate != null ? object.usingDate : DateTime.now(),
                "totalVolume": object.totalVolume.toString(),
                "averageExpiration": object.averageExpiration.toString(),
                "interestRate": "${object.interestRate != null ? object.interestRate : "0"}",
                "commissionRate": "${object.commissionRate != null ? object.commissionRate : "0"}",
                "processFee": "${object.processFee != null ? object.processFee : "100"}",
                "companyUsed": "${object.companyUsed != null ? object.companyUsed : ""}",
              },
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    name: "usingDate",
                    inputType: InputType.date,
                    helpText: "Faktoring Kullandığınız Tarihi Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Kullanım Tarihi"),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["usingDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "totalVolume",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Portföy Toplam Tutarı (TL)",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["totalVolume"] = value,
                  ),
                  FormBuilderTextField(
                    name: "averageExpiration",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Portföyün Ortalama Vadesi (GÜN)",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["averageExpiration"] = value,
                  ),
                  FormBuilderTextField(
                    name: "interestRate",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Yıllık Faiz Oranı (%)",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["interestRate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "commissionRate",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Komisyon Oranı (%)",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["commissionRate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "processFee",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "İşlem Ücreti (TL)",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["processFee"] = value,
                  ),
                  FormBuilderTextField(
                    name: "companyUsed",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Kullanılan Faktoring Şirketi",),
                    onChanged: (value) =>
                    _portfolioFormKey.currentState.value["companyUsed"] = value,
                  ),
                ],
              )
            ),
            ElevatedButton(
              child: Text("HESAPLA"),
              onPressed: () => openResultsInAlert(context, object, elements),
            )
          ],
        ),
      ),
    );
  }

  openResultsInAlert(BuildContext context, Portfolio object, List<PaymentInstrument> elements) {
    var formMap, result = Map<String, dynamic>();
    if(_portfolioFormKey.currentState.saveAndValidate()) {
      formMap = _portfolioFormKey.currentState.value;
      result = portfolioValueOnToday(
          object, elements, double.tryParse(formMap["interestRate"]),
          commissionRate: double.tryParse(formMap["commissionRate"]),
          processFee: double.tryParse(formMap["processFee"]),
          usingDate: formMap["usingDate"]);

    } else {
      print("*** usage Form validation error: ${_portfolioFormKey.currentState.value}");
    }

    Alert(
      context: context,
      title: "Faktoring Detayları\nİşlem Tarihi : ${makeLocalDate(formMap["usingDate"])}",
      content: Center(
        child: Column(
          children: [
            DataTable(
                horizontalMargin: 3.0,
                headingRowHeight: 15.0,
                dataRowHeight: 20.0,
                dividerThickness: 0.5,
                columnSpacing: 40.0,
                columns: [
                  DataColumn(label: Text("Kullanılan Şirket")),
                  DataColumn(label: Text("${formMap["companyUsed"]!=null?formMap["companyUsed"]:""}"))
                ],
                rows: [
                  tableRowMaker("İşlem Tutarı", result["amount"], symbol: "TL"),
                  tableRowMaker("Ortalama Vade", result["daysToPayment"], symbol: "GÜN"),
                  tableRowMaker("Çek / Senet Sayısı", result["elementCount"], symbol: "ADET"),

                  tableRowMaker("Faiz", result["interestFee"], symbol: "TL"),
                  tableRowMaker("Komisyon", result["commissionFee"], symbol: "TL"),
                  tableRowMaker("BSMV", result["taxFee"], symbol: "TL"),
                  tableRowMaker("Toplam Maliyet", result["totalCostRate"], symbol: "%"),
                  tableRowMaker("Toplam Kesinti", result["totalCost"], symbol: "TL"),

                  tableRowMaker("NET ÖDEME", result["totalPayment"], symbol: "TL"),
                ])
          ],
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.orange,
          child: Text(
            "DÜZELT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        DialogButton(
          color: Colors.green,
          child: Text(
            "KAYDET",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            saveUsingDetailsToPortfolioAndElements(object, formMap, result);
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          },
        ),
      ]).show();

  }

  saveUsingDetailsToPortfolioAndElements(
      Portfolio object,
      Map<String, dynamic> formMap,
      Map<String, dynamic> result) {
    if(formMap["companyUsed"] != null && formMap["companyUsed"] != "") {
      object.companyUsed = formMap["companyUsed"];
    }
    for(var element in result["elements"]) {
      if(element is Cek) {
        if(formMap["companyUsed"] != null && formMap["companyUsed"] != "") {
          element.companyUsed = formMap["companyUsed"];
        }
        cekBloc.updateCek(element);
      }else if(element is Senet) {
        if(formMap["companyUsed"] != null && formMap["companyUsed"] != "") {
          element.companyUsed = formMap["companyUsed"];
        }
        senetBloc.updateSenet(element);
      }
    }
    savePortfolioUsageInfo(object, formMap, result);
  }

}