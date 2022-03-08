
import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:flutter/material.dart';

/// @author : istiklal

class CekAddScreen extends StatelessWidget{
  Cek cek;
  var expirationDateField;
  var amountField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Çek Ekle"),
      ),
      body: buildCekAddWidget(context),
    );
  }

  buildCekAddWidget(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildAmountField(), buildExpirationDateField(), buildSaveButton(context)
          ],
        ),
      ),

    );

  }

  buildAmountField() {
    return TextField(
      controller: amountField,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Çek Tutarı :", hintText: "TL tutar giriniz"),
    );
  }

  buildExpirationDateField() {
    return DateTimePicker(
      icon: Icon(Icons.event),
      dateMask: "d MM yyyy",
      initialValue: DateTime.now().toString(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      dateLabelText: "Çek Vadesi",

      onChanged: (val) { print("$val in onChanged"); expirationDateField = DateTime.parse(val);},
      validator: (val) {
        print("$val in validator");
        return val;
      },
      onSaved: (val) => print("$val in onSaved"),
    );
  }

  buildSaveButton(BuildContext context) {
    return TextButton(
      child: Text("KAYDET"),
      onPressed: () {
        print(amountField.text);
        print(expirationDateField);
        addCek(context);
      },
    );
  }

  void addCek(BuildContext context) async {
    var cek = Cek(expirationDateField, double.tryParse(amountField.text));
    cekBloc.addCek(cek);
    // print("*** ${amountField.text} TL lik $expirationDateField vadeli çek kayıt edildi..");
    Navigator.pop(context, true);
  }

}