// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AccountManagementPage extends StatefulWidget
    with GetItStatefulWidgetMixin {
  AccountManagementPage({super.key});

  @override
  AccountManagementPageState createState() => AccountManagementPageState();
}

class AccountManagementPageState extends State<AccountManagementPage>
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    renameController.dispose();
    indexController.dispose();
    renameControllerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    // var statusBarHeight = MediaQuery.of(context).viewPadding.top;

    int walletIndex = watchOnly((WalletsService x) => x.activeWallet);

    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletIndex]);

    WalletService wallet = services<WalletService>(instanceName: walletName);

    int accLen = wallet.accountsList.length;

    // if (kDebugMode) {
    //   print(
    //       "management address page: walletIndex $walletIndex -- walletName = ${walletName}");
    //   print(
    //       "management address page: wallet: ${wallet.original_name} -- accounts: $accLen");
    //   print(wallet.accountsList);
    // }
    //

    for (int index = 0; index < accLen; index++) {
      String accOrgName = wallet.accountsList[index];

      // if (kDebugMode) {
      //   print("Checking account: $index $accOrgName");
      //
      // }
      var account = services<Account>(instanceName: accOrgName);

      if (!account.doneovR && !account.completed) {
        services<QueueService>().add(account.getOverview());
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            // constraints: BoxConstraints(
            //   minWidth: 100,
            //   maxWidth: 500,
            //   // maxHeight: 600,
            // ),
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
                    addButton(),
                    addButtonWithTextInput(),
                  ],
                ),
                const Gap(10),
                Divider(
                  thickness: 3,
                ),
                addressList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addressList() {
    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService currentWallet =
        services<WalletService>(instanceName: walletName);
    var accountsList = currentWallet.accountsList;

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
            itemCount: accountsList.length,
            itemBuilder: (BuildContext context, int index) {
              // if (width < 600) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        services<WalletService>(instanceName: walletName)
                            .setActiveIndex(index);
                      });
                    },
                    child: Slidable(
                      key: ValueKey(index),
                      endActionPane: ActionPane(
                        extentRatio: 0.3,
                        motion: ScrollMotion(),
                        children: [
                          renameSlidableAction(
                              context, currentTheme, accountsList, index),
                          deleteSlidableAction(
                              context, index, currentWallet, currentTheme),
                        ],
                      ),
                      child: slidableTileData(
                          currentTheme, width, accountsList, index),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                ],
              );
              // }
            },
          ),
        ),
      ),
    );
  }

  SlidableAction deleteSlidableAction(BuildContext context, int index,
      WalletService currentWallet, BaseTheme currentTheme) {
    return SlidableAction(
      onPressed: (_) {
        // currentWallet.removeIndex(index);
        // loadedAccounts.removeAt(index);
        dismissDialog(context, index, currentWallet, currentTheme);
        setState(() {});
      },
      backgroundColor: currentTheme.red,
      foregroundColor: Colors.white,
      icon: Icons.delete,
    );
  }

  SlidableAction renameSlidableAction(
      BuildContext context, BaseTheme currentTheme, accounts, int index) {
    return SlidableAction(
      // An action can be bigger than the others.
      onPressed: (_) {
        int walletID = watchOnly((WalletsService x) => x.activeWallet);
        String walletName =
            watchOnly((WalletsService x) => x.walletsList[walletID]);
        WalletService wallet =
            services<WalletService>(instanceName: walletName);

        String accOrgName = wallet.accountsList[index];
        Account account = services<Account>(instanceName: accOrgName);

        String tempName = wallet.getAccountName(index);
        renameController.text = tempName;
        var appLocalizations = AppLocalizations.of(context);

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22))),
            backgroundColor: currentTheme.secondary,
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      appLocalizations!.renameAccountName,
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: currentTheme.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25, bottom: 10),
                      child:
                          Utils().colorffix(account.getAddress(), currentTheme),
                      // AutoSizeText(
                      //   maxLines: 2,
                      //   loadedAccounts[index],
                      //   style: TextStyle(
                      //     color: currentTheme.text,
                      //     fontSize: currentTheme.fontSize,
                      //     height: 1.3,
                      //     fontFamily: 'monospace',
                      //   ),
                      // ),
                    ),
                    SizedBox(
                      height: 10,
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
                      height: 45,
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
                              color: renameControllerFocusNode.hasFocus
                                  ? currentTheme.textDisabled
                                  : currentTheme.textDisabled),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          // labelText: "Wallet name",
                          // prefixIcon: Icon(Icons.search),

                          suffixIcon: Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(80, 30),
                                backgroundColor: currentTheme.primaryBottomBar,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: Text(
                                appLocalizations.rename,
                                style: TextStyle(
                                  color: currentTheme.textDisabled,
                                ),
                              ),
                              onPressed: () {
                                tempName = renameController.text;

                                doRename(index);
                                ////////////////////////////
                                //no need to clear if we keeping dialog open after renaming
                                // renameController.clear();
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          return value!.length > 20
                              ? appLocalizations.accNameErrMsg
                              : null;
                        },
                        style: TextStyle(color: currentTheme.text),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        renameController.clear();
                        services<AppRouter>().pop();
                      },
                      child: Text(
                        appLocalizations.close,
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
      backgroundColor: currentTheme.lightgreen,
      foregroundColor: Colors.white,
      icon: Icons.drive_file_rename_outline,
      // label: 'rename',
    );
  }

  Column slidableTileData(
      BaseTheme currentTheme, double width, accounts, int index) {
    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService currentWallet =
        services<WalletService>(instanceName: walletName);

    String accOrgName = currentWallet.accountsList[index];
    Account account = services<Account>(instanceName: accOrgName);

    bool isActiveAccount =
        (currentWallet.getCurrentAccount() == account.getAddress());
    // if (!account.doneovR) {
    //   services<QueueService>().add(account.getOverview());
    // }
    var accountOpen =
        watchOnly((Account x) => x.opened, instanceName: accOrgName);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.secondary,
            border: Border(
              left: BorderSide(
                color:
                    (isActiveAccount ? currentTheme.text : Colors.transparent),
                width: 5,
              ),
            ),
          ),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: (width > 800 ? 100 : 15),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    account.getIndex().toString(),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    style: TextStyle(
                      color: currentTheme.textDisabled,
                      fontSize: currentTheme.fontSize,
                    ),
                  ),
                ),
              ),

              // Image.network(
              FadeInImage.assetNetwork(
                image: 'https://imgproxy.moonano.net/${account.getAddress()}',
                placeholder: 'images/greymonkey.png',
                width: 50,
                fit: BoxFit.fill,
              ),
              SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    account.getName(),
                    style: TextStyle(
                      color: currentTheme.textSecondary,
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AutoSizeText(
                      (width > 700
                          ? account.getAddress()
                          : Utils().shortenAccount(account.getAddress())),
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: currentTheme.fontSize - 5,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, //Center Row contents horizontally,
                  crossAxisAlignment: CrossAxisAlignment
                      .center, //Center Row contents vertically,
                  children: <Widget>[
                    // ------------------ change image Icons between BANANO/XNO
                    // Image.asset(
                    //   width: 12,
                    //   'images/banano.png',
                    // ),
                    // const SizedBox(
                    //   width: 4,
                    // ),

                    blurBalance(
                        !accountOpen, displayBalance(account, currentTheme)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget blurBalance(bool blur, Widget widget) {
    if (blur) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: widget,
      );
    } else {
      return widget;
    }
  }

  Row displayBalance(Account account, BaseTheme currentTheme) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //Center Row contents horizontally,
        crossAxisAlignment: CrossAxisAlignment.center,
        //Center Row contents vertically,
        children: <Widget>[
          // ------------------ change image Icons between BANANO/XNO
          Image.asset(
            width: 12,
            'images/banano.png',
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            Utils().displayNums(account.getBalance()),
            style: TextStyle(color: currentTheme.text),
          ),
        ]);
  }

  Future<bool?> dismissDialog(BuildContext context, int index,
      WalletService currentWallet, BaseTheme currentTheme) async {
    var appLocalizations = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: currentTheme.secondary,
          elevation: 2,
          title: Center(
            child: Text(appLocalizations!.removeAddress),
          ),
          titleTextStyle: currentTheme.textStyle,
          content: Text(appLocalizations.removeAddressWarning),
          contentTextStyle: TextStyle(
            color: currentTheme.textDisabled,
            fontSize: currentTheme.fontSize - 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (currentWallet.accountsList.length == 1) {
                  var snackBar = SnackBar(
                    content: Text(
                      appLocalizations.lastAddressSnackBar,
                      style: TextStyle(
                        color: currentTheme.textDisabled,
                      ),
                    ),
                  );
                  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
                } else {
                  setState(() {
                    currentWallet.removeIndex(index);
                  });
                }
                services<AppRouter>().pop();
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
      },
    );
  }

  createButton(String label, Widget stuff) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return TextButton(
      onPressed: () {
        stuff;
      },
      child: Text(
        label,
        style: TextStyle(color: currentTheme.text),
      ),
    );
  }

  void doRename(int index) {
    setState(() {
      String walletName = services<WalletsService>().walletsList[index];
      services<WalletService>(instanceName: walletName)
          .editAccountName(index, renameController.text);
    });
  }

  Widget addButton() {
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
        onPressed: () {
          addAccount("0");

          setState(() {});
        },
        child: Text(
          AppLocalizations.of(context)!.add,
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  Widget addButtonWithTextInput() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Row(
      children: [
        SizedBox(
          height: 48,
          width: 90,
          child: OutlinedButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => currentTheme.text.withOpacity(0.3)),
              // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: Utils().isDirectionRTL(context)
                      ? BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      : BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
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
                if (indexController.text != "" &&
                    indexController.text != null) {
                  addAccount(indexController.text);
                  indexController.clear();
                }
              });
            },
            child: Text(
              AppLocalizations.of(context)!.addNo,
              style: TextStyle(
                color: currentTheme.text,
                fontSize: currentTheme.fontSize,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: TextField(
            autofocus: false,
            controller: indexController,
            style: TextStyle(
              color: currentTheme.text,
            ),
            ////////////////////////////////////////////////////////////////////
            ///
            ///

            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 5),
              enabledBorder: OutlineInputBorder(
                borderRadius: !Utils().isDirectionRTL(context)
                    ? BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                //Outline border type for TextFeild
                borderRadius: !Utils().isDirectionRTL(context)
                    ? BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                //Outline border type for TextFeild
                borderRadius: !Utils().isDirectionRTL(context)
                    ? BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              //////////////////////////////////////////////////////////////////
              ///
              ///
              ///
              ///
              ///
              // labelText: "#",
              // labelStyle: TextStyle(
              //   color: currentTheme.offColor,
              // ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
          ),
        ),
      ],
    );
  }

  void addAccount(index) {
    int activeWallet = services<WalletsService>().activeWallet;

    String walletName = services<WalletsService>().walletsList[activeWallet];

    WalletService currentWallet =
        services<WalletService>(instanceName: walletName);

    if (index == "0") {
      currentWallet.createAccount();
    } else {
      var index = indexController.text;

      int intIndex = int.parse(index);
      if (!currentWallet.indexExist(intIndex)) {
        currentWallet.createAccount(intIndex);
      }
    }

    setState(() {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }
}
