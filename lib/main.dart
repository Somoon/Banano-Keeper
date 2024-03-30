import 'package:auto_route/auto_route.dart';
import 'package:bananokeeper/api/currency_conversion.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow/node_selector.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
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
import 'package:uni_links_desktop/uni_links_desktop.dart';
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

populateUserData(userValues) async {
  services<LocalizationModel>().setLocale(userValues[1]);
  services<ThemeModel>().setTheme(userValues[2]);
  services<UserData>().setPin(userValues[6]);
  services<PoWSource>().setAPI(userValues[7]);
  services<UserData>().setRepresentativesList(userValues[8]);
  services<UserData>().setRepUpdateTime(userValues[9]);
  services<UserData>().setThreadCount(userValues[10]);
  services<UserData>().setAuthOnBoot(userValues[11]);
  services<NodeSelector>().setNode(userValues[12]);
  services<UserData>().setAutoReceive(userValues[13]);
  services<UserData>().setMinToReceive(userValues[14]);
  services<UserData>().setNumOfAllowedRx(userValues[15]);
  services<UserData>().setAuthForSmallTx(userValues[16]);
}

Future<void> setupUserData() async {
  await _initSharedPref();
  await services<DBManager>().init();

  var userValues = await services<SharedPrefsModel>().getStoredValues();

  // services<WalletsService>().createMockWallet();

  var cData = await CurrencyAPI().getData();
  services.registerSingleton<CurrencyConversion>(CurrencyConversion());
  services<CurrencyConversion>().updateData(cData);

  //new app launch - no data

  if (!userValues[0]) {
    isNewUser = true;
    String masterKey = Utils().getRandString(64);
    services<SharedPrefsModel>().bioStorageSaveKey(masterKey);
    // send user to firsttime page v
  } else {
    if (kDebugMode) {
      // print("main.dart: not new user: $userValues");
    }
    await services.allReady();
    //set theme and language
    await populateUserData(userValues);

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
  var walletsData = await services<DBManager>().getWallets();
  final masterKey = await services<SharedPrefsModel>().bioStorageFetchKey();
  for (var walletData in walletsData) {
    var seed =
        await Utils().decryptSeed(walletData['seed_encrypted'], masterKey);
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

    // if (kDebugMode) {
    //   print("done loading wallet ${walletData['name']}");
    // }

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
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // register services
  initServices();
  services.registerSingleton<AppRouter>(AppRouter());
  await setupUserData();
  if (!kIsWeb && Platform.isWindows) {
    registerProtocol('ban');
    registerProtocol('banano');
    registerProtocol('banrep');
    registerProtocol('bansign');
    registerProtocol('banverify');
  }

  /* if (Platform.isWindows) {
    runApp(const MyApp());
    // setup window size for PC/Desktop platforms
    initWindowsSize();
    //remove splash ready to start
    FlutterNativeSplash.remove();
  } else {
    */
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      const MyApp(),
    );
    // runApp(const MyApp());

    // setup window size for PC/Desktop platforms
    initWindowsSize();
    //remove splash ready to start

    FlutterNativeSplash.remove();
  });
  // }
}

void initWindowsSize() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // if (Platform.isWindows) {
    // await DesktopWindow.setMinWindowSize(const Size(400, 400));
    // doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(600, 850);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Banano Keeper";
    win.show();
    // });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var currentLocale = services<LocalizationModel>().getLocale();
    var supportedLocales = services<LocalizationModel>().supportedLocales;

    // print("MAIN.DART: is new user? $isNewUser");
    final appRouter = services<AppRouter>();
    return MaterialApp.router(
      routerConfig: appRouter.config(
        deepLinkBuilder: (deepLink) {
          if (deepLink.path.startsWith('/products')) {
            // continute with the platfrom link
            return deepLink;
          } else {
            // return DeepLink.defaultPath;
            // or DeepLink.path('/')
            print('we here');
            return DeepLink([HomeRoute()]);
          }
        },
      ),
      // routeInformationParser: appRouter.defaultRouteParser(),
      // routerDelegate: appRouter.delegate(),

      // return MaterialApp(
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: currentLocale,
      // ---------------------------
      //////////// home: (isNewUser ? InitialPageOne() : MainAppLogic()),
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
