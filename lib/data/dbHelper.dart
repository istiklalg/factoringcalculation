import 'dart:async';

import 'package:faktoring_hesap/models/cek.dart';
import 'package:faktoring_hesap/models/payment_instrument.dart';
import 'package:faktoring_hesap/models/portfolio.dart';
import 'package:faktoring_hesap/models/senet.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// @author : istiklal

class DbHelper {

  static const createCekTable = "Create table ceks("+
    "id integer primary key autoincrement, portfolioId integer, serialNumber integer, drawerTaxNumber integer, giverTaxNumber integer, "+
    "companyUsed text, imgUrl text, bankName text, bankBrunchName text, drawer text, giver text, "+
    "usingDate text, expirationDate text, receiptDate text, "+
    "interestFee num, commissionFee num, interestRate num, commissionRate num, receivedPayment num, amount num, "+
    "isUsed bool, isDeprecated bool, isPaid bool"+
    ")";
  static const createSenetTable = "Create table senets("+
    "id integer primary key autoincrement, portfolioId integer, registerNumber integer, drawerTaxNumber integer, giverTaxNumber integer, "+
    "companyUsed text, imgUrl text, drawer text, giver text, "+
    "usingDate text, issuedDate text, expirationDate text, receiptDate text, "+
    "interestFee double, commissionFee double, interestRate double, commissionRate double, receivedPayment double, amount double, "+
    "isUsed bool, isDeprecated bool, isPaid bool"+
    ")";
  static const createPortfolioTable = "Create table portfolios("+
    "id integer primary key autoincrement, "+
    "portfolioName text, companyUsed text, usingDate text, "+
    "interestFee double, commissionFee double, interestRate double, commissionRate double, receivedPayment double, "+
    "totalVolume double, currentRiskVolume double, "+
    "isUsed bool, isDeprecated bool"+
    ")";

  Database _db;

  Future<Database> get db async {
    if(_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    String dbPath = join(await getDatabasesPath(), "faktoring.db");
    var faktoringDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    print("**** db created / opened : $faktoringDb on path : $dbPath");
    return faktoringDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(createCekTable);
    await db.execute(createSenetTable);
    await db.execute(createPortfolioTable);
  }

  // getting objects from database;
  // Tüm ödeme araçlarının listesi;
  Future<List<PaymentInstrument>> getAllInstrument() async {
    Database db = await this.db;
    List<PaymentInstrument> instrumentList = []; //List<PaymentInstrument>();
    var resultCek = await db.query("ceks");
    instrumentList.addAll(List.generate(resultCek.length, (i) => Cek.fromMap(resultCek[i])));
    var resultSenet = await db.query("senets");
    instrumentList.addAll(List.generate(resultSenet.length, (i) => Senet.fromMap(resultSenet[i])));
    return instrumentList;
  }

  // Çeklerin Listesi
  Future<List<Cek>> getCeks() async {
    Database db = await this.db;
    var result = await db.query("ceks");
    return List.generate(result.length, (i) => Cek.fromMap(result[i]));
  }

  // Tek Çek
  Future<Cek> getCek(int id) async {
    Database db = await this.db;
    var result = await db.query("ceks where id=$id");
    return Cek.fromMap(result[0]);
  }

  // Senet Listesi
  Future<List<Senet>> getSenets() async {
    Database db = await this.db;
    var result = await db.query("senets");
    return List.generate(result.length, (i) => Senet.fromMap(result[i]));
  }

  // Tek Senet
  Future<Senet> getSenet(int id) async {
    Database db = await this.db;
    var result = await db.query("senets where id=$id");
    return Senet.fromMap(result[0]);
  }

  // Tanımlanmış portföylerin listesi
  Future<List<Portfolio>> getPortfolios() async {
    Database db = await this.db;
    var result = await db.query("portfolios");
    return List.generate(result.length, (i) => Portfolio.fromMap(result[i]));
  }

  // Tekportföy
  Future<Portfolio> getPortfolio(int id) async {
    Database db = await this.db;
    var result = await db.query("portfolios where id=$id");
    return Portfolio.fromMap(result[0]);
  }

  // portföy içeriğinin (Çek Senet Listesi)
  Future<List<PaymentInstrument>> getPortfolioElements(int id) async {
    Database db = await this.db;
    var cekResult = await db.query("ceks where portfolioId=$id");
    var senetResult = await db.query("senets where portfolioId=$id");
    var cekList = List.generate(cekResult.length, (i) => Cek.fromMap(cekResult[i]));
    var senetList = List.generate(senetResult.length, (i) => Senet.fromMap(senetResult[i]));
    var paymentInstrumentList = []; //List<PaymentInstrument>();
    paymentInstrumentList.addAll(cekList);
    paymentInstrumentList.addAll(senetList);
    return paymentInstrumentList;
  }

  // inserting objects to database;
  Future<int> insertCek(Cek cek) async {
    Database db = await this.db;
    var result = await db.insert("ceks", cek.toMap());
    return result;
  }

  Future<int> insertSenet(Senet senet) async {
    Database db = await this.db;
    var result = await db.insert("senets", senet.toMap());
    return result;
  }

  Future<int> insertPortfolio(Portfolio portfolio) async {
    Database db = await this.db;
    var result = await db.insert("portfolios", portfolio.toMap());
    return result;
  }

  // deleting objects from database;
  Future<int> deleteCek(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete("delete from ceks where id=$id");
    return result;
  }

  Future<int> deleteSenet(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete("delete from senets where id=$id");
    return result;
  }

  Future<int> deletePortfolioOnly(int id) async {
    Database db = await this.db;
    var result = await db.rawDelete("delete from portfolios where id=$id");
    return result;
  }

  // updating database with objects new datas
  Future<int> updateCek(Cek cek) async {
    Database db = await this.db;
    var result = await db.update("ceks", cek.toMap(), where: "id=?", whereArgs: [cek.id]);
    return result;
  }

  Future<int> updateSenet(Senet senet) async {
    Database db = await this.db;
    var result = await db.update("senets", senet.toMap(), where: "id=?", whereArgs: [senet.id]);
    return result;
  }

  Future<int> updatePortfolio(Portfolio portfolio) async {
    Database db = await this.db;
    var result = await db.update("portfolios", portfolio.toMap(), where: "id=?", whereArgs: [portfolio.id]);
    return result;
  }

}