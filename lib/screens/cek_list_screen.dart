// import 'dart:ui';

import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/utilities/widget_condition_utilities.dart';
import 'package:faktoring_hesap/widgets/flip_card.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';

/// @author : istiklal

class CekListScreen extends StatelessWidget {

  final cekBlocW = CekBloc();

  final localNumber = NumberFormat("###,###.0#", "en_US");

  @override
  Widget build(BuildContext context) {
    // var device = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.style_outlined),
            Text("  Kayıtlı Çeklerim"),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.home_outlined),
              onPressed: () => Navigator.pop(context, true)),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.pushNamed(context, "/addingcek"),
          )
        ],
      ),
      body: RefreshIndicator(
          child: buildCekList(),
          onRefresh: () async {
            return buildCekList();
          }),
    );
  }

  buildCekList() {
    return StreamBuilder(
      stream: cekBlocW.outCek,
      builder: (context, snapshot) {
        // print("*** snapshot :$snapshot");
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.data.length > 0
            ? buildCekListItems(snapshot)
            : Center(
                child: Text("Şu An Kayıtlı Çek Yok"),
              );
      },
    );
  }

  buildCekListItems(AsyncSnapshot snapshot) {
    return ListView.builder(
        padding: EdgeInsets.all(15.0),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, index) {
          var list = snapshot.data;
          return Card(
              borderOnForeground: true,
              clipBehavior: Clip.antiAlias,
              color: Colors.white70,
              elevation: 2.0,
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: Column(
                  children: [
                    ListTile(
                      leading: avatarBuilder(list[index])["avatar"],
                      title: Column(
                        children: [
                          Text(
                            "VADE :  ${makeLocalDate(list[index].expirationDate)}",
                          ),
                          Text("TUTAR :  ${localNumber.format(list[index].amount)} TL")
                        ],
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                      subtitle: Text(
                        avatarBuilder(list[index])["summary"],
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      // contentPadding: EdgeInsets.all(5.0),
                    ),
                    Text(avatarBuilder(list[index])["message"]),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "${list[index].receiptDate!=null?makeLocalDate(list[index].receiptDate):"..."} tarihinde alınan "+
                            "${list[index].bankName!=null?list[index].bankName:"... bankası"} çeki.",
                        style: TextStyle(color: Colors.black.withOpacity(0.5)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "KEŞİDECİ : ${list[index].drawer!=null?list[index].drawer:"... LTD. ŞTİ."}",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Divider(
                      color: Colors.blue,
                      indent: 15,
                      endIndent: 15,
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text("faktoring", style: TextStyle(fontSize: 9.0),),
                            Icon(Icons.check_circle, color: list[index].isUsed?Colors.green:Colors.grey,),
                          ],
                        ),
                        IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.orangeAccent,),
                            onPressed: () => goToCekDetail(context, list[index]) ),
                        IconButton(
                            icon: Icon(Icons.delete_outlined, color: Colors.redAccent,),
                            onPressed: () => confirmationDialog(context, list[index])
                        ),
                        makePortfolioAddDiscardButton(context, list[index]),
                      ],
                    ),
                  ],
                ),
                back: Card(
                  color: Colors.white70,
                  borderOnForeground: true,
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: objectFactoringUsage(context, list[index])
                      ),
                      Expanded(
                        flex: 1,
                        child: editFactoringUsage(context, list[index]),
                      )
                    ],
                  ),
                ),
              ));
        });
  }

  // for object details
  void goToCekDetail(BuildContext context, Cek cek) {
    cekBlocW.getDetails(cek.id.toString());
    Navigator.pushNamed(context, "/cekdetails", arguments: cek.id.toString());
  }

  // confirmation for deleting object from database;
  confirmationDialog(BuildContext context, Cek cek) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Çek Silinecek",
        desc: "${cek.amount} tutarlı çeki silmek istediniz onaylıyor musunuz?",
        buttons: [
          DialogButton(
              child: Text("İPTAL", style: TextStyle(color: Colors.white)),
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, false)),
          DialogButton(
              child: Text("SİL"),
              color: Colors.greenAccent,
              onPressed: () => deleteCekItem(context, cek))
        ]).show();
  }

  // accepting the confirmation;
  void deleteCekItem(BuildContext context, Cek cek) {
    cekBlocW.deleteCek(cek);
    var snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Text("Çek silindi.."),
    );
    Navigator.pop(context, true);
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }


}
