// ignore_for_file: prefer_const_constructors

import 'dart:ui';
import 'package:bananokeeper/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/ui/management/import_wallet.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:gap/gap.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nanodart/nanodart.dart';
import 'package:local_auth/local_auth.dart';

class WalletManagementPage extends StatefulWidget
    with GetItStatefulWidgetMixin {
  WalletManagementPage({super.key});

  @override
  WalletManagementPageState createState() => WalletManagementPageState();
}

class WalletManagementPageState extends State<WalletManagementPage>
    with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  final renameController = TextEditingController();
  final indexController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode renameControllerFocusNode = FocusNode();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    renameController.dispose();
    indexController.dispose();
    renameControllerFocusNode.dispose();
    super.dispose();
  }

  //create new wallet states
  bool isCheckedNewWallet = false;
  bool createStateNewWallet = true;

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    // var statusBarHeight = MediaQuery.of(context).viewPadding.top;
    List<String> walletList = watchOnly((WalletsService x) => x.walletsList);
    var activeWallet = get<WalletsService>().activeWallet;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: currentTheme.primary,
          ),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Gap(20),

              // top buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  addButton(AppLocalizations.of(context)!.create),
                  addImportButton(AppLocalizations.of(context)!.import),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              // Divider(
              //   thickness: 3,
              // ),
              addressList(activeWallet, walletList),
            ],
          ),
        ),
      ),
    );
  }

  Widget addressList(activeWallet, walletsList) {
    // List<WalletService> wallets = get<WalletsService>().wallets;
//services<WalletsService>().walletsList;

    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: ListView.builder(
            controller: scrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: walletsList.length,
            itemBuilder: (BuildContext context, int index) {
              bool isActiveWallet = (activeWallet == index);

              return walletListCard(currentTheme, width, index, isActiveWallet,
                  walletsList, context);
            },
          ),
        ),
      ),
    );
  }

  Card walletListCard(BaseTheme currentTheme, double width, int index,
      bool isActiveWallet, List<String> walletsList, BuildContext context) {
    double width2 = MediaQuery.of(context).size.width;

    String walletName = watchOnly((WalletsService x) => x.walletsList[index]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    return Card(
      color: currentTheme.primary,
      child: Ink(
        height: 70,
        width: width2,
        child: Row(
          children: [
            //Wallet name portion
            GestureDetector(
              onTap: () {
                setState(() {
                  services<WalletsService>().setActiveWallet(index);
                  // currentWallet.setActiveIndex(index);
                  // currentWallet.setActiveAccount(loadedAccounts[index]);
                });
              },
              child: Container(
                width: width - 205,
                decoration: BoxDecoration(
                  color: currentTheme.secondary,
                  border: Border(
                    left: BorderSide(
                      color: (isActiveWallet
                          ? currentTheme.text
                          : Colors.transparent),
                      width: 5,
                    ),
                  ),
                ),
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: AutoSizeText(
                        wallet.getWalletName(),
                        style: TextStyle(
                          color: currentTheme.text,
                          fontSize: currentTheme.fontSize,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Rename button
            SizedBox(
              height: 80,
              width: 65,
              child: TextButton(
                onPressed: () {
                  String walletName =
                      watchOnly((WalletsService x) => x.walletsList[index]);

                  String tempName =
                      services<WalletService>(instanceName: walletName)
                          .getWalletName();

                  renameController.text = tempName;
                  var appLocalizations = AppLocalizations.of(context);

                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22))),
                      backgroundColor: currentTheme.secondary,
                      child: SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                appLocalizations!.renameWalletName,
                                style: TextStyle(
                                  color: currentTheme.text,
                                  fontSize: currentTheme.fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: currentTheme.primary,
                                  border: Border.all(
                                    color: currentTheme.primaryBottomBar,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 50,
                                width: double.infinity,
                                child: TextFormField(
                                  focusNode: renameControllerFocusNode,
                                  controller: renameController,
                                  autofocus: false,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.only(
                                      left: 8,
                                      right: 1,
                                    ),
                                    labelStyle: TextStyle(
                                        color:
                                            renameControllerFocusNode.hasFocus
                                                ? currentTheme.textDisabled
                                                : currentTheme.textDisabled),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    // hintText: tempName, //activeWalletName,
                                    // hintStyle:
                                    //     TextStyle(color: currentTheme.textDisabled),

                                    suffixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(80, 30),
                                          backgroundColor:
                                              currentTheme.primaryBottomBar,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        child: Text(
                                          appLocalizations.rename,
                                          style: TextStyle(
                                            color: currentTheme.textDisabled,
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            tempName = renameController.text;
                                            doRename(index);
                                            ////////////////////////////
                                            // renameController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  autovalidateMode: AutovalidateMode.always,
                                  validator: (value) {
                                    return value!.length > 20
                                        ? AppLocalizations.of(context)!
                                            .walletNameErrMsg
                                        : null;
                                  },
                                  style: TextStyle(color: currentTheme.text),
                                ),
                              ),
                              const SizedBox(height: 35),
                              TextButton(
                                onPressed: () {
                                  renameController.clear();
                                  services<AppRouter>().pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                  style: TextStyle(color: currentTheme.text),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  setState(() {});
                },
                style: currentTheme.btnStyleRect.copyWith(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.green)),
                child: Icon(
                  Icons.drive_file_rename_outline,
                  color: currentTheme.buttonIconColor,
                ),
              ),
            ),
            //Backup button
            SizedBox(
              height: 80,
              width: 65,
              child: TextButton(
                onPressed: () {
                  backupWallet(context, index, walletsList, currentTheme);
                },
                style: currentTheme.btnStyleRect.copyWith(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blue)),
                child: Icon(
                  Icons.save,
                  color: currentTheme.buttonIconColor,
                ),
              ),
            ),
            //Delete Wallet
            SizedBox(
              height: 80,
              width: 65,
              child: TextButton(
                onPressed: () async {
                  await dismissDialog(
                      context, index, walletsList, currentTheme);
                  setState(() {});
                },
                style: currentTheme.btnStyleRect.copyWith(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.red)),
                child: Icon(
                  Icons.delete,
                  color: currentTheme.buttonIconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> dismissDialog(BuildContext context, int index,
      List<String> walletsList, BaseTheme currentTheme) async {
    var appLocalizations = AppLocalizations.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            backgroundColor: currentTheme.secondary,
            elevation: 2,
            title: Center(
              child: Text(appLocalizations!.removeWallet),
            ),
            titleTextStyle: currentTheme.textStyle,
            content: Text(appLocalizations.removeWalletWarning),
            contentTextStyle: TextStyle(
              color: currentTheme.textDisabled,
              fontSize: currentTheme.fontSize - 3,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (walletsList.length == 1) {
                    var snackBar = SnackBar(
                      content: Text(
                        appLocalizations.lastWalletSnackBar,
                        style: TextStyle(
                          color: currentTheme.textDisabled,
                        ),
                      ),
                    );
                    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
                  } else {
                    bool canauth = await BiometricUtil().canAuth();
                    bool? verified = false;

                    if (!canauth) {
                      verified =
                          await services<AppRouter>().push(VerifyPINRoute()) ??
                              false;
                    } else {
                      verified = await BiometricUtil()
                          .authenticate(appLocalizations.authMsgWalletDel);
                    }

                    if (verified != null && verified) {
                      setState(() {
                        services<WalletsService>().deleteWallet(index);
                      });
                    }
                  }
                  setState(() {
                    services<AppRouter>().pop<bool>(true);
                  });
                },
                child: Text(
                  // 'Yes',
                  appLocalizations.yes,
                  style: currentTheme.textStyle,
                ),
              ),
              TextButton(
                onPressed: () {
                  services<AppRouter>().pop();
                },
                child: Text(
                  appLocalizations.no,
                  style: currentTheme.textStyle,
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void backupWallet(
      context, index, List<String> walletsList, currentTheme) async {
    bool canauth = await BiometricUtil().canAuth();
    bool? verified = false;
    var appLocalizations = AppLocalizations.of(context);
    if (!canauth) {
      verified = await services<AppRouter>().push<bool>(VerifyPINRoute());
    } else {
      verified = await BiometricUtil()
          .authenticate(appLocalizations!.authMsgWalletBackup);
    }

    if (verified != null && verified) {
      bool createStateNewWallet = true;
      String walletName = services<WalletsService>().walletsList[index];
      String seed = services<WalletService>(instanceName: walletName).seed;
      List<String> mnemonicPhrase = NanoMnemomics.seedToMnemonic(seed);

      List<Widget> oddWords = [];
      List<Widget> evenWords = [];
      //for odds
      for (var i = 0; i < mnemonicPhrase.length; i++) {
        if ((i + 1) % 2 == 1) {
          oddWords.add(AutoSizeText(
            "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
            style: TextStyle(
              color: currentTheme.text,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            maxFontSize: 14,
            minFontSize: 9,
          ));
        } else {
          evenWords.add(AutoSizeText(
            "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
            style: TextStyle(
              color: currentTheme.text,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            maxFontSize: 14,
            minFontSize: 9,
          ));
        }
      }
      Widget mnemonicWidget = Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: oddWords,
          ),
          SizedBox(
            width: 25,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: evenWords,
          )
        ],
      );
      var appLocalizations = AppLocalizations.of(context);

      showDialog<bool>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                key: ValueKey(isCheckedNewWallet),
                backgroundColor: currentTheme.secondary,
                elevation: 2,
                title: Center(
                  child: Text(
                    (createStateNewWallet
                        ? appLocalizations!
                            .backupWalletTitle(appLocalizations.seed)
                        : appLocalizations!.backupWalletTitle(
                            appLocalizations.mnemonicPhrase)),
                  ),
                ),
                titleTextStyle: currentTheme.textStyle,
                content: SizedBox(
                  width: 300,
                  height: 280,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: currentTheme.primary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
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
                                  (states) =>
                                      currentTheme.text.withOpacity(0.3)),
                              foregroundColor: MaterialStatePropertyAll<Color>(
                                  currentTheme.text),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
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
                            child: (createStateNewWallet
                                ? Icon(Icons.abc_sharp)
                                : Icon(Icons.key)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              String tempstr;
                              if (createStateNewWallet) {
                                tempstr = seed;
                              } else {
                                tempstr = mnemonicPhrase.join(" ");
                              }

                              Clipboard.setData(
                                ClipboardData(text: tempstr),
                              );
                            },
                            icon: Text(AppLocalizations.of(context)!.copy),
                            label: Icon(Icons.copy),
                            style: ButtonStyle(
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      currentTheme.text.withOpacity(0.3)),
                              foregroundColor: MaterialStatePropertyAll<Color>(
                                  currentTheme.text),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
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
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => currentTheme.text.withOpacity(0.3)),
                    ),
                    onPressed: () {
                      services<AppRouter>().pop();
                    },
                    child: Text(
                      // 'Yes',
                      appLocalizations.close,
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: currentTheme.fontSize,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  void doRename(int index) {
    setState(() {
      String walletName = services<WalletsService>().walletsList[index];
      services<WalletService>(instanceName: walletName)
          .editWalletName(renameController.text);
    });
  }

  Widget addButton(String label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalizations = AppLocalizations.of(context);

    return SizedBox(
      height: 48,
      width: 140.0,
      child: OutlinedButton(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => currentTheme.text.withOpacity(0.3)),
          // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
        onPressed: () async {
          String seed = Utils().generateSeed();
          List<String> mnemonicPhrase = NanoMnemomics.seedToMnemonic(seed);

          List<Widget> oddWords = [];
          List<Widget> evenWords = [];
          //for odds
          for (var i = 0; i < mnemonicPhrase.length; i++) {
            if ((i + 1) % 2 == 1) {
              oddWords.add(AutoSizeText(
                "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
                style: TextStyle(
                  color: currentTheme.text,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                maxFontSize: 14,
                minFontSize: 9,
              ));
            } else {
              evenWords.add(AutoSizeText(
                "#${(i + 1).toString().padRight(2, " ")} ${mnemonicPhrase[i]}",
                style: TextStyle(
                  color: currentTheme.text,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                maxFontSize: 14,
                minFontSize: 9,
              ));
            }
          }
          Widget mnemonicWidget = Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: oddWords,
              ),
              SizedBox(
                width: 25,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: evenWords,
              )
            ],
          );
          // for(men)
          isCheckedNewWallet = false;
          createStateNewWallet = true;
          bool? result = await createNewWalletDialog(currentTheme, seed,
              mnemonicWidget, appLocalizations, mnemonicPhrase.join(" "));
          if (kDebugMode) {
            print(result);
          }
          if (result ?? false) {
            await services<WalletsService>().createNewWallet(seed);
            setState(() {});
          }
        },
        child: Text(
          label,
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  Future<bool?> createNewWalletDialog(
      BaseTheme currentTheme,
      String seed,
      Widget mnemonicWidget,
      AppLocalizations? appLocalizations,
      String mnemonicPhrase) async {
    bool? result = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              key: ValueKey(isCheckedNewWallet),
              backgroundColor: currentTheme.secondary,
              elevation: 2,
              title: Center(
                child: Text(
                  (createStateNewWallet
                      ? appLocalizations!.seedInfo
                      : appLocalizations!.mnemonicInfo),
                ),
              ),
              titleTextStyle: currentTheme.textStyle,
              content: SizedBox(
                width: 300,
                height: 320,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: currentTheme.primary,
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
                            foregroundColor: MaterialStatePropertyAll<Color>(
                                currentTheme.text),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                          child: (createStateNewWallet
                              ? Icon(Icons.abc_sharp)
                              : Icon(Icons.key)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            String tempstr;
                            if (createStateNewWallet) {
                              tempstr = seed;
                            } else {
                              tempstr = mnemonicPhrase;
                            }

                            Clipboard.setData(
                              ClipboardData(text: tempstr),
                            );
                            setState(() {});
                          },
                          icon: Text(AppLocalizations.of(context)!.copy),
                          label: Icon(Icons.copy),
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => currentTheme.text.withOpacity(0.3)),
                            foregroundColor: MaterialStatePropertyAll<Color>(
                                currentTheme.text),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
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
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor: currentTheme.textDisabled,
                              fillColor:
                                  MaterialStateProperty.resolveWith(getColor),
                              value: isCheckedNewWallet,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCheckedNewWallet = value!;
                                });
                              },
                            ),
                            SizedBox(
                              width: 170,
                              child: AutoSizeText(
                                (createStateNewWallet
                                    ? appLocalizations.backedNewWalletMSG(
                                        appLocalizations.seed)
                                    : appLocalizations.backedNewWalletMSG(
                                        appLocalizations.mnemonicPhrase)),
                                style: TextStyle(
                                  color: currentTheme.textDisabled,
                                  fontSize: currentTheme.fontSize - 3,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
                  ),
                  onPressed: () {
                    services<AppRouter>().pop<bool>(false);
                  },
                  child: Text(
                    // 'Yes',
                    appLocalizations.cancel,
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
                  onPressed: () {
                    if (isCheckedNewWallet) {
                      services<AppRouter>().pop<bool>(true);
                    }
                  },
                  child: Text(
                    // 'Yes',
                    appLocalizations.create,
                    style: TextStyle(
                      color: (isCheckedNewWallet
                          ? currentTheme.text
                          : currentTheme.textDisabled),
                      fontSize: currentTheme.fontSize,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    return result;
  }

  Color getColor(Set<MaterialState> states) {
    var currentTheme = services<ThemeModel>().curTheme;
    return currentTheme.text;
  }

  Widget addImportButton(String label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SizedBox(
      height: 48,
      width: 140.0,
      child: OutlinedButton(
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => currentTheme.text.withOpacity(0.3)),
          // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
        onPressed: () async {
          //open seed/Mnemonic importing page
          await services<AppRouter>().push(ImportWalletRoute());

          setState(() {});
        },
        child: Text(
          label,
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }
}
