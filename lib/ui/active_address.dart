import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../utils/utils.dart';

class ActiveAccount extends StatefulWidget with GetItStatefulWidgetMixin {
  ActiveAccount({super.key});

  @override
  ActiveAccountState createState() => ActiveAccountState();
}

class ActiveAccountState extends State<ActiveAccount>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    var wallet = watchOnly((WalletsService x) => x.wallets[x.activeWallet]);
    // var account = wallet.accounts[wallet.getActiveIndex()];
    var account = watchOnly((WalletsService x) => x.wallets[x.activeWallet]
        .accounts[x.wallets[x.activeWallet].getActiveIndex()]);

    String currentAccount =
        watchX((WalletsService x) => x.wallets[x.activeWallet].currentAccount);
    // num activeAccountBalance =
    //     watchX((WalletsService x) => x.wallets[x.activeWallet].accounts[x.wallets[x.activeWallet].getActiveIndex()].getBalance());

    double width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: account.getOverview(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (account.overviewResp.isEmpty && account.getBalance() == 0) {
            return displayActiveCard(
                currentTheme, width, currentAccount, account, wallet, true);
          }
        } else if (snapshot.connectionState == ConnectionState.done) {
          account.handleOverviewResponse();
          // If we got an error
          if (snapshot.hasError) {
            return displayActiveCard(
                currentTheme, width, currentAccount, account, wallet, true);
          }
        }
        if (account.history.isEmpty) {
          return displayActiveCard(
              currentTheme, width, currentAccount, account, wallet, true);
        } else {
          return displayActiveCard(
              currentTheme, width, currentAccount, account, wallet, false);
        }
      },
    );
  }

  Center displayActiveCard(
      BaseTheme currentTheme,
      double width,
      String currentAccount,
      Account account,
      WalletService wallet,
      bool blurred) {
    return Center(
      child: Card(
        color: currentTheme.secondary,
        child: Container(
          decoration: BoxDecoration(
            color: currentTheme.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
          height: 75,
          child: Column(
            children: [
              Ink(
                height: 70,
                width: width / 1.1,
                color: currentTheme.secondary,
                child: Row(
                  children: [
                    Utils().getMonkey(currentAccount),
                    // SizedBox(width: w2),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            account.getName(),
                            maxLines: 1,
                            style: TextStyle(
                              color: currentTheme.textDisabled,
                              fontSize: currentTheme.fontSize - 3,
                            ),
                          ),
                          // const SizedBox(height: 10),
                          Container(
                            child: PopupMenuButton(
                              constraints: const BoxConstraints(maxHeight: 300),
                              tooltip: "select address",
                              // position: PopupMenuPosition.under,
                              // offset: const Offset(0, -380),
                              // position: ,
                              offset: const Offset(0, 20),
                              color: currentTheme.primary,
                              initialValue: currentAccount,
                              // Callback that sets the selected popup menu item.
                              onSelected: (item) {
                                // services<WalletsService>()
                                //     .setActiveWallet(item);
                                wallet.setActiveIndex(item);
                                setState(() {});
                              },
                              itemBuilder: (BuildContext context) =>
                                  createDropDownMenuItems(),
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        //Center Row contents horizontally,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        //Center Row contents vertically,
                                        children: <Widget>[
                                      AutoSizeText(
                                        Utils().shortenAccount(currentAccount),
                                        maxLines: 1,
                                        style: currentTheme.textStyle
                                            .copyWith(fontSize: 14),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: currentTheme.text,
                                      ),
                                    ])),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: blurBalance(blurred,
                                  displayBalance(account, currentTheme)),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget displayBalance(Account account, BaseTheme currentTheme) {
    num activeAccountBalance = watchOnly((WalletsService x) => x
        .wallets[x.activeWallet]
        .accounts[x.wallets[x.activeWallet].getActiveIndex()]
        .getBalance());
    if (kDebugMode) {
      print("ACTIVE ADDRESS: $activeAccountBalance");
    }
    return Utils().formatBalance(activeAccountBalance, currentTheme);
  }

  List<PopupMenuEntry> createDropDownMenuItems() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var wallet = watchOnly((WalletsService x) => x.wallets[x.activeWallet]);

    var ddmi = <PopupMenuEntry>[];
    for (int i = 0; i < wallet.accounts.length; i++) {
      ddmi.add(PopupMenuItem(
        value: i,
        child: Text(
          wallet.accounts[i].getAddress().substring(0, 16),
          style: currentTheme.textStyle.copyWith(fontSize: 14),
        ),
      ));
    }
    return ddmi;
  }
}
