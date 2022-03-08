
import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:faktoring_hesap/utilities/object_utilities.dart';
import 'package:faktoring_hesap/utilities/widget_condition_utilities.dart';
import 'package:faktoring_hesap/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// @author : istiklal

class PortfolioDetail extends StatelessWidget {
  final String id;
  PortfolioDetail({Key key, @required this.id}) : super(key: key);

  final blocPortfolioDetails = PortfolioBloc();

  Portfolio portfolio;

  @override
  Widget build(BuildContext context) {
    portfolio = blocPortfolioDetails.getDetails(id);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.folder_open_rounded),
            Text(" Portföy Detayları", style: TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
      body: RefreshIndicator(
        child: portfolioDetailBodyBuilder(context, id),
        onRefresh: () async {
          return portfolioDetailBodyBuilder(context, id);
        },
      )
    );
  }

  addMaterialTheme(Widget widget) {
    return Material(
        elevation: 14.0,
        shadowColor: Colors.grey,
        borderRadius: BorderRadius.circular(24.0),
        child: widget);
  }

  portfolioDetailBodyBuilder(BuildContext context, String id) {
    return StaggeredGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14.0,
      crossAxisSpacing: 14.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        addMaterialTheme(factoringUsageSummary(context, id)),
        addMaterialTheme(elementStreamBuilder(context, id)),
      ],
      staggeredTiles: [
        StaggeredTile.extent(2, 240),
        StaggeredTile.extent(2, 320),

      ],
    );
  }

  factoringUsageSummary(BuildContext context, String id) {

    return StreamBuilder(
      stream: blocPortfolioDetails.outDetails,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.data != null
            ? portfolioDetailsTable(context, snapshot.data)
            : Center(child: Text("Bir Hata Oluştu..."),);
      }
    );
  }

  portfolioDetailsTable(BuildContext context, Portfolio data) {

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            Text("${data.portfolioName}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(indent: 3.0, endIndent: 3.0, thickness: 0.5, color: Colors.black,),
            detailTableMaker(context, data),
          ],
        ),
      ),
    );
  }

  detailTableMaker(BuildContext context, Portfolio data) {
    // var calculationResult = calculatePortfolioDetails(portfolio);
    var widget;
    // if(data.isUsed) {
    //   widget = Center(child: Text("Kullanım yapılmış"),);
    // }else {
      widget = StreamBuilder(
          stream: blocPortfolioDetails.outDetails,
          initialData: blocPortfolioDetails.calculatePortfolioDetails(data),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if(!snapshot.hasData){
              return Center(child: CircularProgressIndicator(),);
            }else if(snapshot.data.elementCount==null) {
              return Center(child: Text("Portföy Boş"),);
            }
            return generatePortfolioTable(context, snapshot.data);
          }
        );
    // }
    return widget;
  }

  generatePortfolioTable(BuildContext context, Portfolio data) {
    var tableBlock;
    if(!data.isUsed) {
      tableBlock = DataTable(
          horizontalMargin: 3.0,
          headingRowHeight: 0.0,
          dataRowHeight: 20.0,
          dividerThickness: 0.5,
          columnSpacing: 35.0,
          columns: [
            DataColumn(label: Text("")),
            DataColumn(label: Text("")),
          ],
          rows: [
            tableRowMaker("Çek/Senet Sayısı", data.elementCount, symbol: "ADET"),
            tableRowMaker("Portföy Toplamı", data.totalVolume, symbol: "TL"),
            tableRowMaker("Tahsil Olan", (data.totalVolume-data.leftPayment), symbol: "TL"),
            tableRowMaker("Tahsil Bekleyen", data.leftPayment, symbol: "TL"),
            tableRowMaker("Ortalama Vadesi", data.averageExpiration, symbol: "GÜN"),
            tableRowMaker("Portföyün Vadesi", data.lastDayOfPayment),
            tableRowMaker("Kullanıldı mı?", data.isUsed),
            DataRow(

                cells: [
                  DataCell(ElevatedButton(
                      child: Text("Faktoring Hesapla"),
                      onPressed: () {
                        Navigator.pushNamed(context, "/portfoliouseform", arguments: data.id.toString());
                      })
                  ),
                  DataCell(Text("")),
                ]
            ),
          ]);
    }else {
      tableBlock = DataTable(
          horizontalMargin: 3.0,
          headingRowHeight: 0.0,
          dataRowHeight: 20.0,
          dividerThickness: 0.5,
          columnSpacing: 35.0,
          columns: [
            DataColumn(label: Text("")),
            DataColumn(label: Text("")),
          ],
          rows: [
            tableRowMaker("Çek/Senet Sayısı", data.elementCount, symbol: "ADET", rowColor: Colors.grey),
            tableRowMaker("Portföy Toplamı", data.totalVolume, symbol: "TL", rowColor: Colors.grey),
            tableRowMaker("Tahsil Olan", (data.totalVolume-data.leftPayment), symbol: "TL", rowColor: Colors.grey),
            tableRowMaker("Tahsil Bekleyen", data.leftPayment, symbol: "TL", rowColor: Colors.grey),
            tableRowMaker("Ortalama Vadesi", data.averageExpiration, symbol: "GÜN", rowColor: Colors.grey),
            // Factoring usage informations of portfolio;
            tableRowMaker("Faktoring Şirketi", data.companyUsed),
            tableRowMaker("Kullanım Tarihi", data.usingDate),
            tableRowMaker("Faiz Oranı", data.interestRate, symbol: "%"),
            tableRowMaker("Faiz Tutarı", data.interestFee, symbol: "TL"),
            tableRowMaker("Komisyon Oranı", data.commissionRate, symbol: "%"),
            tableRowMaker("Komisyon Tutarı", data.commissionFee, symbol: "TL"),
            tableRowMaker("Toplam Maliyet", roundDouble((data.totalVolume-data.receivedPayment), 2), symbol: "TL"),
            tableRowMaker("Alınan Ödeme", data.receivedPayment, symbol: "TL", rowColor: Colors.red),

            DataRow(

                cells: [
                  DataCell(ElevatedButton(
                    child: Text("Yeniden Hesapla"),
                    onPressed: () {
                      Navigator.pushNamed(context, "/portfoliouseform", arguments: data.id.toString());
                    })
                  ),
                  DataCell(Text("")),
                ]
            ),
          ]);
    }
    return tableBlock;
  }


  elementStreamBuilder(BuildContext context, String id) {
    return StreamBuilder(
        stream: portfolioBloc.outElements,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return snapshot.data.length > 0
              ? elementListBuilder(snapshot, id)
              : Center(
                  child: Text("Portföy şu an boş..."),
          );
        });
  }

  elementListBuilder(AsyncSnapshot snapshot, String id) {
    return ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, index) {
          var list = snapshot.data;
          // calculatePortfolioDetails(id, list);
          return Card(
            borderOnForeground: true,
            clipBehavior: Clip.antiAlias,
            color: Colors.white70,
            elevation: 2.0,
            child: ListTile(
              leading: avatarBuilder(list[index])["avatar"],
              title: Text("${makeLocalDate(list[index].expirationDate)} vadeli\n${localNumber.format(list[index].amount)} TL"),
              subtitle: elementListSubtitle(list[index]),
              trailing: IconButton(
                  icon: Icon(Icons.do_disturb_on_outlined, color: Colors.red,),
                  onPressed: () {
                    openPortfolioDiscardDialog(context, list[index]);
                  }),
            ),
          );
        }
    );
  }

  getDetails(PaymentInstrument instrument) {
    var context;
    if(instrument is Cek) {
      context = {"symbol": "Ç", "id":instrument.id, "avatar": "Ç-${instrument.id}"};
    } else if(instrument is Senet) {
      context = {"symbol": "S", "id":instrument.id, "avatar": "S-${instrument.id}"};
    }
    return context;
  }

  elementListSubtitle(PaymentInstrument instrument) {
    if(instrument.isUsed == true) {
      var cost = roundDouble((instrument.amount - instrument.receivedPayment), 2);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Maliyet : ${localNumber.format(cost)} TL"),
          Text("Ödeme : ${localNumber.format(instrument.receivedPayment)} TL"),
        ],
      );
    }else{
      return Text("${instrument.isUsed==true?"Kullanım Yapıldı":"Kullanım Yapılmadı"}");
    }
  }

  openPortfolioDiscardDialog(BuildContext context, PaymentInstrument object) {
    return Alert(
      context: context,
      type: AlertType.warning,
      title: "${object.amount} TL",
      desc: "tutarlı ödeme enstrümanı portföyden çıkarılsın mı?",
      buttons: [
        DialogButton(
          child: Text("İPTAL", style: TextStyle(color: Colors.white)),
          color: Colors.redAccent,
          onPressed: () => Navigator.pop(context, false)
        ),
        DialogButton(
          child: Text("EVET"),
          color: Colors.greenAccent,
          onPressed: () {
            portfolioBloc.discardElementFromPortfolio(object, object.portfolioId);
            var snackBar = SnackBar(
              duration: Duration(seconds: 3),
              content: Text("Ödeme aracı portföyden çıkarıldı"),
            );
            Navigator.pop(context, true);
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(snackBar);
          }
        ),
      ]
    ).show();
  }






}
