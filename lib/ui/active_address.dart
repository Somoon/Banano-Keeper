import 'dart:ui';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/utils/utils.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ActiveAccount extends StatefulWidget with GetItStatefulWidgetMixin {
  ActiveAccount({super.key});

  @override
  ActiveAccountState createState() => ActiveAccountState();
}

class ActiveAccountState extends State<ActiveAccount>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    // int accountIndex = wallet.activeIndex;
    int accountIndex =
        watchOnly((WalletService x) => x.activeIndex, instanceName: walletName);

    String accOrgName = watchOnly(
        (WalletService x) => x.accountsList[accountIndex],
        instanceName: walletName);
    // wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);
    var accountOpen =
        watchOnly((Account x) => x.opened, instanceName: accOrgName);

    bool completed =
        watchOnly((Account x) => x.completed, instanceName: accOrgName);

    if (!account.doneovR && !completed) {
      services<QueueService>().add(account.getOverview(true));
    }
    String currentAccount =
        watchX((WalletService x) => x.currentAccount, instanceName: walletName);
    double width = MediaQuery.of(context).size.width;
    return displayActiveCard(
        currentTheme, width, currentAccount, account, wallet, !accountOpen);
  }

  Center displayActiveCard(
      BaseTheme currentTheme,
      double width,
      String currentAccount,
      Account account,
      WalletService wallet,
      bool blurred) {
    String userCurrency = watchOnly((UserData x) => x.currency);
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
                          PopupMenuButton(
                            constraints: const BoxConstraints(maxHeight: 300),
                            tooltip:
                                AppLocalizations.of(context)!.selectAddressHint,
                            // position: PopupMenuPosition.under,
                            // offset: const Offset(0, -380),
                            // position: ,
                            offset: const Offset(0, 20),
                            color: currentTheme.primary,
                            initialValue: currentAccount,
                            // Callback that sets the selected popup menu item.
                            onSelected: (item) {
                              int walletID =
                                  services<WalletsService>().activeWallet;
                              String walletName = services<WalletsService>()
                                  .walletsList[walletID];
                              if (item !=
                                  services<WalletService>(
                                          instanceName: walletName)
                                      .getActiveIndex()) {
                                services<WalletService>(
                                        instanceName: walletName)
                                    .setActiveIndex(item);
                              }
                              setState(() {});
                            },
                            itemBuilder: (BuildContext context) =>
                                createDropDownMenuItems(wallet, currentTheme),
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
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: blurBalance(
                                blurred,
                                Utils().formatBalance(account.getBalance(),
                                    currentTheme, userCurrency),
                              ),
                              // displayBalance(account, currentTheme)),
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

  List<PopupMenuEntry> createDropDownMenuItems(
      WalletService wallet, BaseTheme currentTheme) {
    // var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    // var wallet = watchOnly((WalletsService x) => x.wallets[x.activeWallet]);

    var ddmi = <PopupMenuEntry>[];
    for (int i = 0; i < wallet.accountsList.length; i++) {
      ddmi.add(PopupMenuItem(
        value: i,
        child: Text(
          services<Account>(instanceName: wallet.accountsList[i])
              .getAddress()
              .substring(0, 16),
          // wallet.accounts[i].getAddress().substring(0, 16),
          style: currentTheme.textStyle.copyWith(fontSize: 14.0),
        ),
      ));
    }
    return ddmi;
  }
}
