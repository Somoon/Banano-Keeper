import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/utils/utils.dart';

//for debug prints kDebugMode
import 'package:flutter/foundation.dart';

class WalletsService extends ChangeNotifier {
  List<String> walletsList = [];

  late int activeWallet;
  late int latestWalletID;

  /// sets the active wallet ID to given ID
  ///
  /// @param  nID  the wallet ID
  setActiveWallet(nID) {
    if (nID < walletsList.length) {
      activeWallet = nID;
      String orgName = walletsList[activeWallet];
      services<SharedPrefsModel>().saveActiveWallet(orgName);
      notifyListeners();
    }
  }

  /// sets the latest wallet ID to given ID
  ///
  /// @param  nID  the wallet ID
  setLatestWalletID(int nID) {
    latestWalletID = nID;
    notifyListeners();
  }

  /// to use when creating/importing NEW wallet into the app
  createNewWallet([String seed = "", String name = ""]) async {
    String original_name = "wallet_$latestWalletID";
    if (name == "") {
      name = "Wallet $latestWalletID";
    }
    if (seed == "") {
      seed = Utils().generateSeed();
    }

    String encryptedSeed = await Utils().encryptSeed(seed);

    WalletService wallet =
        WalletService(seed, name, original_name, encryptedSeed);
    await services<DBManager>().insertWallet(name, wallet.toMap());

    addWallet(wallet);
    services.registerSingleton<WalletService>(wallet,
        instanceName: original_name);
    services<WalletService>(instanceName: original_name).createAccount(0);

    setLatestWalletID(++latestWalletID);

    services<SharedPrefsModel>().saveLatestWalletID(latestWalletID);

    notifyListeners();
  }

  /// used when importing a wallet from DB
  importWallet(
      String seed, String name, String original_name, int active_index) {
    if (name == "") {
      name = "Wallet $latestWalletID";
      setLatestWalletID(++latestWalletID);
      services<SharedPrefsModel>().saveLatestWalletID(latestWalletID);
    }
    if (seed == "") {
      seed = Utils().generateSeed();
    }

    WalletService wallet = WalletService(seed, name, original_name, "");

    addWallet(wallet);
    services.registerSingleton<WalletService>(wallet,
        instanceName: original_name);

    notifyListeners();
  }

  createMockWallet() {
    String seed =
        "0000000000000000000000000000000000000000000000000000000000000000";
    createNewWallet(seed);
  }

  addWallet(WalletService wallet) {
    walletsList.add(wallet.original_name);
  }

  /// Deletes given wallet index from DB and the app
  ///
  /// @param index wallet index
  deleteWallet(int index) {
    if (walletsList.asMap().containsKey(index)) {
      if (walletsList.length == 1) {
        unregisterAccounts(walletsList[index]);
        services<DBManager>().deleteWallet(walletsList[index]);
        services.unregister<WalletService>(instanceName: walletsList[index]);
        walletsList.clear();
      } else {
        unregisterAccounts(walletsList[index]);
        services<DBManager>().deleteWallet(walletsList[index]);
        services.unregister<WalletService>(instanceName: walletsList[index]);
        walletsList.removeAt(index);
        setActiveWallet(0);
      }
      notifyListeners();
    }
  }

  /// unregisters accounts of a to be deleted wallet
  ///
  /// @param orgWalletName original wallet name to call service
  void unregisterAccounts(String orgWalletName) {
    List<String> accountsList =
        services<WalletService>(instanceName: orgWalletName).accountsList;
    for (int i = 0; i < accountsList.length; i++) {
      services.unregister<Account>(instanceName: accountsList[i]);
    }
  }

  resetService() {
    walletsList.clear();
    setActiveWallet(0);
    setLatestWalletID(0);
  }
}
