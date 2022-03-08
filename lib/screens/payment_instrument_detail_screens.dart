
//import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

/// @author : istiklal

class CekDetailsScreen extends StatelessWidget{

  final localNumber = NumberFormat("###,###.0#", "en_US");

  final String id;
  CekDetailsScreen({Key key, @required this.id}) : super(key: key);

  final GlobalKey<FormBuilderState> _cekDetailsFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit_outlined),
            Text("  ${this.id}  kayıt nolu çek", style: TextStyle(fontSize: 20.0)),
          ],
        ),
      ),
      body: cekDetailBuilder(context, this.id)
    );
  }

  cekDetailBuilder(BuildContext context, String id) {
    final cek = cekBloc.getDetails(id);
    return streamDetailSceneCek(context, cek);
  }


  streamDetailSceneCek(BuildContext context, Cek cek) {
    return StreamBuilder(
      stream: cekBloc.cekDetails,
      builder: (context, snapshot ) {
        if(!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return cekDetailsForm(context, snapshot.data);
      });
  }

  cekDetailsForm(BuildContext context, Cek cek) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FormBuilder(
              key: _cekDetailsFormKey,
              initialValue: {
                "expirationDate": cek.expirationDate,
                "amount": cek.amount.toString(),
                "receiptDate": cek.receiptDate!=null?cek.receiptDate:DateTime.now(),
                "serialNumber": cek.serialNumber!=null?cek.serialNumber.toString():"",
                "bankName":cek.bankName!=null?cek.bankName:"",
                "bankBrunchName": cek.bankBrunchName!=null?cek.bankBrunchName:"",
                "drawer": cek.drawer!=null?cek.drawer:"",
                "drawerTaxNumber": cek.drawerTaxNumber!=null?cek.drawerTaxNumber.toString():"",
                "giver": cek.giver!=null?cek.giver:"",
                "giverTaxNumber": cek.giverTaxNumber!=null?cek.giverTaxNumber.toString():"",
              },
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    name: "expirationDate",
                    inputType: InputType.date,
                    helpText: "Çek Vadesini Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Çek Vadesi"),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["expirationDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "amount",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Çek Tutarı (TL)",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["amount"] = value,
                  ),
                  FormBuilderDateTimePicker(
                    name: "receiptDate",
                    inputType: InputType.date,
                    helpText: "Çeki Aldığınız Tarihi Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Çeki Aldığın Tarih"),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["receiptDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "serialNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Çek Seri Numarası",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["serialNumber"] = value,
                  ),
                  FormBuilderTextField(
                    name: "bankName",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Çek Bankası",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["bankName"] = value,
                  ),
                  FormBuilderTextField(
                    name: "bankBrunchName",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Çek Şubesi",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["bankBrunchName"] = value,
                  ),
                  FormBuilderTextField(
                    name: "drawer",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Keşideci",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["drawer"] = value,
                  ),
                  FormBuilderTextField(
                    name: "drawerTaxNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Keşideci Vergi No",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["drawerTaxNumber"] = value,
                  ),
                  FormBuilderTextField(
                    name: "giver",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Son Ciranta",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["giver"] = value,
                  ),
                  FormBuilderTextField(
                    name: "giverTaxNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Son Ciranta Vergi No",
                    ),
                    onChanged: (value) =>
                    _cekDetailsFormKey.currentState.value["giverTaxNumber"] = value,
                  ),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                  child: Text("İPTAL", style: TextStyle(color: Colors.white),),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                  child: Text("KAYDET", style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    saveChangesForCek(cek);
                    Navigator.pop(context, true);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void saveChangesForCek(Cek cek) {
    var formMap = Map<String, dynamic>();
    if(_cekDetailsFormKey.currentState.saveAndValidate()){
      formMap = _cekDetailsFormKey.currentState.value;
      cek.expirationDate = formMap["expirationDate"];
      cek.amount = double.tryParse(formMap["amount"]);
      cek.receiptDate = formMap["receiptDate"];
      cek.serialNumber = int.tryParse(formMap["serialNumber"]);
      cek.bankName = formMap["bankName"];
      cek.bankBrunchName = formMap["bankBrunchName"];
      cek.drawer = formMap["drawer"];
      cek.drawerTaxNumber = int.tryParse(formMap["drawerTaxNumber"]);
      cek.giver = formMap["giver"];
      cek.giverTaxNumber = int.tryParse(formMap["giverTaxNumber"]);

      cekBloc.updateCek(cek);

    }else{
      print("*** save Changes Error : $formMap");
    }

  }



}








class SenetDetailsScreen extends StatelessWidget {

  final localNumber = NumberFormat("###,###.0#", "en_US");

  final String id;
  SenetDetailsScreen({Key key, @required this.id }) : super(key:key);

  final GlobalKey<FormBuilderState> _senetDetailsFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit_outlined),
            Text("  ${this.id}  kayıt nolu senet", style: TextStyle(fontSize: 20.0)),
          ],
        ),
      ),
      body: senetDetailBuilder(context, this.id),
    );
  }

  senetDetailBuilder(BuildContext context, String id) {
    final senet = senetBloc.getDetails(id);
    return streamDetailSceneSenet(context, senet);
  }

  streamDetailSceneSenet(BuildContext context, Senet senet) {
    return StreamBuilder(
        stream: senetBloc.senetDetails,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return senetDetailsForm(context, snapshot.data);
        });
  }

  senetDetailScene(Senet senet) {
    return Column(
      children: [
        Center(child: Text("${localNumber.format(senet.amount)} tutarlı ${senet.id} ID li Senet"),)
      ],
    );
  }

  senetDetailsForm(BuildContext context, Senet senet) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            FormBuilder(
              key: _senetDetailsFormKey,
              initialValue: {
                "expirationDate": senet.expirationDate,
                "amount": senet.amount.toString(),
                "receiptDate": senet.receiptDate!=null?senet.receiptDate:DateTime.now(),
                "registerNumber": senet.registerNumber!=null?senet.registerNumber.toString():"",
                "drawer": senet.drawer!=null?senet.drawer:"",
                "drawerTaxNumber": senet.drawerTaxNumber!=null?senet.drawerTaxNumber.toString():"",
                "issuedDate": senet.issuedDate!=null?senet.issuedDate:DateTime.now(),
                "giver": senet.giver!=null?senet.giver:"",
                "giverTaxNumber": senet.giverTaxNumber!=null?senet.giverTaxNumber.toString():"",
              },
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    name: "expirationDate",
                    inputType: InputType.date,
                    helpText: "Senet Vadesini Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Senet Vadesi"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["expirationDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "amount",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Senet Tutarı (TL)"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["amount"] = value,
                  ),
                  FormBuilderDateTimePicker(
                    name: "receiptDate",
                    inputType: InputType.date,
                    helpText: "Senedi Aldığınız Tarihi Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Senedi Aldığın Tarih"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["receiptDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "registerNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Senet Kayıt Numarası"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["registerNumber"] = value,
                  ),
                  FormBuilderTextField(
                    name: "drawer",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Senet Borçlusu"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["drawer"] = value,
                  ),
                  FormBuilderTextField(
                    name: "drawerTaxNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Senet Borçlusu Vergi No"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["drawerTaxNumber"] = value,
                  ),
                  FormBuilderDateTimePicker(
                    name: "issuedDate",
                    inputType: InputType.date,
                    helpText: "Senedin Düzenlenme Tarihini Seçin",
                    format: DateFormat("dd-MM-yyyy"),
                    decoration: InputDecoration(labelText: "Düzenlenme Tarihi"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["issuedDate"] = value,
                  ),
                  FormBuilderTextField(
                    name: "giver",
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: "Son Ciranta / Kefil"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["giver"] = value,
                  ),
                  FormBuilderTextField(
                    name: "giverTaxNumber",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Son Ciranta / Kefil Vergi No"),
                    onChanged: (value) =>
                    _senetDetailsFormKey.currentState.value["giverTaxNumber"] = value,
                  ),
                ],
              )
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                  child: Text("İPTAL", style: TextStyle(color: Colors.white),),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.green)),
                  child: Text("KAYDET", style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    saveChangesForSenet(context, senet);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void saveChangesForSenet(BuildContext context, Senet senet) {

    var formMap = Map<String, dynamic>();

    if(_senetDetailsFormKey.currentState.saveAndValidate()) {
      formMap = _senetDetailsFormKey.currentState.value;
      senet.expirationDate = formMap["expirationDate"];
      senet.amount = double.tryParse(formMap["amount"]);
      senet.receiptDate = formMap["receiptDate"];
      senet.registerNumber = int.tryParse(formMap["registerNumber"]);
      senet.drawer = formMap["drawer"];
      senet.drawerTaxNumber = int.tryParse(formMap["drawerTaxNumber"]);
      senet.issuedDate = formMap["issuedDate"];
      senet.giver = formMap["giver"];
      senet.giverTaxNumber = int.tryParse(formMap["giverTaxNumber"]);

      senetBloc.updateSenet(senet);

      Navigator.pop(context, true);

    }else {

      print("** An error occurred saving senet details : $formMap");

    }
  }

}