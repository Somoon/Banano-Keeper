// ignore_for_file: prefer_const_constructors

import 'dart:ui';

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

    int walletIndex = services<WalletsService>().activeWallet;
    int accLen =
        services<WalletsService>().wallets[walletIndex].accountsList.length;
    for (int index = 0; index < accLen; index++) {
      String accOrgName =
          services<WalletsService>().wallets[walletIndex].accountsList[index];

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
                SizedBox(
                  height: 20,
                ),

                // top buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    addButton(),
                    addButtonWithTextInput(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
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
    var accountsList =
        watchOnly((WalletsService x) => x.wallets[x.activeWallet].accountsList);

    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    double width = MediaQuery.of(context).size.width;
    var currentWallet =
        watchOnly((WalletsService x) => x.wallets[x.activeWallet]);
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
                        currentWallet.setActiveIndex(index);
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
        int walletIndex = services<WalletsService>().activeWallet;

        String accOrgName =
            services<WalletsService>().wallets[walletIndex].accountsList[index];

        var account = services<Account>(instanceName: accOrgName);

        int activeWallet = watchOnly((WalletsService x) => x.activeWallet);
        String tempName = services<WalletsService>()
            .wallets[activeWallet]
            .getAccountName(index);
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
                      appLocalizations!.renameAccountName ?? "",
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
                                appLocalizations.rename ?? "",
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
                        Navigator.pop(context);
                      },
                      child: Text(
                        appLocalizations.close ?? "",
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
    int walletIndex = services<WalletsService>().activeWallet;

    String accOrgName =
        services<WalletsService>().wallets[walletIndex].accountsList[index];

    var account = services<Account>(instanceName: accOrgName);
    var currentWallet =
        watchOnly((WalletsService x) => x.wallets[x.activeWallet]);
    bool isActiveAccount =
        (currentWallet.currentAccount.value == account.getAddress());
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
                      color: currentTheme.textDisabled,
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
                    // FutureBuilder(
                    //   future: //(accounts[index].overviewResp.isEmpty &&
                    //       //accounts[index].getBalance() == 0
                    //       // ?
                    //       account.getOverview(),
                    //   //  : Future<null>),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState ==
                    //         ConnectionState.waiting) {
                    //       if (account.overviewResp.isEmpty &&
                    //           account.getBalance() == 0) {
                    //         return blurBalance(
                    //             true, displayBalance(account, currentTheme));
                    //       }
                    //     } else if (snapshot.connectionState ==
                    //         ConnectionState.done) {
                    //       account.handleOverviewResponse();
                    //       // If we got an error
                    //       if (snapshot.hasError) {
                    //         return blurBalance(
                    //             true, displayBalance(account, currentTheme));
                    //       }
                    //     }
                    //     if (account.overviewResp.isEmpty) {
                    //       return blurBalance(
                    //           true, displayBalance(account, currentTheme));
                    //     } else {
                    //       return blurBalance(
                    //           false, displayBalance(account, currentTheme));
                    //     }
                    //   },
                    // ),
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
          title: Text(appLocalizations!.removeAddress),
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
                Navigator.of(context).pop();
              },
              child: Text(
                // 'Yes',
                appLocalizations?.yes ?? "",
                style: currentTheme.textStyle,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                appLocalizations?.no ?? "",
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
      int activeWallet = watchOnly((WalletsService x) => x.activeWallet);

      services<WalletsService>()
          .wallets[activeWallet]
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
                  borderRadius: BorderRadius.only(
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
                  addAccount();
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
            //////////////////////////////////////////////////////////////////////
            ///
            ///

            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                //Outline border type for TextFeild
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                //Outline border type for TextFeild
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                borderSide: BorderSide(
                  color: currentTheme.buttonOutline,
                  width: 1,
                ),
              ),
              //////////////////////////////////////////////////////////////////////
              ///
              ///
              ///
              ///
              ///
              labelText: "#",
              labelStyle: TextStyle(
                color: currentTheme.offColor,
              ),
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

  void addAccount([index = "0"]) {
    // if (indexController.value != null || indexController.value != "") {}

    var currentWallet =
        get<WalletsService>().wallets[get<WalletsService>().activeWallet];

    var index = indexController.text;

    if (index == "" || index == "0") {
      currentWallet.createAccount();
    } else {
      // services<WalletsService>()
      //     .wallets[activeWallet]
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
