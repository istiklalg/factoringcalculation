// import 'dart:ui';

// import 'package:date_time_picker/date_time_picker.dart';
import 'package:faktoring_hesap/blocs/cek_bloc.dart';
import 'package:faktoring_hesap/blocs/payment_instrument_bloc.dart';
import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:faktoring_hesap/blocs/senet_bloc.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// @author : istiklal

class MainScreen extends StatefulWidget {
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  final localNumber = NumberFormat("###,###.0#", "en_US");

  final GlobalKey<AnimatedCircularChartState> _allChartKey =
    new GlobalKey<AnimatedCircularChartState>();

  final GlobalKey<AnimatedCircularChartState> _cekChartKey =
      new GlobalKey<AnimatedCircularChartState>();

  final GlobalKey<AnimatedCircularChartState> _senetChartKey =
      new GlobalKey<AnimatedCircularChartState>();

  @override
  void initState() {
    super.initState();
  }

  _updateScreen(BuildContext context) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: mainScreenBarBuilder(context),
        body: RefreshIndicator(
          child: mainScreenBodyBuilder(context),
          onRefresh: () async {
            _updateScreen(context);
          },
        ));
  }

  mainScreenBarBuilder(BuildContext context) {
    return AppBar(
      title: Text("Faktoring Çek/Senet"),
      leading: Icon(Icons.account_balance_wallet_outlined),
    );
  }

  mainScreenBodyBuilder(BuildContext context) {
    return StaggeredGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14.0,
      crossAxisSpacing: 14.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        addMaterialTheme(allSummaryScreen(context)),
        addMaterialTheme(cekSummaryScreen(context)),
        addMaterialTheme(senetSummaryScreen(context)),
        addMaterialTheme(portfolioSummaryScreen(context)),
        addMaterialTheme(factoringCalculatorButton(context)),
        addMaterialTheme(aboutUsButton(context))
      ],
      staggeredTiles: [
        StaggeredTile.extent(2, 210),
        StaggeredTile.extent(1, 220),
        StaggeredTile.extent(1, 220),
        StaggeredTile.extent(2, 50),
        StaggeredTile.extent(1, 50),
        StaggeredTile.extent(1, 50),
      ],
    );
  }

  addMaterialTheme(Widget widget) {
    return Material(
        elevation: 14.0,
        shadowColor: Colors.grey,
        borderRadius: BorderRadius.circular(24.0),
        child: widget);
  }

  allSummaryScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "GENEL",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Divider(
          indent: 10,
          endIndent: 10,
          color: Colors.black,
        ),
        overallSummaryBuilder(context),
      ],
    );
  }

  cekSummaryScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text("Çeklerim"),
        Padding(
          padding: EdgeInsets.only(left: 1.0, right: 1.0),
          child: StreamBuilder(
              stream: cekBloc.outCek,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return snapshot.data.length > 0
                    ? buildCircularChart(snapshot.data, "Çekler", _cekChartKey)
                    : Text("Veriler Boş");
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text("ÇEKLERİM"),
                  onPressed: () => Navigator.pushNamed(context, "/cek"),
                ),
                CircleAvatar(
                  backgroundColor: Colors.yellow,
                  child: StreamBuilder(
                      stream: cekBloc.outCek,
                      builder: (context, snapshot) {
                        return Text(
                            "${snapshot.hasData ? snapshot.data.length : "!"}");
                      }),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  senetSummaryScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text("Senetlerim"),
        Padding(
          padding: EdgeInsets.only(left: 1.0, right: 1.0),
          child: StreamBuilder(
              stream: senetBloc.outSenet,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return snapshot.data.length > 0
                    ? buildCircularChart(
                        snapshot.data, "Senetler", _senetChartKey)
                    : Text("Veriler Boş");
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text("SENETLERİM"),
                  onPressed: () => Navigator.pushNamed(context, "/senet"),
                ),
                CircleAvatar(
                  backgroundColor: Colors.yellow,
                  child: StreamBuilder(
                      stream: senetBloc.outSenet,
                      builder: (context, snapshot) {
                        return Text(
                            "${snapshot.hasData ? snapshot.data.length : "!"}");
                      }),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  portfolioSummaryScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/portfolios"),
            child: Text("PORTFÖYLERİM"),
          ),
          CircleAvatar(
            backgroundColor: Colors.yellow,
            child: StreamBuilder(
                stream: portfolioBloc.outPortfolio,
                builder: (context, snapshot) {
                  return Text(
                      "${snapshot.hasData ? snapshot.data.length : "!"}");
                }),
          )
        ],
      ),
    );
  }

  // factoring calculate button;
  factoringCalculatorButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, "/factoringCalculator"),
          child: Text("FAKTORİNG HESAPLA"),
        )
      ],
    );
  }

  // about us button;
  aboutUsButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, "/aboutappscreen"),
          child: Text("HAKKINDA"),
        )
      ],
    );
  }

  buildCircularChart(
      _list, String holeLabel, GlobalKey<AnimatedCircularChartState> _chartKey) {
    var _data = generateGraphData(_list);
    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        _data["segmentEntries"],
        rankKey: 'graph1',
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: AnimatedCircularChart(
            key: _chartKey,
            size: const Size(100.0, 80.0),
            initialChartData: data,
            chartType: CircularChartType.Radial,
            startAngle: 180.0,
            holeLabel: holeLabel,
            labelStyle: TextStyle(
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Vadesi Geçen :",
              style: TextStyle(color: Colors.grey, fontSize: 12.0,),
            ),
            Text(
              "${localNumber.format(_data["older"])} TL",
              style: TextStyle(color: Colors.grey.withOpacity(0.85), fontSize: 12.0,),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Bugün Vadeli :",
              style: TextStyle(color: Colors.red, fontSize: 12.0,),
            ),
            Text(
              "${localNumber.format(_data["today"])} TL",
              style: TextStyle(color: Colors.red.withOpacity(0.85), fontSize: 12.0,),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "İleri Vadeli :",
              style: TextStyle(color: Colors.blue, fontSize: 12.0,),
            ),
            Text(
              "${localNumber.format(_data["future"])} TL",
              style: TextStyle(color: Colors.blue.withOpacity(0.85), fontSize: 12.0,),
            )
          ],
        ),
        Divider(indent: 2, endIndent: 2, color: Colors.grey, thickness: 0.5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Toplam :", style: TextStyle(fontSize: 12.0),),
            Text("${localNumber.format(_data["totalAmount"])} TL", style: TextStyle(fontSize: 12.0),)
          ],
        )
      ],
    );
  }

  overallSummaryBuilder(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: paymentInstrumentBloc.outInstrument,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return snapshot.data.length > 0
              ? overallSummary(snapshot.data)
              : Center(
                child: Text("Kayıtlı Bir Ödeme Aracı Bulunmuyor"),
          );
        },
      ),);
  }

  overallSummary(List<PaymentInstrument> list) {
    var data = generateGraphData(list);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  todayTableBuilder(data),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: dataSummaryBuilder(data, "Tümü", _allChartKey),
        )
      ],
    );
  }

  todayTableBuilder(Map<String, dynamic> data) {
    return DataTable(
        horizontalMargin: 3.0,
        headingRowHeight: 15.0,
        dataRowHeight: 20.0,
        dividerThickness: 0.5,
        columnSpacing: 25.0,
        columns: [
          DataColumn(label: Text("BUGÜN")),
          DataColumn(label: Text("")),
        ],
        rows: [
          tableRowMaker("Dün Tahsil Olan", data["older"], symbol: "TL"),
          tableRowMaker("Tahsil Olacak", data["today"], rowColor: Colors.red, symbol: "TL"),
          tableRowMaker("Faktoring Riski", data["usedAmount"], symbol: "TL"),
        ]);
  }

  dataSummaryBuilder(
      Map<String, dynamic> _data, String holeLabel,
      GlobalKey<AnimatedCircularChartState> _chartKey) {

    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        _data["segmentEntries"],
        rankKey: 'graph2',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: AnimatedCircularChart(
            key: _chartKey,
            size: const Size(100.0, 100.0),
            initialChartData: data,
            chartType: CircularChartType.Radial,
            startAngle: 180.0,
            holeLabel: holeLabel,
            labelStyle: TextStyle(
              color: Colors.blueGrey[600],
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ),
        Text("Toplam",style: TextStyle(decoration: TextDecoration.underline),),
        Text("${localNumber.format(_data["totalAmount"])} TL"),
      ],
    );
  }
}
