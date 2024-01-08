import 'dart:async';
// import 'dart:ffi';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:bananokeeper/api/account_api.dart';
// import 'package:bananokeeper/api/state_block.dart';
// import 'package:bananokeeper/db/dbManager.dart';
// import 'package:bananokeeper/providers/account.dart';
// import 'package:bananokeeper/providers/pow/local_pow.dart';
// import 'package:bananokeeper/providers/wallet_service.dart';
// import 'package:bananokeeper/providers/wallets_service.dart';
// import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:isolate';
// import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Completer<String> completer = Completer<String>();

class DBTest extends StatefulWidget with GetItStatefulWidgetMixin {
  DBTest({super.key});

  @override
  DBTestState createState() => DBTestState();
}

class DBTestState extends State<DBTest> with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  // String url = 'https://moonano.net/assets/data/pow/new.html';

  @override
  Widget build(BuildContext context) {
    // LocalPoW pow = LocalPoW();

    // int walletIndex = watchOnly((WalletsService x) => x.activeWallet);

    // String orgWalletName =
    //     watchOnly((WalletsService x) => x.walletsList[walletIndex]);
    // String activeWalletName = watchOnly((WalletService x) => x.getWalletName(),
    //     instanceName: orgWalletName);

    // WalletService wallet = services<WalletService>(instanceName: orgWalletName);
    // String currentAccount = watchX((WalletService x) => x.currentAccount,
    //     instanceName: orgWalletName);

    // int accountIndex = //wallet.activeIndex;
    //     watchOnly((WalletService x) => x.getActiveIndex(),
    //         instanceName: orgWalletName);

    // String accOrgName = wallet.accountsList[accountIndex];

    // String accountName =
    //     watchOnly((Account x) => x.getName(), instanceName: accOrgName);

    // var account = services<Account>(instanceName: accOrgName);

    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            color: Colors.purple.shade900,
            child: Column(
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("X CLOSE X")),
                TextButton(
                  onPressed: () async {
                    // await account.changeRepresentative(
                    //     "ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid");

                    setState(() {});
                  },
                  child: const Text("headless run"),
                ),
                TextButton(
                  onPressed: () async {
                    // await account.changeRepresentative(
                    //     "ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid");

                    setState(() {});
                  },
                  child: const Text("HEADLESS EVAL JS"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
