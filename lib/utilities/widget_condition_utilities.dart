import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'object_utilities.dart';

/// @author : istiklal

String makeLocalDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

Map<String, dynamic> expirationConditionControl(PaymentInstrument object) {
  MaterialColor dotColor;
  Color lineColor = Colors.blue;
  String summary = "";
  String message = "";
  // -1 : vadesi geçmiş, 0 : tahsil oluyor, 1 : takasta, 2 : yarın takasta
  // 3: bu hafta takasa girecek 4: bu ay takasa girecek 5: bir aydan fazla var;
  int filterVar = 5;
  var content;
  // Çekler için;
  if (object is Cek) {
    Cek cek = object;
    message = "Vadesine ${(cek.daysToPayment.floor()).toString()} gün var";
    if (cek.daysToPayment < -2) {
      dotColor = lineColor = Colors.grey;
      summary = "Vadesi Geçmiş";
      message =
          "Vadesini ${(cek.daysToPayment * -1).floor().toString()} gün geçti";
      filterVar = -1;
    } else if (-2 <= cek.daysToPayment && cek.daysToPayment <= -1) {
      dotColor = lineColor = Colors.lime;
      summary = "Bugün Hesaba Geçiyor";
      message =
          "Vadesini ${(cek.daysToPayment * -1).floor().toString()} gün geçti";
      filterVar = 0;
    } else if (-1 < cek.daysToPayment && cek.daysToPayment < 1) {
      dotColor = lineColor = Colors.red;
      summary = "Çek Takasta";
      message = "Vadesi bugün";
      filterVar = 1;
    } else if (1 <= cek.daysToPayment && cek.daysToPayment < 2) {
      dotColor = lineColor = Colors.deepOrange;
      summary = "Yarın Takasta";
      filterVar = 2;
    } else if (2 <= cek.daysToPayment && cek.daysToPayment <= 7) {
      dotColor = Colors.orange;
      summary = "Bu Hafta Tahsil olacak";
      filterVar = 3;
    } else if (7 < cek.daysToPayment && cek.daysToPayment <= 30) {
      dotColor = Colors.amber;
      summary = "Bu Ay Tahsil olacak";
      filterVar = 4;
    } else if (30 < cek.daysToPayment && cek.daysToPayment <= 90) {
      dotColor = Colors.teal;
      summary = "Vadesine Bir Aydan Çok Var";
    } else if (90 < cek.daysToPayment) {
      dotColor = Colors.blue;
      summary = "Vadesine Üç Aydan Çok Var";
    }
    content = {"dotColor": dotColor, "summary": summary, "message": message, "filterVar": filterVar, "lineColor": lineColor};
    // senetler için;
  } else if (object is Senet) {
    Senet senet = object;
    dotColor = Colors.purple;
    summary = "Senet için hazırlanacak!!";
    message = message = "Vadesine ${(senet.daysToPayment.floor()).toString()} gün var";
    if(senet.daysToPayment < -4) {
      dotColor = lineColor = Colors.grey;
      summary = "Vadesi Geçmiş";
      message =
      "Vadesini ${(senet.daysToPayment * -1).floor().toString()} gün geçti";
      filterVar = -1;
    } else if(-4 <= senet.daysToPayment && senet.daysToPayment <= -1) {
      dotColor = lineColor = Colors.lime;
      summary = "Protesto Süresi İçinde";
      message =
      "Vadesini ${(senet.daysToPayment * -1).floor().toString()} gün geçti";
      filterVar = 0;
    } else if(-1 < senet.daysToPayment && senet.daysToPayment < 1) {
      dotColor = lineColor = Colors.red;
      summary = "Protesto Süresi Başladı";
      message = "Vadesi bugün";
      filterVar = 1;
    } else if (1 <= senet.daysToPayment && senet.daysToPayment < 2) {
      dotColor = lineColor = Colors.deepOrange;
      summary = "Vadesi Yarın";
      filterVar = 2;
    } else if (2 <= senet.daysToPayment && senet.daysToPayment <= 7) {
      dotColor = Colors.orange;
      summary = "Bu Hafta Vadesi Geliyor";
      filterVar = 3;
    } else if (7 < senet.daysToPayment && senet.daysToPayment <= 30) {
      dotColor = Colors.amber;
      summary = "Bu Ay Vadesi Geliyor";
      filterVar = 4;
    } else if (30 < senet.daysToPayment && senet.daysToPayment <= 90) {
      dotColor = Colors.teal;
      summary = "Vadesine Bir Aydan Çok Var";
    } else if (90 < senet.daysToPayment) {
      dotColor = Colors.blue;
      summary = "Vadesine Üç Aydan Çok Var";
    }
    content = {
      "dotColor": dotColor, "summary": summary, "message": message,
      "filterVar": filterVar, "lineColor": lineColor
    };
  }

  return content;
}

avatarBuilder(PaymentInstrument object) {
  var calc = expirationConditionControl(object);
  var content = {
    "avatar": CircleAvatar(
      backgroundColor: calc["dotColor"],
      child: Icon(Icons.payments_outlined, color: Colors.white,),
    ),
    "summary": calc["summary"],
    "message": calc["message"]
  };
  return content;
}

makePortfolioAddDiscardButton(BuildContext context, PaymentInstrument object) {
  if (object.portfolioId == null) {
    return TextButton(
        onPressed: () => addToPortfolioDialog(context, object),
        child: Column(
          children: [
            Text("PORTFÖYE",style: TextStyle(fontSize: 10.0)),
            Icon(Icons.add_circle_outline, color: Colors.blue,)
          ],
        ));
  } else {
    return TextButton(
        onPressed: () => discardFromPortfolioDialog(context, object),
        child: Column(
          children: [
            Text("PORTFÖYDEN", style: TextStyle(fontSize: 10.0, color: Colors.red)),
            Icon(Icons.remove_circle_outline, color: Colors.red,)
          ],
        ));
  }
}

Future<void> addToPortfolioDialog(
    BuildContext context, PaymentInstrument object) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          // child: portfolioListBuilder(context, object),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Text("Kayıtlı Portföylerim",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(
                    indent: 5,
                    endIndent: 5,
                    color: Colors.indigo,
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 50),
                child: portfolioListBuilder(context, object),
              )
            ],
          ),
        );
      });
}

portfolioListBuilder(BuildContext context, PaymentInstrument object) {
  return StreamBuilder(
      stream: portfolioBloc.outPortfolio,
      initialData: portfolioBloc.portfolios,
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            var list = snapshot.data;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("P-${list[index].id}"),
              ),
              title: Text("${list[index].portfolioName}"),
              onTap: () {
                if (object is Cek) {
                  cekBloc.addToPortfolio(object, list[index].id);
                  Navigator.pop(context, true);
                } else if (object is Senet) {
                  senetBloc.addToPortfolio(object, list[index].id);
                  Navigator.pop(context, true);
                }
              },
            );
          },
        );
      });
}

discardFromPortfolioDialog(BuildContext context, PaymentInstrument object) {
  if (object is Cek) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Çeki Portföyden Çıkarıyorsunuz",
        desc:
            "${object.amount} tutarlı çeki ekli portföyden çıkarmak istiyor musunuz?",
        buttons: [
          DialogButton(
              child: Text("İPTAL", style: TextStyle(color: Colors.white)),
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, false)),
          DialogButton(
              child: Text("EVET"),
              color: Colors.greenAccent,
              onPressed: () {
                cekBloc.discardFromPortfolio(object);
                var snackBar = SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text("Çek portföyden çıkarıldı.."),
                );
                Navigator.pop(context, true);
                Scaffold.of(context).showSnackBar(snackBar);
              })
        ]).show();
  } else if(object is Senet) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Seneti Portföyden Çıkarıyorsunuz",
        desc:
            "${object.amount} tutarlı seneti ekli portföyden çıkarmak istiyor musunuz?",
        buttons: [
          DialogButton(
              child: Text("İPTAL", style: TextStyle(color: Colors.white)),
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, false)),
          DialogButton(
              child: Text("EVET"),
              color: Colors.greenAccent,
              onPressed: () {
                senetBloc.discardFromPortfolio(object);
                var snackBar = SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text("Senet portföyden çıkarıldı.."),
                );
                Navigator.pop(context, true);
                Scaffold.of(context).showSnackBar(snackBar);
              })
        ]).show();
  }
}


// factoring usage details second column;
editFactoringUsage(BuildContext context, PaymentInstrument object){
  var widget;
  if(object.isUsed) {
    if (object is Cek) {
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/cekuseform", arguments: object.id.toString()),
              child: Text(
                "DÜZENLE",
                style: TextStyle(color: Colors.orange, fontSize: 11.0),)
          ),
          TextButton(
              onPressed: () {
                Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Veriler Siliniyor",
                    desc: "Faktoring kullanımına ait kayıtları silmek istediniz onaylıyor musunuz?",
                    buttons: [
                      DialogButton(
                          child: Text("İPTAL", style: TextStyle(color: Colors.white)),
                          color: Colors.redAccent,
                          onPressed: () => Navigator.pop(context, false)),
                      DialogButton(
                          child: Text("SİL"),
                          color: Colors.greenAccent,
                          onPressed: () => factoringUsageCancel(context, object))
                    ]).show();
              },
              child: Text(
                "TEMİZLE",
                style: TextStyle(color: Colors.red, fontSize: 11.0),)
          ),
        ],
      );
    } else if(object is Senet){
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/senetuseform", arguments: object.id.toString()),
              child: Text(
                "DÜZENLE",
                style: TextStyle(color: Colors.orange, fontSize: 11.0),)
          ),
          TextButton(
              onPressed: () {
                Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Veriler Siliniyor",
                    desc: "Faktoring kullanımına ait kayıtları silmek istediniz onaylıyor musunuz?",
                    buttons: [
                      DialogButton(
                          child: Text("İPTAL", style: TextStyle(color: Colors.white)),
                          color: Colors.redAccent,
                          onPressed: () => Navigator.pop(context, false)),
                      DialogButton(
                          child: Text("SİL"),
                          color: Colors.greenAccent,
                          onPressed: () => factoringUsageCancel(context, object))
                    ]).show();
              },
              child: Text(
                "TEMİZLE",
                style: TextStyle(color: Colors.red, fontSize: 11.0),)
          ),
        ],
      );
    }
  }else{
    widget = Column(
      children: [
        Icon(Icons.list_alt_outlined),
      ],
    );
  }
  return widget;
}


factoringUsageCancel(BuildContext context, PaymentInstrument object) {
  if(object is Cek){
    var cek = object;
    cek.companyUsed = null;
    cek.usingDate =  null;
    cek.interestRate = null;
    cek.interestFee = null;
    cek.commissionRate = null;
    cek.commissionFee = null;
    cek.receivedPayment = null;
    cek.isUsed = false;

    cekBloc.updateCek(cek);
  }else if(object is Senet){
    var senet = object;
    senet.companyUsed = null;
    senet.usingDate =  null;
    senet.interestRate = null;
    senet.interestFee = null;
    senet.commissionRate = null;
    senet.commissionFee = null;
    senet.receivedPayment = null;
    senet.isUsed = false;

    senetBloc.updateSenet(senet);
  }
  var snackBar = SnackBar(
    duration: Duration(seconds: 3),
    content: Text("Kayıtlar temizlendi.."),
  );
  Navigator.pop(context, true);
  Scaffold.of(context).showSnackBar(snackBar);
}

// factoring usage form and saving to object properties;
objectFactoringUsage(BuildContext context, PaymentInstrument object) {
  switch(object.isUsed) {
    case false :
      return factoringUseButton(context, object);
      break;
    case true :
      return factoringDetailsTable(object);
      break;
  }
}

factoringDetailsTable(PaymentInstrument object) {
  if(object is Cek){
    var financialCost = object.amount-(object.receivedPayment!=null?object.receivedPayment:object.amount);
    return DataTable(
      horizontalMargin: 3.0,
      headingRowHeight: 15.0,
      dataRowHeight: 20.0,
      dividerThickness: 0.5,
      columnSpacing: 25.0,
      columns: [DataColumn(label: Text("")), DataColumn(label: Text(""))],
      rows: [
        tableRowMaker("Çek Tutarı", object.amount, symbol: "TL"),
        tableRowMaker("Kullanım Tarihi", object.usingDate),
        tableRowMaker("Kapanma Tarihi", getPaymentDay(object.expirationDate)),
        tableRowMaker("Faiz Oranı", object.interestRate, symbol: "%"),
        tableRowMaker("Faiz Tutarı", object.interestFee, symbol: "TL"),
        tableRowMaker("Komisyon Oranı", object.commissionRate, symbol: "%"),
        tableRowMaker("Komisyon Tutarı", object.commissionFee, symbol: "TL"),
        tableRowMaker("FİNANSMAN GİDERİ", financialCost, symbol: "TL"),
        tableRowMaker("ALINAN ÖDEME", object.receivedPayment, symbol: "TL"),
      ]
    );
  }else if(object is Senet){
    var financialCost = object.amount-(object.receivedPayment!=null?object.receivedPayment:object.amount);
    return DataTable(
        horizontalMargin: 3.0,
        headingRowHeight: 15.0,
        dataRowHeight: 20.0,
        dividerThickness: 0.5,
        columnSpacing: 25.0,
        columns: [DataColumn(label: Text("")), DataColumn(label: Text(""))],
        rows: [
          tableRowMaker("Senet Tutarı", object.amount, symbol: "TL"),
          tableRowMaker("Kullanım Tarihi", object.usingDate),
          tableRowMaker("Kapanma Tarihi", getPaymentDay(object.expirationDate).add(Duration(days:3))),
          tableRowMaker("Faiz Oranı", object.interestRate, symbol: "%"),
          tableRowMaker("Faiz Tutarı", object.interestFee, symbol: "TL"),
          tableRowMaker("Komisyon Oranı", object.commissionRate, symbol: "%"),
          tableRowMaker("Komisyon Tutarı", object.commissionFee, symbol: "TL"),
          tableRowMaker("FİNANSMAN GİDERİ", financialCost, symbol: "TL"),
          tableRowMaker("ALINAN ÖDEME", object.receivedPayment, symbol: "TL"),
        ]
    );

  }
}

factoringUseButton(BuildContext context, PaymentInstrument object) {

  return ElevatedButton.icon(
      icon: Icon(Icons.calculate_outlined),
      label: Text("Faktoring Kullan"),
      onPressed: () {
        if(object is Cek) {
          Navigator.pushNamed(context, "/cekuseform", arguments: object.id.toString());
        }else if(object is Senet) {
          Navigator.pushNamed(context, "/senetuseform", arguments: object.id.toString());
        }
      },
  );
}

