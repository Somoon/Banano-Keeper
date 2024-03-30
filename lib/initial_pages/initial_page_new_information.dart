// ignore_for_file: prefer_const_constructors
import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/themes.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nanodart/nanodart.dart';

@RoutePage(name: "InitialPageInformationRoute")
class InitialPageInformation extends StatefulWidget
    with GetItStatefulWidgetMixin {
  InitialPageInformation({super.key});

  @override
  InitialPageInformationState createState() => InitialPageInformationState();
}

class InitialPageInformationState extends State<InitialPageInformation>
    with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isCheckedNewWallet = false;
  bool createStateNewWallet = true;
  String seed = Utils().generateSeed();

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalizations = AppLocalizations.of(context);
    List<String> mnemonicPhrase = NanoMnemomics.seedToMnemonic(seed);

    List<Widget> oddWords = [];
    List<Widget> evenWords = [];
    for (var i = 0; i < mnemonicPhrase.length; i++) {
      if ((i + 1) % 2 == 1) {
        oddWords.add(AutoSizeText(
          "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
          style: TextStyle(
            color: currentTheme.text,
            fontFamily: 'monospace',
            fontSize: 15,
          ),
          maxFontSize: 15,
          minFontSize: 9,
        ));
      } else {
        evenWords.add(AutoSizeText(
          "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
          style: TextStyle(
            color: currentTheme.text,
            fontFamily: 'monospace',
            fontSize: 15,
          ),
          maxFontSize: 15,
          minFontSize: 9,
        ));
      }
    }
    Widget mnemonicWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: oddWords,
        ),
        // SizedBox(
        //   width: 30,
        // ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: evenWords,
        )
      ],
    );
    // for(men)
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: currentTheme.primaryAppBar,
            automaticallyImplyLeading: false,
            centerTitle: true,
            titleTextStyle: currentTheme.textStyle,
            title: Text(
              (createStateNewWallet
                  ? AppLocalizations.of(context)!
                      .newWalletTitle(AppLocalizations.of(context)!.seedInfo)
                  : AppLocalizations.of(context)!.newWalletTitle(
                      AppLocalizations.of(context)!.mnemonicInfo)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    createStateNewWallet = !createStateNewWallet;
                  });
                },
                // splashColor: currentTheme.text,
                // color: currentTheme.text,
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => currentTheme.text.withOpacity(0.3)),
                  foregroundColor:
                      MaterialStatePropertyAll<Color>(currentTheme.text),
                ),
                child: (createStateNewWallet
                    ? Icon(Icons.abc_sharp)
                    : Icon(Icons.key)),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: currentTheme.primary,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30.0,
                    right: 30,
                  ),
                  child: AutoSizeText(
                    "Make a backup of your ${(createStateNewWallet ? "seed" : "mnemonic phrase")} before progressing to the next page.",
                    maxLines: 4,
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: currentTheme.fontSize - 3,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(35.0),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: currentTheme.secondary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  //(createStateNewWallet
                  //        ? seed
                  //       : mnemonicPhrase.join(" ")
                  child: (createStateNewWallet
                      ? AutoSizeText(
                          seed,
                          maxLines: 6,
                          style: TextStyle(
                            color: currentTheme.text,
                            fontFamily: 'monospace',
                          ),
                        )
                      : mnemonicWidget),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        String tempString;
                        if (createStateNewWallet) {
                          tempString = seed;
                        } else {
                          tempString = mnemonicPhrase.join(" ");
                        }

                        Clipboard.setData(
                          ClipboardData(text: tempString),
                        );
                        setState(() {});
                      },
                      icon: Text(AppLocalizations.of(context)!.copy),
                      label: Icon(Icons.copy),
                      style: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith(
                            (states) => currentTheme.text.withOpacity(0.3)),
                        foregroundColor:
                            MaterialStatePropertyAll<Color>(currentTheme.text),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        side: MaterialStatePropertyAll<BorderSide>(
                          BorderSide(
                            color: currentTheme.text,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                GestureDetector(
                  onTap: () {
                    isCheckedNewWallet = !isCheckedNewWallet;
                    setState(() {});
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: Row(
                        children: [
                          Checkbox(
                            checkColor: currentTheme.text,
                            fillColor: MaterialStateProperty.all(Colors.white),
                            // MaterialStateProperty.resolveWith(getColor),
                            value: isCheckedNewWallet,
                            onChanged: (bool? value) {
                              setState(() {
                                isCheckedNewWallet = value!;
                              });
                            },
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          SizedBox(
                            width: width - 100,
                            child: AutoSizeText(
                              appLocalizations!.backedNewWalletMSG(
                                  (createStateNewWallet
                                      ? appLocalizations.seed.toLowerCase()
                                      : appLocalizations.mnemonicPhrase
                                          .toLowerCase())),
                              style: TextStyle(
                                color: currentTheme.textDisabled,
                                fontSize: currentTheme.fontSize - 3,
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            color: currentTheme.primary,
            width: double.infinity,
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
                  ),
                  onPressed: () {
                    services<WalletsService>().deleteWallet(0);
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    appLocalizations.back,
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: currentTheme.fontSize,
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
                  ),
                  onPressed: () async {
                    if (isCheckedNewWallet) {
                      bool? ok = await services<AppRouter>()
                          .push(SetupPinRoute(nextPage: 'initial'));

                      if (ok != null && ok) {
                        services<WalletsService>().setLatestWalletID(0);

                        await services<WalletsService>().createNewWallet(seed);
                        services<WalletsService>().setActiveWallet(0);

                        String walletName =
                            services<WalletsService>().walletsList[0];

                        services<WalletService>(instanceName: walletName)
                            .setActiveIndex(0);
                        services<SharedPrefsModel>().initliazeValues();
                        if (kDebugMode) {
                          print(
                              "LATEST ID ${services<WalletsService>().latestWalletID}");
                        }
                        setState(() {
                          //await
                          services<AppRouter>().replaceAll([HomeRoute()]);
                          //after successful return create wallet
                        });
                      }
                    }
                  },
                  child: Text(
                    appLocalizations.next,
                    style: TextStyle(
                      color: (isCheckedNewWallet
                          ? currentTheme.text
                          : currentTheme.textDisabled),
                      fontSize: currentTheme.fontSize,
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

  Color getColor(Set<MaterialState> states) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return currentTheme.textDisabled;
  }
}
