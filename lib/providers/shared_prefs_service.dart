import 'dart:convert';
import 'dart:io';

import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:biometric_storage/biometric_storage_win.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async' show Future;

class SharedPrefsModel {
  SharedPreferences sharedPref;

  SharedPrefsModel(this.sharedPref);

  saveLang(String lang) async {
    sharedPref.setString('language', lang);
  }

  // String getString(String key, [String defValue = ""]) {
  //   return sharedPref.getString(key) ?? defValue;
  // }
  //
  // setString(String key, String value) async {
  //   sharedPref.setString(key, value);
  // }

  getLang() async {
    //Return String
    String stringValue = sharedPref.getString('language') ?? "English";
    return stringValue;
  }

  saveTheme(String theme) async {
    sharedPref.setString('theme', theme);
  }

  getTheme() async {
    //Return String
    String stringValue = sharedPref.getString('theme') ?? "Yellow";
    return stringValue;
  }

  saveRepUpdateTime(int repUpdate) async {
    sharedPref.setInt('repUpdate', repUpdate);
  }

  getRepUpdateTime() async {
    int intValue = sharedPref.getInt('repUpdate') ?? 0;
    return intValue;
  }

  saveRepresentatives(List<Representative> repList) async {
    List<String> listArr = [];
    for (Representative rep in repList) {
      Map<String, dynamic> mappedRep = rep.toJson();
      listArr.add(jsonEncode(mappedRep));
    }

    sharedPref.setStringList('representatives', listArr);
  }

  Future<List<Representative>> getRepresentatives() async {
    List<Representative> savedRepList = [];
    List<String> stringValue =
        sharedPref.getStringList('representatives') ?? [];
    for (var item in stringValue) {
      Representative newRep = Representative.fromJson(jsonDecode(item));
      savedRepList.add(newRep);
    }

    return savedRepList;
  }

  saveCurrency(String currency) {
    sharedPref.setString('currency', currency);
  }

  String getCurrency() {
    String stringValue = sharedPref.getString('currency') ?? "USD";
    return stringValue;
  }

  saveActiveWallet(String walletname) async {
    sharedPref.setString('activeWallet', walletname);
  }

  getActiveWallet() async {
    String stringValue = sharedPref.getString('activeWallet') ?? "";
    return stringValue;
  }

  saveActiveAccount(int addressIndex) async {
    sharedPref.setInt('activeAccount', addressIndex);
  }

  getActiveAccount() async {
    int stringValue = sharedPref.getInt('activeAccount') ?? 0;
    return stringValue;
  }

  getLatestWalletID() async {
    int latestWalletID = sharedPref.getInt('latestWalletID') ?? 0;
    return latestWalletID;
  }

  void saveLatestWalletID(int latestWalletID) async {
    sharedPref.setInt('latestWalletID', latestWalletID);
  }

  getPoWSource() async {
    String powSource = sharedPref.getString('PoWSource') ?? "Kalium";
    return powSource;
  }

  void savePoWSource(String powSource) async {
    sharedPref.setString('PoWSource', powSource);
  }

  getNode() async {
    String nodeName = sharedPref.getString('nodeName') ?? "Kalium";
    return nodeName;
  }

  void saveNode(String powSource) async {
    sharedPref.setString('nodeName', powSource);
  }

  getDataSource() async {
    String sourceName = sharedPref.getString('dataSource') ?? "Moonano";
    return sourceName;
  }

  void saveDataSource(String sourceName) async {
    sharedPref.setString('dataSource', sourceName);
  }

  getThreadCount() async {
    int poWThreadCount = sharedPref.getInt('PoWThreadCount') ?? 3;
    return poWThreadCount;
  }

  void saveThreadCount(int threadCount) async {
    sharedPref.setInt('PoWThreadCount', threadCount);
  }

  getPin() async {
    String pinE = sharedPref.getString('pin') ?? "0";
    final pin = await Utils().decryptSeed(pinE);
    return pin;
  }

  void savePin(pin) async {
    final key = await bioStorageFetchKey();
    final ecryptedPIN = await Utils().encryptSeed(pin, key);
    sharedPref.setString('pin', ecryptedPIN);
  }

  bioStorageSaveKey(String masterKey) async {
    BiometricStorageFile? _authStorage;

    if (!kIsWeb && Platform.isWindows) {
      _authStorage = await Win32BiometricStoragePlugin().getStorage('masterKey',
          options: StorageFileInitOptions(
            authenticationRequired: false,
          ));
    } else {
      _authStorage = await BiometricStorage().getStorage('masterKey',
          options: StorageFileInitOptions(
            authenticationRequired: false,
          ));
    }

    await _authStorage.write(masterKey);
    print("written pin to secuStorage");
  }

  Future<String> bioStorageFetchKey() async {
    BiometricStorageFile? authStorage;

    if (!kIsWeb && Platform.isWindows) {
      authStorage = await Win32BiometricStoragePlugin().getStorage('masterKey',
          options: StorageFileInitOptions(
            authenticationRequired: false,
          ));
    } else {
      authStorage = await BiometricStorage().getStorage('masterKey',
          options: StorageFileInitOptions(
            authenticationRequired: false,
          ));
    }

    final result = await authStorage.read();
    return result ?? '0';
  }

  getAuthOnBoot() async {
    bool status = sharedPref.getBool('authOnBoot') ?? false;
    return status;
  }

  void saveAuthOnBoot(bool newStatus) async {
    sharedPref.setBool('authOnBoot', newStatus);
  }

  getMinToReceive() async {
    double minToReceive = sharedPref.getDouble('minToReceive') ?? 0.01;
    return minToReceive;
  }

  void saveMinToReceive(double value) async {
    sharedPref.setDouble('minToReceive', value);
  }

  getAutoReceive() async {
    bool status = sharedPref.getBool('autoReceive') ?? true;
    return status;
  }

  void saveAutoReceive(bool newStatus) async {
    sharedPref.setBool('autoReceive', newStatus);
  }

  getNoAuthForSmallTx() async {
    bool status = sharedPref.getBool('authForSmallTx') ?? true;
    return status;
  }

  void saveNoAuthForSmallTx(bool newStatus) async {
    sharedPref.setBool('authForSmallTx', newStatus);
  }

  getNumOfAllowedRx() async {
    int numOfAllowedReceivables =
        sharedPref.getInt('numOfAllowedReceivables') ?? 10;
    return numOfAllowedReceivables;
  }

  void saveNumOfAllowedRx(int value) async {
    sharedPref.setInt('numOfAllowedReceivables', value);
  }

  Future<List> getStoredValues() async {
    var isInit = sharedPref.containsKey('isInitialized');
    var lang = "English";
    var theme = "Yellow";
    var activeWallet = "";
    var activeAccount = 0;
    var latestWalletID = 0;
    String powSource = "Kalium";
    String nodeName = "Kalium";
    int powThreadCount = 3;
    String pin = "0";
    List<Representative> repList = [];
    int repUpdate = 0;
    bool authOnBoot = false;
    bool autoReceive = true;
    double minToReceive = 0.01;
    int numOfAllowedReceivables = 10;
    bool noAuthForSmallTx = false;
    String dataSource = "Moonano";
    if (isInit) {
      lang = await getLang();
      theme = await getTheme();
      activeWallet = await getActiveWallet();
      activeAccount = await getActiveAccount();
      latestWalletID = await getLatestWalletID();
      pin = await getPin();
      powSource = await getPoWSource();
      powThreadCount = await getThreadCount();
      repList = await getRepresentatives();
      repUpdate = await getRepUpdateTime();
      authOnBoot = await getAuthOnBoot();
      nodeName = await getNode();
      autoReceive = await getAutoReceive();
      minToReceive = await getMinToReceive();
      numOfAllowedReceivables = await getNumOfAllowedRx();
      noAuthForSmallTx = await getNoAuthForSmallTx();
      dataSource = await getDataSource();
    }

    return [
      isInit, //0
      lang, //1
      theme, //2
      activeWallet, //3
      activeAccount, //4
      latestWalletID, //5
      pin, //6
      powSource, //7
      repList, //8
      repUpdate, //9
      powThreadCount, //10
      authOnBoot, //11
      nodeName, //12
      autoReceive, //13
      minToReceive, //14
      numOfAllowedReceivables, //15
      noAuthForSmallTx, //16
      dataSource, //17
    ];
  }

  void initliazeValues() async {
    if (kDebugMode) {
      print("shared_prefs: initliazeValues");
    }
    // bool langExist = sharedPref.containsKey('language');
    // // bool themeExist = sharedPref.containsKey('theme');
    // if (!langExist)
    saveLang("English");
    // if (!themeExist)
    saveTheme("Yellow");
    saveActiveAccount(0);
    // saveActiveWallet(0);
    saveLatestWalletID(0);
    await sharedPref.setString("isInitialized", "true");
  }

  void clearAll() async {
    if (sharedPref.containsKey("isInitialized")) {
      sharedPref.remove("isInitialized");
    }
    if (sharedPref.containsKey("latestWalletID")) {
      sharedPref.remove("latestWalletID");
    }
    if (sharedPref.containsKey("activeAccount")) {
      sharedPref.remove("activeAccount");
    }
    if (sharedPref.containsKey("activeWallet")) {
      sharedPref.remove("activeWallet");
    }
    if (sharedPref.containsKey("PoWSource")) sharedPref.remove("PoWSource");
    if (sharedPref.containsKey("theme")) sharedPref.remove("theme");
    if (sharedPref.containsKey("language")) sharedPref.remove("language");
    if (sharedPref.containsKey("pin")) sharedPref.remove("pin");
    if (sharedPref.containsKey("representatives")) {
      sharedPref.remove("representatives");
    }
    if (sharedPref.containsKey("repUpdate")) sharedPref.remove("repUpdate");
    if (sharedPref.containsKey("PoWThreadCount"))
      sharedPref.remove("PoWThreadCount");
    if (sharedPref.containsKey("authOnBoot")) sharedPref.remove("authOnBoot");
    if (sharedPref.containsKey("nodeName")) sharedPref.remove("nodeName");
    if (sharedPref.containsKey("autoReceive")) sharedPref.remove("autoReceive");
    if (sharedPref.containsKey("minToReceive")) {
      sharedPref.remove("minToReceive");
      if (sharedPref.containsKey("numOfAllowedReceivables")) {
        sharedPref.remove("numOfAllowedReceivables");
      }
      if (sharedPref.containsKey("noAuthForSmallTx")) {
        sharedPref.remove("noAuthForSmallTx");
      }
      if (sharedPref.containsKey("dataSource")) sharedPref.remove("dataSource");
    }
  }
}
