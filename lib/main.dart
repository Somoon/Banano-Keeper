import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_app_logic.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//for debug prints kDebugMode
import 'package:flutter/foundation.dart';
// void main() => runApp(const MyApp());
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isNewUser = false;
Future<void> _initSharedPref() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  services.registerSingleton<SharedPrefsModel>(SharedPrefsModel(sharedPref));
}

Future<void> setupUserData() async {
  await _initSharedPref();
  await services<DBManager>().init();

  var userValues = await services<SharedPrefsModel>().getStoredValues();

  // services<WalletsService>().createMockWallet();

  //new app launch - no data

  if (!userValues[0]) {
    isNewUser = true;
    // send user to firsttime page v
  } else {
    if (kDebugMode) {
      // print("main.dart: not new user: $userValues");
    }
    await services.allReady();
    //set theme and language
    services<LocalizationModel>().setLocale(userValues[1]);
    services<ThemeModel>().setTheme(userValues[2]);
    services<UserData>().setPin(userValues[6]);
    services<PoWSource>().setAPI(userValues[7]);
    services<UserData>().setRepresentativesList(userValues[8]);
    services<UserData>().setRepUpdateTime(userValues[9]);

    //get active wallet and index

    //used for creation and import new wallets
    if (kDebugMode) {
      // print("main.dart: setting latest wallet to ${userValues[5]}");
    }
    services<WalletsService>().setLatestWalletID(userValues[5]);

    //load wallets from DB
    String activeWalletName = userValues[3];
    int activeAccountIndex = userValues[4];

    await loadWalletsFromDB(activeWalletName, activeAccountIndex);

    // services<WalletsService>()
    //     .wallets[userValues[3]]
    //     .setActiveIndex(userValues[4]);
    // ---- for testing purposed, import from encyrpted storage in prod

    //set active wallet after creating / loading the wallet(s)
  }
}

Future<void> loadWalletsFromDB(
    String activeWalletName, int activeAccountIndex) async {
  int index = 0;
  var walletsData = await services<DBManager>().getWallets();
  for (var walletData in walletsData) {
    var seed = await Utils().decryptSeed(walletData['seed_encrypted']);
    var original_name = walletData['original_name'];
    int active_index = walletData['active_index'];
    services<WalletsService>().importWallet(
      seed,
      walletData['name'],
      original_name,
      active_index,
    );
    if (original_name == activeWalletName) {
      int walletslen = services<WalletsService>().walletsList.length - 1;
      services<WalletsService>().activeWallet = walletslen;
    }

    if (kDebugMode) {
      // print("done loading wallet ${walletData['name']}");
    }

    //load the wallet data from its table $original_name

    var walletIndices =
        await services<DBManager>().getWalletData(original_name);
    for (var row in walletIndices) {
      // print(row);

      services<WalletService>(instanceName: original_name).importAccount(
        row['index_id'],
        row['index_name'],
        row['address'],
        row['balance'],
        int.parse(row['last_update']),
        row['representative'],
      );
    }
    if (original_name == activeWalletName) {
      int walletID = services<WalletsService>().activeWallet;
      String walletName = services<WalletsService>().walletsList[walletID];
      WalletService wallet = services<WalletService>(instanceName: walletName);
      int accsLen = wallet.accountsList.length;
      if (activeAccountIndex < accsLen) {
        wallet.setActiveIndex(activeAccountIndex);
      }
    }

    index++;
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // register services
  initServices();
  await setupUserData();

  //remove splash ready to start
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      const MyApp(),
    );
    // runApp(const MyApp());

    // setup window size for PC/Desktop platforms
    initWindowsSize();
  });
}

void initWindowsSize() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // if (Platform.isWindows) {
    // await DesktopWindow.setMinWindowSize(const Size(400, 400));
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(600, 850);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Banano Keeper";
      win.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var currentLocale = services<LocalizationModel>().getLocale();
    var supportedLocales = services<LocalizationModel>().supportedLocales;

    // print("MAIN.DART: is new user? $isNewUser");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   // Define the default brightness and colors.
      //   brightness: Brightness.dark,
      //   primaryColor: Colors.lightBlue[800],
      //
      //   // Define the default font family.
      //   fontFamily: 'Georgia',
      //
      //   // Define the default `TextTheme`. Use this to specify the default
      //   // text styling for headlines, titles, bodies of text, and more.
      //   textTheme: const TextTheme(
      //     displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
      //     titleLarge: TextStyle(fontSize: 36, fontStyle: FontStyle.italic),
      //     bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
      //   ),
      // ),
      // -----------------------
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: currentLocale,
      // ---------------------------
      home: (isNewUser ? InitialPageOne() : MainAppLogic()),
      // initialRoute: '/initialpageone', //(isNewUser ? '/initialpageone' : '/'),

      // routes: {
      //   // '/': (context) {
      //   //   // print(Localizations.localeOf(context));
      //   //   print("test?");
      //   //   return MainAppLogic();
      //   // },
      //   '/wallet_management': (context) {
      //     return Text("hell");
      //   },
      //   '/address_management': (context) {
      //     return Text("hell");
      //   },
      //   '/initialpageone': (context) {
      //     print("INIT PAGE ONE");
      //     return InitialPageOne();
      //   }
      // },
    );
  }
}
