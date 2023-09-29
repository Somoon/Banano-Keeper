// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';

// ignore_for_file: unused_import, prefer_conditional_assignment
import 'dart:convert';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  //type either:
  //pin or Biometric
  late String lockType = "pin";
  String pin = "";
  late int lockoutTime = 0;
  late String currency = "usd";
  late double minToReceive = 0.01;
  late String powSource = "Kalium";
  late String blockExplorer = "";
  late bool Notifs = false;

  //Auth related

  setPin(String newPIN) {
    pin = newPIN;

    notifyListeners();
  }

  String getPin() {
    return pin;
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

  /// Rep data
  List<Representative>? representatives;
  int repUpdate = 0; //store last call for rep list. we update once a day.

  updateRepresentatives() async {
    int ct = DateTime.now().millisecondsSinceEpoch;
    int ms = ct - repUpdate;
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
      repUpdate = DateTime.now().millisecondsSinceEpoch;

      //store copy of representatives to sharedPrefs + repUpdate
      notifyListeners();
    }
  }

  Representative? getRepData(address) {
    Representative? repItem;
    if (representatives!.isNotEmpty) {
      repItem = representatives!.firstWhere((e) => e.address == address);
    }

    return repItem;
  }
}
