// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// ignore_for_file: unused_import, prefer_conditional_assignment

import 'dart:convert';
import 'dart:typed_data';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/account_history_response.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nanodart/nanodart.dart';

class Account extends ChangeNotifier {
  late int index;
  late String address;
  late String name;
  late num balance;
  late String representative;
  bool opened = false;
  //placeholders for now
  int lastUpdate = 0; //date of last update
  Account(this.index, this.name, this.address, this.balance) {
    representative = "";
  }

  setIndex(int newIndex) {
    index = newIndex;
    notifyListeners();
  }

  int getIndex() {
    return index;
  }

  setBalance(num newBalance) {
    balance = newBalance;
    print("setBalance: $balance");
    notifyListeners();
  }

  num getBalance() {
    return balance;
  }

  setAddress(String newAddress) {
    address = newAddress;
    notifyListeners();
  }

  String getAddress() {
    return address;
  }

  void setName(String newName) {
    name = newName;
    notifyListeners();
  }

  String getName() {
    return name;
  }

  void setRep(String newRep) {
    representative = newRep;
    notifyListeners();
  }

  String getRep() {
    return representative;
  }

  //
  updateTime() {
    //get current unix time
    //set lastUpdate to it
    //notify
  }
  void setLastUpdate(int time) {
    print("look into using updateTime fn, much easier");
    lastUpdate = time;
  }

  int getLastUpdate() {
    return lastUpdate;
  }

///////////////////////////////////////////
  List<AccountHistory> history = [];

  bool completed = false;
  List res = [];
  Map<String, dynamic> overviewResp = {};
  getHistory() async {
    var historyRes = await AccountAPI().getHistory(getAddress(), 8);
    // "ban_14xjizffqiwjamztn4edhmbinnaxuy4fzk7c7d6gywxigydrrxftp4qgzabh",
    // 8);

    res = jsonDecode(historyRes.body);
    // print('------------------------------------------------------------');
  }

  handleResponse() {
    print(completed);
    try {
      if (res.isNotEmpty || res != null) {
        for (var row in res) {
          String hash = row['hash'];
          String address = row['address'] ?? "";
          String type = row['type'];
          int height = row['height'];
          int timestamp = row['timestamp'];
          String date = row['date'];
          String amountRaw = row['amountRaw'] ?? "";
          num amount = row['amount'] ?? num.parse("0");
          String newRep = row['newRepresentative'] ?? "";
          AccountHistory t = AccountHistory(hash, address, type, height,
              timestamp, date, amountRaw, amount, newRep);

          // print(t.toJson());
          if (kDebugMode) {
            // print("creating history item in HandleResponse");
          }
          history.add(t);
          // history.reversed;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    completed = true;
    notifyListeners();
  }

  void onRefreshUpdateHistory() async {
    await getHistory();

    if (res == null || res.length == 0) return;
    res.reversed.forEach((row) {
      var exist = false;
      AccountHistory t = AccountHistory(
          row['hash'],
          row['address'] ?? "",
          row['type'],
          row['height'],
          row['timestamp'],
          row['date'],
          row['amountRaw'] ?? "",
          row['amount'] ?? num.parse("0"),
          row['newRepresentative'] ?? "");
      history.forEach((element) {
        // print(
        //     "${element.height} == ${t.height} => ${element.height == t.height}");
        if (element.height == t.height) {
          exist = true;
        }
      });
      if (!exist) {
        // print("RETURN TRUE");
        // exist = false;

        if (kDebugMode) {
          print("DIFFED ${t.toJson()}");
        }
        if (kDebugMode) {
          print("before insert ${history.length}");
        }
        history.insert(0, t);
        if (kDebugMode) {
          print("after insert ${history.length}");
        }
        exist = false;
        // res.remove(item);
      }
    });
    if (kDebugMode) {
      print(history.length);
    }
    notifyListeners();
  }

  getOverview() async {
    var overview = await AccountAPI().getOverview(getAddress());
    // "ban_14xjizffqiwjamztn4edhmbinnaxuy4fzk7c7d6gywxigydrrxftp4qgzabh");

    overviewResp = jsonDecode(overview.body);

    if (kDebugMode) {
      print('------------------------------------------------------------');
      print(overviewResp);
    }
  }

  bool hasReceivables = false;
  handleOverviewResponse() async {
    try {
      if (overviewResp.isNotEmpty || overviewResp != null) {
        opened = overviewResp['opened'];
        hasReceivables = (overviewResp['receivable'] > 0);
        if (hasReceivables && !opened) {
          if (kDebugMode) {
            print(
                "Account is not opened yet, we have receivable, starting open process...");
          }
          openAcc();
        }
        if (opened) {
          var newBalance = overviewResp['balance'].toStringAsFixed(2);
          print(
              'ACCOUNT: handleOverviewResponse: get Balance from resp ${newBalance}');

          newBalance = num.parse(newBalance);
          if (kDebugMode) {
            print(getBalance() != newBalance);
          }
          String newRep = overviewResp['representative'];
          if (getBalance() != newBalance) {
            setBalance(newBalance);

            if (kDebugMode) {
              print(
                  'ACCOUNT: handleOverviewResponse: newBalance ${newBalance} ${getBalance().toString()}');
            }
          }
          if (getRep() != newRep) {
            setRep(newRep);
          }

          notifyListeners();

          print("DONE EXUCTING NOTIFYLIS");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("HandleOVerviewResp : $e");
      }
    }
  }

  openAcc() async {
    var recRes = await AccountAPI().getReceivables(address);
    var receivablesData = jsonDecode(recRes.body);
    String amountRaw = receivablesData[0]['amountRaw'];
    String hash = receivablesData[0]['hash'];

    //def test
    String representative =
        "ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid";
    //for open state
    String previous = "".padLeft(64, "0");

    int activeWallet = services<WalletsService>().activeWallet;
    String privateKey =
        services<WalletsService>().wallets[activeWallet].getPrivateKey(index);

    if (kDebugMode) {
      print("private key $privateKey");
    }
    int accountType = NanoAccountType.BANANO;
    String calculatedHash = NanoBlocks.computeStateHash(accountType, address,
        previous, representative, BigInt.parse(amountRaw), hash);
    // Signing a block
    String sign = NanoSignatures.signBlock(calculatedHash, privateKey);

    // print(sign);

    StateBlock openBlock =
        StateBlock(address, previous, representative, amountRaw, hash, sign);

    // Map<String, dynamic> block = {
    //   "type": "state",
    //   "account": address,
    //   "previous": previous,
    //   "representative": representative,
    //   "balance": amountRaw,
    //   "link": hash,
    //   "signature": sign,
    //   // "private"
    // };

    String hashResponse =
        await AccountAPI().processRequest(openBlock.toJson(), "open");
    if (kDebugMode) {
      print(hashResponse);
    }
    //
    // await openBlock();
    // var a = await getHistory();
  }

  toMap() {
    return {
      "index": index,
      "name": name,
      "address": address,
      "balance": balance,
      "lastUpdate": lastUpdate
    };
  }
}
