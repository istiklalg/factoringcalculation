
import 'package:faktoring_hesap/blocs/portfolio_bloc.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// @author : istiklal

class PortfolioListScreen extends StatelessWidget {
  final portfolioBlocW = PortfolioBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.all_inbox),
            Text(" Çek/Senet Portföylerim", style: TextStyle(fontSize: 16.0)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined),
            onPressed: () => Navigator.pop(context, true),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              openPopUpForm(context);
            },
          )
        ],
      ),
      body: RefreshIndicator(
          child: buildPortfolioList(),
          onRefresh: () async {
            return buildPortfolioList();
          }),
    );
  }

  buildPortfolioList() {
    return StreamBuilder(
      stream: portfolioBlocW.outPortfolio,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.data.length > 0
            ? buildPortfolioListItems(snapshot.data)
            : Center(
                child: Text("Oluşturulmuş portföy yok"),
              );
      },
    );
  }

  buildPortfolioListItems(List<Portfolio> list) {
    return ListView.builder(
        padding: EdgeInsets.all(15.0),
        itemCount: list.length,
        itemBuilder: (BuildContext context, index) {
          return Card(
              color: Colors.greenAccent,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.greenAccent,
                  child: Icon(Icons.folder_open_rounded, color: Colors.white,),
                ),
                title: Text(
                  "${list[index].portfolioName}",
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => goToPortfolioDetails(context, list[index].id),
                trailing: IconButton(
                    icon: Icon(Icons.delete_outlined, color: Colors.red,),
                    onPressed: () => confirmationDialog(context, list[index])),
              ));
        });
  }

  openPopUpForm(BuildContext context) {
    var nameField = TextEditingController();
    Alert(
        context: context,
        title: "Yeni Portföy Oluştur",
        content: Column(children: [
          TextField(
            controller: nameField,
            decoration: InputDecoration(
                labelText: "Portföy Adı :",
                hintText: "Portföy için bir isim verin"),
          )
        ]),
        buttons: [
          DialogButton(
              child: Text(
                "İPTAL",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, false),
              color: Colors.redAccent),
          DialogButton(
              child: Text("KAYDET"),
              onPressed: () => savePortfolio(context, nameField.text),
              color: Colors.greenAccent)
        ]).show();
  }

  savePortfolio(BuildContext context, String name) {
    var portfolio = Portfolio(name);
    portfolioBlocW.createPortfolio(portfolio);
    Navigator.pop(context, true);
  }

  confirmationDialog(BuildContext context, Portfolio portfolio) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Potföy Silinecek",
        desc: "${portfolio.portfolioName} isimli portföyü silmek istediniz",
        buttons: [
          DialogButton(
              child: Text(
                "İPTAL",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.redAccent,
              onPressed: () => Navigator.pop(context, false)),
          DialogButton(
              child: Text("PORTFÖYÜ SİL"),
              color: Colors.blueAccent,
              onPressed: () => deletePortfolioItem(context, portfolio)),
          DialogButton(
              child: Text("İÇERİĞİ İLE SİL"),
              color: Colors.greenAccent,
              onPressed: () => deleteWholePortfolio(context, portfolio))
        ]).show();
  }

  deletePortfolioItem(BuildContext context, Portfolio portfolio) {
    portfolioBlocW.deletePortfolioOnly(portfolio);
    Navigator.pop(context, true);
  }

  deleteWholePortfolio(BuildContext context, Portfolio portfolio) {
    portfolioBlocW.deletePortfolioWithContent(portfolio);
    Navigator.pop(context, true);
  }

  goToPortfolioDetails(BuildContext context, int id) {
    portfolioBloc.getAllElements(id.toString());
    Navigator.pushNamed(context, "/portfoliodetails", arguments: id.toString());
  }
}
