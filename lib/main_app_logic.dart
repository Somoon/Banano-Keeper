import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/providers/pow/local_work.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/bottom_bar/send_sheet/send_sheet.dart';
import 'package:bananokeeper/ui/message_signing/bottomSheetSign.dart';
import 'package:bananokeeper/ui/message_signing/message_sign_verification.dart';
import 'package:bananokeeper/ui/representative_pages/manual_rep_change.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/ui/wallet_picker.dart';
import 'package:bananokeeper/ui/sideDrawer.dart';
import 'package:bananokeeper/ui/home_body.dart';
import 'package:bananokeeper/ui/bottom_bar/bottom_bar.dart';

import 'package:auto_route/annotations.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uni_links/uni_links.dart';

bool _initialURILinkHandled = false;

@RoutePage(name: "HomeRoute")
class MainAppLogic extends StatefulWidget with GetItStatefulWidgetMixin {
  MainAppLogic({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MainAppLogic createState() => _MainAppLogic();
}

class _MainAppLogic extends State<MainAppLogic> with GetItStateMixin {
  // ------------------------------------
  String? _initialURI;
  String? _currentURI;
  Object? _err;

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    //start local webserver if local pow is enabled
    if (services<PoWSource>().getAPIName() == 'Local PoW') {
      if (!services<LocalWork>().localhostServer.isRunning()) {
        services<LocalWork>().init();
      }
    }
    _initURIHandler();
    _incomingLinkHandler();
  }

  Future<void> _initURIHandler() async {
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;

      try {
        final initialURI = await getInitialLink();
        // Use the initialURI and warn the user if it is not correct,
        // but keep in mind it could be `null`.
        if (initialURI != null) {
          // debugPrint("Initial URI received $initialURI");
          if (!mounted) {
            return;
          }
          Uri? uri = await getInitialUri();
          String? scheme = uri?.scheme;
          Map<String, String?> deepLinkData =
              Utils().dissectDeepLink(initialURI);
          handleDeepLink(scheme, deepLinkData);

          setState(() {
            _initialURI = initialURI;
          });
        } else {
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        // Platform messages may fail, so we use a try/catch PlatformException.
        // Handle exception by warning the user their action did not succeed
        debugPrint("Failed to receive initial uri");
      } on FormatException catch (err) {
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received');
        setState(() => _err = err);
      }
    }
  }

  /// Handle incoming links - the ones that the app will receive from the OS
  /// while already started.
  void _incomingLinkHandler() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _streamSubscription = linkStream.listen((String? newURI) async {
        if (!mounted) {
          return;
        }
        // print('-----------------------------------------------------');
        // print('Received URI: $newURI');
        Uri? uri = Uri.tryParse(newURI!);
        String? scheme = uri?.scheme;
        Map<String, String?> deepLinkData = Utils().dissectDeepLink(newURI);
        handleDeepLink(scheme, deepLinkData);
        setState(() {
          _currentURI = newURI;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        if (kDebugMode) {
          print('Error occurred: $err');
        }
        setState(() {
          _currentURI = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  handleDeepLink(String? scheme, Map<String, String?> deepLinkData) async {
    // debugPrint("scheme $scheme");
    //
    // debugPrint("Data $deepLinkData");
    int walletIndex = watchOnly((WalletsService x) => x.activeWallet);

    String orgWalletName =
        watchOnly((WalletsService x) => x.walletsList[walletIndex]);
    WalletService wallet = services<WalletService>(instanceName: orgWalletName);

    int accountIndex = watchOnly((WalletService x) => x.getActiveIndex(),
        instanceName: orgWalletName);
    String accOrgName = wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);
    switch (scheme) {
      case 'ban':
      case 'banano':
        final sendPage = SendBottomSheet();
        if (sendPage.isDisplayed) {
          sendPage.clear();
        }
        sendPage.show(context, services<ThemeModel>().curTheme,
            AppLocalizations.of(context), account);
        sendPage.addressController.text = deepLinkData['address'] ?? "";
        String amount =
            Utils().amountFromRaw(deepLinkData['amountRaw'] ?? "0").toString();
        sendPage.amountController.text = amount;
        break;
      case 'banrep':
        final repPage = ManualRepChange();
        if (repPage.isDisplayed) repPage.clear();
        repPage.show(context, services<ThemeModel>().curTheme, null,
            AppLocalizations.of(context), account);
        repPage.addressController.text = deepLinkData['representative'] ?? "";
        break;
      case 'bansign':
        final msgSignPage = MsgSignPage();
        if (msgSignPage.isDisplayed) {
          msgSignPage.clear();
        }
        msgSignPage.show(context, services<ThemeModel>().curTheme);
        msgSignPage.messageController.text = deepLinkData['message'] ?? "";
        break;
      case 'banverify':
        final msgSignVerifyPage = MsgSignVerifyPage();
        // if (!msgSignVerifyPage.isDisplayed) {
        msgSignVerifyPage.clear();
        // }
        msgSignVerifyPage.show(context, services<ThemeModel>().curTheme);
        // print(deepLinkData);
        msgSignVerifyPage.addressController.text =
            deepLinkData['address'] ?? "";
        msgSignVerifyPage.messageController.text =
            deepLinkData['message'] ?? "";
        msgSignVerifyPage.signController.text = deepLinkData['sign'] ?? "";
        break;
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    var currentLocale = watchOnly((LocalizationModel x) => x.getLocale());
    var supportedLocales =
        watchOnly((LocalizationModel x) => x.supportedLocales);
    // print("not new user - in homepage aka main_app_logic ");
    double width = MediaQuery.of(context).size.width;
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return MaterialApp(
      theme: ThemeData(
        canvasColor: currentTheme.primary,
        primarySwatch: currentTheme.materialColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          splashColor: currentTheme.text.withOpacity(0.3),
          backgroundColor: currentTheme.primary,
          foregroundColor: currentTheme.textSecondary,
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: currentTheme.textDisabled,
            fill: 0,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(currentTheme.text),
          fillColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
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

      home: smallScreenLogic(),
      //width < 600 ? smallScreenLogic() : bigScreenLogic()),
    );
  }

  Widget smallScreenLogic() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Scaffold(
      //--------------- Side Drawer -----------------------
      //make it width - (20% of width)
      drawerEdgeDragWidth: 300,
      drawer: SizedBox(
        width: 300,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: currentTheme.sideDrawerColor,
          ),
          child: SideDrawer(),
        ),
      ),
      backgroundColor: currentTheme.primary,

      //--------------- Wallet Settings -----------------------
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: currentTheme.primaryAppBar,
        centerTitle: true,
        title: Column(
          children: [
            walletPicker(),
            // Divider(color: Colors.black54),
          ],
        ),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            style: currentTheme.btnStyleNoBorder,
            splashRadius: 15,
            splashColor: currentTheme.textDisabled.withOpacity(0.3),
            highlightColor: currentTheme.text.withOpacity(0.4),
            icon: const Icon(Icons.menu), //, color: Colors.black38),
            // icon: new Icon(Icons.settings),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // ------ MAIN BODY ------------------
      body: HomeBody(),
      bottomNavigationBar: BottomBarApp(),
    );
  }

  Widget bigScreenLogic() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Directionality(
      //to move text direct in localization class
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          SizedBox(
            // color: Colors.blue,
            width: 250,
            child: SideDrawer(),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: currentTheme.primary,

              //--------------- Wallet Settings -----------------------
              appBar: AppBar(
                toolbarHeight: 50,
                backgroundColor: currentTheme.primaryAppBar,
                centerTitle: true,
                title: Column(
                  children: [
                    walletPicker(),
                    // Divider(color: Colors.black54),
                  ],
                ),
                elevation: 0,
              ),
              // ------ MAIN BODY ------------------
              body: HomeBody(),

              bottomNavigationBar: BottomBarApp(),
            ),
          )
        ],
      ),
      //
    );
  }
}
