import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:flutter/material.dart';

/// @author : istiklal

class SenetAddScreen extends StatefulWidget{
  @override
  _SenetAddScreenState createState() => _SenetAddScreenState();
}

class _SenetAddScreenState extends State<SenetAddScreen> {
  Senet senet;

  var expirationDateField;

  var amountField = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yeni Senet Ekle"),
        titleSpacing: 5,
      ),
      body: buildSenetAddWidget(context),
    );
  }

  buildSenetAddWidget(BuildContext context) {
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
      decoration: InputDecoration(labelText: "Senet Tutarı :", hintText: "TL tutar giriniz"),
    );
  }

  buildExpirationDateField() {
    return DateTimePicker(
      icon: Icon(Icons.event),
      dateMask: "d MM yyyy",
      initialValue: DateTime.now().toString(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      dateLabelText: "Senet Vadesi",

      onChanged: (val) { print("$val in onChanged"); expirationDateField = DateTime.parse(val);},
      validator: (val) {
        // print("$val in validator");
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
        addSenet(context);
      },
    );
  }

  void addSenet(BuildContext context) {
    var senet = Senet(expirationDateField, double.parse(amountField.text));
    senetBloc.addSenet(senet);
    // print("*** ${amountField.text} TL lik $expirationDateField vadeli senet kayıt edildi..");
    Navigator.pop(context, true);
  }
}