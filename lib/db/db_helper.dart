class DBHelper {
  static const int DB_VERSION = 1;
  static const String WALLETS_SQL = """
  CREATE TABLE "wallets" (
	"ID"	INTEGER NOT NULL UNIQUE,
	"original_name"	TEXT NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"active_index"	INTEGER NOT NULL,
	"seed_encrypted"	INTEGER NOT NULL,
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
	"name"	INTEGER NOT NULL,
	PRIMARY KEY("ID" AUTOINCREMENT)
);""";

  generatenewWalletTable(String walletName) {
    return """CREATE TABLE "$walletName" (
	"ID"	INTEGER NOT NULL UNIQUE,
	"index"	INTEGER NOT NULL UNIQUE,
	"index_name"	INTEGER,
	PRIMARY KEY("ID" AUTOINCREMENT)
);""";
  }
}
