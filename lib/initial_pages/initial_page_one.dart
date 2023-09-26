// ignore_for_file: prefer_const_constructors

import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/initial_pages/initial_page_import.dart';
import 'package:bananokeeper/initial_pages/initial_page_new_information.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/account.dart';

class InitialPageOne extends StatefulWidget with GetItStatefulWidgetMixin {
  InitialPageOne({super.key});

  @override
  InitialPageOneState createState() => InitialPageOneState();
}

class InitialPageOneState extends State<InitialPageOne> with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    doInit();
  }

  void doInit() async {

    resetServices();

    // register services
    initServices();

    await services.allReady();
    await _initSharedPref();
    await setupUserData();
  }

  Future<void> _initSharedPref() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    services.registerSingleton<SharedPrefsModel>(SharedPrefsModel(sharedPref));
    print("sharedpred ready");
  }

  Future<void> setupUserData() async {
    await services<DBManager>().init();

    var userValues = await services<SharedPrefsModel>().getStoredValues();

    // services<WalletsService>().createMockWallet();

    //new app launch - no data

    if (!userValues[0]) {
      // send user to firsttime page v
      // services<WalletsService>().setLatestWalletID(0);

      // services<WalletsService>().createNewWallet();
      // services<SharedPrefsModel>().sharedPref.setBool("isInitialized", true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // constraints: BoxConstraints(
            //   minWidth: 100,
            //   maxWidth: 500,
            //   // maxHeight: 600,
            // ),
            decoration: BoxDecoration(
              color: currentTheme.primary,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 50,
                    bottom: 50,
                  ),
                  child: AutoSizeText(
                    "Banano Keeper",
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(
                  height: 55,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          "Welcome! Create new or import a wallet to start using the app.",
                          style: TextStyle(
                            color: currentTheme.text,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 125,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 150,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),

                                  side: MaterialStatePropertyAll<BorderSide>(
                                    BorderSide(
                                      color: currentTheme.buttonOutline,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InitialPageInformation()),
                                    );

                                    /*
                                    services<WalletsService>()
                                        .setLatestWalletID(0);

                                    services<WalletsService>().createNewWallet();
                                    services<SharedPrefsModel>()
                                        .initliazeValues();
                                    services<SharedPrefsModel>()
                                        .sharedPref
                                        .setBool("isInitialized", true);

                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return MainAppLogic();
                                    }), (r) {
                                      return false;
                                    });

                                     */
                                  });
                                },
                                child: AutoSizeText(
                                  "New Wallet",
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: currentTheme.fontSize,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              height: 60,
                              width: 150,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  side: MaterialStatePropertyAll<BorderSide>(
                                    BorderSide(
                                      color: currentTheme.buttonOutline,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InitialPageImport()),
                                    );
                                  });
                                },
                                child: AutoSizeText(
                                  "Import Wallet",
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: currentTheme.fontSize,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
