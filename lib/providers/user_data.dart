// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';

// ignore_for_file: unused_import, prefer_conditional_assignment
import 'dart:convert';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/currency_conversion.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:nanodart/nanodart.dart';

class UserData extends ChangeNotifier {
  //type either:
  //pin or Biometric
  late String lockType = "pin";
  String pin = "";
  late int lockoutTime = 0;
  late bool authOnBoot = false;
  late String currency = "USD";
  late double minToReceive = 0.01;
  late String powSource = "Kalium";
  late int threadCount = 3;
  late String blockExplorer = "";
  late bool Notifs = false;

  getCurrency() {
    return currency;
  }

  setCurrency(String curr) {
    currency = curr;
    services<SharedPrefsModel>().saveCurrency(currency);
    notifyListeners();
  }

  switchCurrency() {
    List<String> currencies =
        services<CurrencyConversion>().price.keys.toList();
    int i = currencies.indexOf(currency);
    if (i == currencies.length - 1) {
      setCurrency(currencies[0]);
    } else {
      setCurrency(currencies[i + 1]);
    }
  }

  //Auth related

  setPin(String newPIN) {
    pin = newPIN;

    notifyListeners();
  }

  String getPin() {
    return pin;
  }

  setAuthOnBoot(bool newStatus) {
    authOnBoot = newStatus;
    notifyListeners();
  }

  bool getAuthOnBoot() {
    return authOnBoot;
  }

  setLockType(String type) {
    lockType = type;
  }

  getLockType() {
    return lockType;
  }

  //PoW related

  String getPoWSource() {
    return powSource;
  }

  void setPoWSource(source) {
    powSource = source;
    notifyListeners();
  }

  int getThreadCount() {
    return threadCount;
  }

  void setThreadCount(int newThreadCount) {
    threadCount = newThreadCount;
    notifyListeners();
  }

  /// Rep data
  List<Representative>? representatives;
  int repUpdate = 0;

  /// update the cached rep list from the internet is one passed since last fetch
  updateRepresentatives() async {
    int ct = DateTime.now().millisecondsSinceEpoch;
    int ms = ct - getRepUpdateTime();
    int days = Duration(milliseconds: ms).inDays;

    if (days > 0) {
      var repResp = await AccountAPI().getRepresentatives();
      var repData = jsonDecode(repResp.body);
      List<Representative> _representatives = [];
      for (var rep in repData) {
        _representatives.add(Representative.fromJson(rep));
      }

      _representatives
          .sort((a, b) => a.weightPercentage.compareTo(b.weightPercentage));
      representatives = List.from(_representatives);
      setRepUpdateTime(DateTime.now().millisecondsSinceEpoch);

      await services<SharedPrefsModel>().saveRepresentatives(representatives!);

      // services<SharedPrefsModel>().getRepresentatives();
      notifyListeners();
    }
  }

  /// return data of rep if it exist
  ///
  /// @param address address of the representative
  Representative? getRepData(String address) {
    Representative? repItem;

    try {
      repItem = representatives!.firstWhere((e) => e.address == address);
    } catch (e) {
      repItem = null;
    }

    return repItem;
  }

  /// sets the cached representatives list.
  ///
  /// @param repList list of representatives
  void setRepresentativesList(List<Representative> repList) {
    representatives = List<Representative>.from(repList);
    notifyListeners();
  }

  /// update stored time to fetch new rep list from the internet
  ///
  /// @param mSeconds time
  setRepUpdateTime(int mSeconds) {
    services<SharedPrefsModel>().saveRepUpdateTime(mSeconds);

    repUpdate = mSeconds;
    notifyListeners();
  }

  /// return stored time to fetch new rep list from the internet
  int getRepUpdateTime() {
    return repUpdate;
  }
}
