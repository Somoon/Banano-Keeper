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

  List<Account> accounts = [];

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
    accounts[index].setName(newName);
    notifyListeners();
  }

  String getAccountName(int index) {
    return accounts[index].getName();
  }

  int getActiveIndex() {
    return activeIndex;
  }

  setActiveIndex(int index) {
    // print("wallet_service.dart: setActiveIndex: $index");
    activeIndex = index;
    currentAccount.value = accounts[index].getAddress();
    services<SharedPrefsModel>().saveActiveAccount(index);
    notifyListeners();
  }

  bool indexExist(int index) {
    for (var element in accounts) {
      if (element.getIndex() == index) {
        return true;
      }
    }
    return false;
  }

  void addAccount(
      [int? index, nickname = "", address = "", bool newAccount = false]) {
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
    currentAccount.value = address;

    if (nickname == "") {
      nickname = "Account $index";
    }

    num balance = 0;
    Account account = Account(index, nickname, address, balance);

    if (kDebugMode) {
      // print('----------------------------------------------');
      // print("create Account: ${account.toMap()}");
    }
    accounts.add(account);

    if (newAccount) {
      services<DBManager>().insertWalletDataRow(original_name, {
        "index_id": index,
        "index_name": nickname,
        "address": currentAccount.value,
        "balance": 0,
      });
    }

    if (kDebugMode) {
      // print('-------------------- END OF addAccount ----------------------');
    }
  }

  void createAccount(
      [int? index, nickname = "", address = "", bool newAccount = true]) async {
    addAccount(index, nickname, address, newAccount);

    notifyListeners();
  }

  void importAccount(int index, [nickname = "", address = ""]) {
    // print("IMPORTING INDEX $index");
    addAccount(index, nickname, address);
    notifyListeners();
  }

  String getCurrentAccount() {
    if (currentAccount.value == "" || currentAccount.value == null) {
      currentAccount.value = accounts[activeIndex].getAddress();
    }
    return currentAccount.value;
  }

  void removeIndex(int index) {
    if (accounts.length > 1) {
      services<DBManager>()
          .deleteAccount(original_name, accounts[index].getIndex());
      accounts.removeAt(index);
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
