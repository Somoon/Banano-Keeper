// ignore_for_file: file_names, constant_identifier_names

import 'dart:async';

import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBManager {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  late Database database;

  static const String WALLETS_SQL = """
  CREATE TABLE "wallets" (
	"ID"	INTEGER NOT NULL UNIQUE,
	"original_name"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"active_index"	INTEGER NOT NULL,
	"seed_encrypted"	TEXT NOT NULL,
	PRIMARY KEY("ID" AUTOINCREMENT)
);""";
  static const String ACTIVE_WALLET_SQL = """
  CREATE TABLE "active_wallet" (
	"original_name"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("original_name")
);""";

  static const String CONTACTS_SQL = """
  CREATE TABLE "contacts" (
	"ID"	INTEGER NOT NULL UNIQUE,
	"address"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	PRIMARY KEY("ID" AUTOINCREMENT)
);""";

  Future<void> deleteDatabase() async {
    await database.close();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    databaseFactory.deleteDatabase(path);
  }

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    // final Directory tempDir = await getTemporaryDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    // print(tempDir);
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database tables
  Future _onCreate(Database db, int version) async {
    await db.execute(WALLETS_SQL);
    await db.execute(ACTIVE_WALLET_SQL);
    await db.execute(CONTACTS_SQL);
  }

  String generateNewWalletTable(String walletName) {
    //IF NOT EXISTS
    return """CREATE TABLE '$walletName' (
	'ID'	INTEGER NOT NULL UNIQUE,
	'index_id'	INTEGER NOT NULL UNIQUE,
	'index_name' TEXT NOT NULL,
	'address' TEXT NOT NULL,
	'balance' TEXT DEFAULT 0,
	'last_update' TEXT DEFAULT 0,
	"representative" TEXT NOT NULL,
	PRIMARY KEY('ID' AUTOINCREMENT)
);""";
  }

  Future<void> insertWallet(walletName, walletMap) async {
    // print("inserting wallet");
    // print(

    await database.insert(
      "wallets",
      walletMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
      // ),
    );

    //create new wallet table
    String walletSql = generateNewWalletTable(walletMap['original_name']);
    // print(
    //     '--------------------------------------------------------------------------');
    // print(walletMap['original_name']);
    // print(wallet_sql);
    // print(
    //     '--------------------------------------------------------------------------');

    await database.execute(walletSql);
  }

  Future getWallets() async {
    final List<Map<String, dynamic>> maps = await database.query('wallets');

    return maps;
  }

  Future<void> insertWalletDataRow(walletName, rowData) async {
    await database.insert(
      walletName,
      rowData,
    );
  }

  Future getWalletData(originalName) async {
    // List<Map> result =
    //     await database.rawQuery('SELECT * FROM ? WHERE name=?', ['Mary']);
    final List<Map<String, dynamic>> maps = await database.query(originalName);

    // for (var walletData in maps) {
    //   if (kDebugMode) {
    //     // print(
    //     //     "done loading wallet ${walletData['index']} ${walletData['index_name']} ${walletData['address']} ${walletData['balance']}");
    //   }
    //   //load the wallet data from its table $original_name
    // }

    return maps;
  }

  Future<void> updateAccountName(
      String tableName, int index, String newName) async {
    await database.rawUpdate(
      'UPDATE $tableName SET index_name = "$newName" WHERE index_id = $index',
    );
  }

  Future<void> updateAccountBalance(
      String tableName, int index, String newBalance) async {
    await database.rawUpdate(
      'UPDATE $tableName SET balance = "$newBalance" WHERE index_id = $index',
    );
  }

  Future<void> updateAccountTime(
      String tableName, int index, String lastUpdate) async {
    await database.rawUpdate(
      'UPDATE $tableName SET last_update = "$lastUpdate" WHERE index_id = $index',
    );
  }

  Future<void> updateAccountRep(
      String tableName, int index, String newRep) async {
    await database.rawUpdate(
      'UPDATE $tableName SET representative = "$newRep" WHERE index_id = $index',
    );
  }

  Future<void> deleteAccount(
    String tableName,
    int index,
  ) async {
    // print("deleting acc");
    await database.rawDelete(
      'DELETE from $tableName where index_id = "$index"',
    );
  }

  Future<void> updateWalletName(String newName, String originalName) async {
    await database.rawUpdate(
      'UPDATE wallets SET name = "$newName" WHERE original_name = "$originalName"',
    );
  }

  Future<void> deleteWallet(String originalName) async {
    await database.rawDelete(
      'DELETE from wallets where original_name = "$originalName"',
    );
    await database.rawDelete(
      'DROP TABLE IF EXISTS $originalName;',
    );
  }
}
