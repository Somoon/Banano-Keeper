// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';

// ignore_for_file: unused_import, prefer_conditional_assignment
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
}
