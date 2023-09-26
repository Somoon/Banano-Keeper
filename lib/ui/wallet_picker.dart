// import 'dart:async';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:flutter/material.dart';

// import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../themes.dart';

// late String focusedWallet;

class walletPicker extends StatefulWidget with GetItStatefulWidgetMixin {
  walletPicker({super.key});

  @override
  _walletPicker createState() => _walletPicker();
}

class _walletPicker extends State<walletPicker>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    return buildMainSettings(context);
  }

  Widget buildMainSettings(BuildContext context) {
    int activeWallet = watchOnly((WalletsService x) => x.activeWallet);
    List<String> walletList = watchOnly((WalletsService x) => x.walletsList);
    // var wallets = watchOnly((WalletsService x) => x.wallets);
    String orgWalletName = walletList[activeWallet];
    String activeWalletName = watchOnly(
        (WalletService x) => x.getWalletName(), instanceName: orgWalletName);
    Color textColor = watchOnly((ThemeModel x) => x.curTheme.text);
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    // double width = MediaQuery.of(context).size.width;
// Drawer sideDrawer() {
    return PopupMenuButton(
      tooltip: "Select wallet",
      constraints: const BoxConstraints(maxHeight: 250),

      // position: PopupMenuPosition.under,
      // offset: const Offset(0, -380),
      // position: ,
      offset: const Offset(-25.3, 20),
      color: currentTheme.primary,
      initialValue: services<WalletService>(instanceName: orgWalletName).getWalletName(),
      // Callback that sets the selected popup menu item.
      onSelected: (item) {
        services<WalletsService>().setActiveWallet(item);
        setState(() {});
      },
      itemBuilder: (BuildContext context) => createDropDownMenuItems(),
      child: SizedBox(
        width: double.infinity,
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
                crossAxisAlignment:
                    CrossAxisAlignment.center, //Center Row contents vertically,
                children: <Widget>[
              Text(
                activeWalletName,
                style: TextStyle(color: textColor),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: textColor,
              ),
            ])),
      ),
    );
  }

  List<PopupMenuEntry> createDropDownMenuItems() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var walletsList = services<WalletsService>().walletsList;
    var ddmi = <PopupMenuEntry>[];
    for (int i = 0; i < walletsList.length; i++) {
      // var wallets = watchOnly((WalletsService x) => x.wallets);
      String orgWalletName = walletsList[i];
      ddmi.add(PopupMenuItem(
        value: i,
        child: Text(

          services<WalletService>(instanceName: orgWalletName).getWalletName(),
          style: TextStyle(
            color: currentTheme.text,
          ),
        ),
      ));
    }
    return ddmi;
  }
}
