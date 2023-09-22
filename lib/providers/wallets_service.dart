// ignore_for_file: unnecessary_import

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:nanodart/nanodart.dart';
// import 'package:banano_library/banano_library.dart';
// import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';

//for debug prints kDebugMode
import 'package:flutter/foundation.dart';

class WalletsService extends ChangeNotifier {
  List<WalletService> wallets = <WalletService>[];
  List<String> walletsList = [];

  late int activeWallet;
  late int latestWalletID;

  setActiveWallet(nID) {
    activeWallet = nID;

    // String orgName = wallets[activeWallet].original_name;
    String orgName =
        services<WalletService>(instanceName: walletsList[activeWallet])
            .original_name;
    services<SharedPrefsModel>().saveActiveWallet(orgName);
    notifyListeners();
  }

  setLatestWalletID(nID) {
    // print('wallets2.dart: setLAtestWalletID: setting to ID $nID');
    latestWalletID = nID;
    notifyListeners();
  }

  //to use when creating/importing NEW wallet into the app
  createNewWallet([String seed = "", String name = ""]) async {
    if (kDebugMode) {
      print(
          '-------------------- START OF createNewWallet ----------------------');
    }

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
    wallets[wallets.length - 1].createAccount(0);
    services.registerSingleton<WalletService>(wallet,
        instanceName: original_name);
    services<WalletService>(instanceName: original_name).createAccount(0);
    if (kDebugMode) {
      // print("wallets_service.dart: createNewWallet: ");
      // print(
      // "wallets_service.dart: createNewWallet: latestWaleltID before saving: $latestWalletID");
    }
    setLatestWalletID(++latestWalletID);

    services<SharedPrefsModel>().saveLatestWalletID(latestWalletID);

    notifyListeners();
  }

  //used when importing from DB
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

    if (kDebugMode) {
      // print(
      //     "wallets_service.dart: createWallet: created $name - $original_name");
    }

    notifyListeners();
  }

  createMockWallet() {
    if (kDebugMode) {
      // print("wallets_service.dart: createMockWallet");
    }
    String seed =
        "0000000000000000000000000000000000000000000000000000000000000000";
    createNewWallet(seed);
  }

  addWallet(WalletService wallet) {
    wallets.add(wallet);
    walletsList.add(wallet.original_name);
  }

  deleteWallet(index) {
    if (walletsList.asMap().containsKey(index)) {
      // if (wallets.asMap().containsKey(index)) {
      if (walletsList.length == 1) {
        // if (wallets.length == 1) {
        //should send user to InitialPage here?
        walletsList.clear();
        // wallets.clear();
      } else {
        services<DBManager>().deleteWallet(wallets[index].original_name);
        // wallets.removeAt(index);

        services.unregister<WalletService>(instanceName: walletsList[index]);
        walletsList.removeAt(index);
      }
      setActiveWallet(0);
    }
    notifyListeners();
  }

  resetService() {
    wallets.clear();
    setActiveWallet(0);
    setLatestWalletID(0);
  }
}
