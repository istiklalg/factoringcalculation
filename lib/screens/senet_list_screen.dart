//import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/utilities/widget_condition_utilities.dart';
import 'package:faktoring_hesap/widgets/flip_card.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:intl/intl.dart';

/// @author : istiklal

class SenetListScreen extends StatelessWidget {

  final localNumber = NumberFormat("###,###.0#", "en_US");

  final senetBlocW = SenetBloc();
  // var deviceData;
  @override
  Widget build(BuildContext context) {
    // deviceData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.style_outlined),
            Text("  Kayıtlı Senetlerim"),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.home_outlined),
              onPressed: () => Navigator.pop(context, true)),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, "/addingsenet"),),
        ],
      ),
      body: RefreshIndicator(
          child: buildSenetList(),
          onRefresh: () async {
            return buildSenetList();
          }),
    );
  }

  buildSenetList() {
    return StreamBuilder(
      // initialData: senetBlocW.senetler,
      stream: senetBlocW.outSenet,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.data.length > 0
            ? buildSenetListItems(snapshot)
            : Center(
                child: Text("Şu An Kayıtlı Senet Yok"),
              );
      },
    );
  }

  buildSenetListItems(AsyncSnapshot snapshot) {
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
                speed: 250,
                direction: FlipDirection.HORIZONTAL,
                front: Column(
                  children: [
                    ListTile(
                      leading: avatarBuilder(list[index])["avatar"],
                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Padding(padding: EdgeInsets.only(left:(deviceData.size.width*0.05),)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  " ÖDEME GÜNÜ ",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                                Text(makeLocalDate(list[index].expirationDate)),
                              ],
                            ),
                            // Padding(padding: EdgeInsets.only(left:(deviceData.size.width*0.05), right: (deviceData.size.width*0.05))),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  " TUTAR ",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                                Text("${localNumber.format(list[index].amount)} TL"),
                              ],
                            ),
                          ]),
                      subtitle: Text(
                        avatarBuilder(list[index])["summary"],
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    Text(avatarBuilder(list[index])["message"]),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "${list[index].giver != null ? list[index].giver : "..."}'den " +
                            "${list[index].receiptDate != null ? makeLocalDate(list[index].receiptDate) : "..."} tarihinde alınan senettir.",
                        style: TextStyle(color: Colors.black.withOpacity(0.5),),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "DÜZENLEME TARİHİ : ${list[index].issuedDate!=null?makeLocalDate(list[index].issuedDate):"..."}",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      "BORÇLU : ${list[index].drawer!=null? list[index].drawer :"..."}",
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      textAlign: TextAlign.right,
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
                            Text("faktoring",
                              style: TextStyle(fontSize: 9.0),),
                            Icon(Icons.check_circle,
                              color: list[index].isUsed?Colors.green:Colors.grey,),
                          ],
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.orangeAccent,
                            ),
                            onPressed: () =>
                                goToSenetDetail(context, list[index])),
                        IconButton(
                            icon: Icon(
                              Icons.delete_outlined,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                confirmationDialog(context, list[index])),
                        makePortfolioAddDiscardButton(context, list[index]),
                      ],
                    )
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

  void goToSenetDetail(BuildContext context, Senet senet) {
    senetBlocW.getDetails(senet.id.toString());
    Navigator.pushNamed(context, "/senetdetails",
        arguments: senet.id.toString());
  }

  confirmationDialog(BuildContext context, Senet senet) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Senet Silinecek",
        desc:
            "${senet.amount} tutarlı senedi silmek istediniz, onaylıyor musunuz?",
        buttons: [
          DialogButton(
              child: Text(
                "İPTAL",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, false)),
          DialogButton(
              child: Text("SİL"),
              color: Colors.greenAccent,
              onPressed: () => deleteSenetItem(context, senet))
        ]).show();
  }

  void deleteSenetItem(BuildContext context, Senet senet) async {
    senetBlocW.deleteSenet(senet);
    var snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Text("Senet silindi.."),
    );
    Navigator.pop(context, true);
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
