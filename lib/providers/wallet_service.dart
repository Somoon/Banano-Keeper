// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';

// ignore_for_file: unused_import, prefer_conditional_assignment, unnecessary_import

import 'dart:typed_data';

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nanodart/nanodart.dart';

class WalletService extends ChangeNotifier {
  int activeIndex;
  String name;
  String original_name;
  String seed;
  String encryptedSeed;
  // =      "0000000000000000000000000000000000000000000000000000000000000000";

  ValueNotifier<String> currentAccount = ValueNotifier<String>('');
  WalletService(
    this.seed,
    this.name,
    this.original_name,
    this.encryptedSeed, [
    this.activeIndex = 0,
  ]);
  List<String> accountsList = [];

  void setSeed(newSeed) {
    seed = newSeed;
    notifyListeners();
  }

  String getSeed(walletID) {
    return seed;
  }

  void setWalletName(newName) {
    name = newName;

    notifyListeners();
  }

  String getWalletName() {
    return name;
  }

  void editWalletName(String newName) {
    services<DBManager>().updateWalletName(newName, original_name);
    setWalletName(newName);
  }

  void editAccountName(int index, String newName) {
    services<DBManager>().updateAccountName(original_name, index, newName);

    String accOrgName = accountsList[activeIndex];
    services<Account>(instanceName: accOrgName).setName(newName);
    notifyListeners();
  }

  String getAccountName(int index) {
    //accounts[index].getName();
    String accOrgName = accountsList[activeIndex];
    return services<Account>(instanceName: accOrgName).getName();
  }

  void addAccount(int? index, String nickname, String address, String balance,
      int lastUpdate, String representative,
      [bool newAccount = false]) {
    // print('-------------------- START OF addAccount ----------------------');

    if (index == null) {
      index = 0;
    }

    while (indexExist(index!)) {
      index++;
    }

    //use less resource if it was created before and saved
    if (address == "") {
      String privateKey = getPrivateKey(index);
      if (kDebugMode) {
        print("private key: $privateKey");
      }
      // Getting public key from this private key
      String pubKey = NanoKeys.createPublicKey(privateKey);
      // Getting address (nano_, ban_) from this pubkey
      address = NanoAccounts.createAccount(NanoAccountType.BANANO, pubKey);
      if (kDebugMode) {
        print("address: $address");
      }
    }
    // currentAccount.value = address;

    if (nickname == "") {
      nickname = "Account $index";
    }
    Account account =
        Account(index, nickname, address, balance, lastUpdate, representative);
    if (balance != "0") {
      account.opened = true;
    }

    if (kDebugMode) {
      // print('----------------------------------------------');
      // print("create Account: ${account.toMap()}");
    }

    String accName = "${original_name}_$index";
    accountsList.add(accName);

    services.registerSingleton<Account>(account, instanceName: accName);

    if (newAccount) {
      services<DBManager>().insertWalletDataRow(original_name, {
        "index_id": index,
        "index_name": nickname,
        "address": currentAccount.value,
        "balance": balance,
        "last_update": lastUpdate,
        "representative": representative
      });
    }

    if (kDebugMode) {
      // print('-------------------- END OF addAccount ----------------------');
    }
  }

  void createAccount(
      [int index = 0,
      nickname = "",
      address = "",
      balance = "0",
      lastUpdate = 0,
      representative = "",
      bool newAccount = true]) async {
    addAccount(index, nickname, address, balance, lastUpdate, representative,
        newAccount);

    notifyListeners();
  }

  void importAccount(int index,
      [nickname = "",
      address = "",
      balance = "0",
      lastUpdate = 0,
      representative = ""]) {
    // print("IMPORTING INDEX $index");
    addAccount(index, nickname, address, balance, lastUpdate, representative);
    notifyListeners();
  }

  String getCurrentAccount() {
    if (currentAccount.value == "" || currentAccount.value == null) {
      String accOrgName = accountsList[activeIndex];
      currentAccount.value =
          services<Account>(instanceName: accOrgName).getAddress();
      // currentAccount.value = accounts[activeIndex].getAddress();
    }
    return currentAccount.value;
  }

  int getActiveIndex() {
    return activeIndex;
  }

  setActiveIndex(int index) {
    // print("wallet_service.dart: setActiveIndex: $index");
    activeIndex = index;
    // currentAccount.value = accounts[index].getAddress();
    String accountInstanceName = accountsList[index];
    // print("wallet_service.dart: setActiveIndex: $accountInstanceName");
    currentAccount.value =
        services<Account>(instanceName: accountInstanceName).getAddress();
    // print("wallet_service.dart: setActiveIndex: ${currentAccount.value}");

    services<SharedPrefsModel>().saveActiveAccount(index);
    try {
      // notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("setActiveIndex error");
        print(e);
      }
    }
  }

  bool indexExist(int index) {
    for (int i = 0; i < accountsList.length; i++) {
      String accOrgName = accountsList[i];
      // if (services.isRegistered<Account>(instanceName: accOrgName)) {
      var acc = services<Account>(instanceName: accOrgName);
      if (acc.getIndex() == index) {
        return true;
      }
      // }
    }
    return false;
  }

  void removeIndex(int index) {
    if (accountsList.length > 1) {
      String accOrgName = accountsList[index];

      services<DBManager>().deleteAccount(original_name,
          services<Account>(instanceName: accOrgName).getIndex());
      services.unregister<Account>(instanceName: accOrgName);
      accountsList.removeAt(index);

      if (index == activeIndex) {
        setActiveIndex(0);
      }
      notifyListeners();
    }
  }

  String getPrivateKey(index) {
    return NanoKeys.seedToPrivate(seed, index);
  }

  Map<String, dynamic> toMap() {
    return {
      'original_name': original_name,
      'name': name,
      'active_index': activeIndex,
      'seed_encrypted': encryptedSeed,
    };
  }
}
