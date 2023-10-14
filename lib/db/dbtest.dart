import 'dart:async';
import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/pow/local_pow.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:isolate';
import 'package:permission_handler/permission_handler.dart';

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

  genWork({required String hash, int threads = 3}) {
    print("AAAA $hash");
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        "Print",
        onMessageReceived: (JavaScriptMessage jsChannel) {
          setState(() {
            print(jsChannel.message);
            setWork(jsChannel.message);
            // controller.runJavaScript('window.stop();');
          });
        },
      )
      ..loadRequest(Uri.parse(
          'https://moonano.net/assets/data/pow/multiThread.html?hash=$hash&threads=${threads.toString()}'));
  }

  setWork(String workk) {
    print("RECEIVED!");
    // work = workk;
    completer.complete(workk);
  }

  String bananas = '';
  @override
  Widget build(BuildContext context) {
    LocalPoW pow = LocalPoW();
    // String work = watchX((LocalPoW x) => x.work);
    int walletIndex = watchOnly((WalletsService x) => x.activeWallet);

    String orgWalletName =
        watchOnly((WalletsService x) => x.walletsList[walletIndex]);
    String activeWalletName = watchOnly((WalletService x) => x.getWalletName(),
        instanceName: orgWalletName);

    WalletService wallet = services<WalletService>(instanceName: orgWalletName);
    // String currentAccount = watchX((WalletService x) => x.currentAccount,
    //     instanceName: orgWalletName);

    int accountIndex = //wallet.activeIndex;
        watchOnly((WalletService x) => x.getActiveIndex(),
            instanceName: orgWalletName);

    String accOrgName = wallet.accountsList[accountIndex];

    String accountName =
        watchOnly((Account x) => x.getName(), instanceName: accOrgName);

    var account = services<Account>(instanceName: accOrgName);
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
                    child: Text("X CLOSE X")),
                // TextButton(
                //   onPressed: () async {
                //     if (!await Permission.bluetoothConnect.isGranted) {
                //       Permission.bluetoothConnect.request();
                //     }

                // services<LocalPoW>().generateWork(
                //     hash:
                //         "BD9F737DDECB0A34DFBA0EDF7017ACB0EF0AA04A6F7A73A406191EF80BB290AD");
                // services<LocalPoW>().generateWork(
                //     hash:
                //         "BD9F737DDECB0A34DFBA0EDF7017ACB0EF0AA04A6F7A73A406191EF80BB290AD",
                //     threads: 2);

                // aa(pow);

                // StateBlock block = await account.iniChangeRep(
                //     "ban_14xjizffqiwjamztn4edhmbinnaxuy4fzk7c7d6gywxigydrrxftp4qgzabh");
                // await Isolate.run(
                // services<LocalPoW>().generateWork(
                //   hash: block.signature,
                //   // ) //;
                //   // ,
                // );
                //     LocalPoW lPow = LocalPoW();
                //
                //     lPow.completer = Completer<String>();
                //     lPow.generateWork(
                //       hash: block.previous,
                //     );
                //     bananas = await lPow.completer.future;
                //     setState(() {
                //       print(bananas);
                //     });
                //     block.work = bananas;
                //     await AccountAPI().processRequest(block, "change");
                //     setState(() {});
                //     print('found it ${bananas}');
                //   },
                //   child: Text("get new work"),
                // ),
                TextButton(
                  onPressed: () async {
                    if (!await Permission.bluetoothConnect.isGranted) {
                      Permission.bluetoothConnect.request();
                    }

                    // services<LocalPoW>().generateWork(
                    //     hash:
                    //         "BD9F737DDECB0A34DFBA0EDF7017ACB0EF0AA04A6F7A73A406191EF80BB290AD");
                    // services<LocalPoW>().generateWork(
                    //     hash:
                    //         "BD9F737DDECB0A34DFBA0EDF7017ACB0EF0AA04A6F7A73A406191EF80BB290AD",
                    //     threads: 2);

                    // aa(pow);

                    await account.changeRepresentative(
                        "ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid");
//ban_14xjizffqiwjamztn4edhmbinnaxuy4fzk7c7d6gywxigydrrxftp4qgzabh
//ban_1moonanoj76om1e9gnji5mdfsopnr5ddyi6k3qtcbs8nogyjaa6p8j87sgid
                    // LocalPoW lPow = LocalPoW();
                    //
                    // lPow.completer = Completer<String>();
                    // lPow.generateWork(
                    //   hash: block.previous,
                    // );
                    // bananas = await lPow.completer.future;
                    // setState(() {
                    //   print(bananas);
                    // });
                    // block.work = bananas;
                    // await AccountAPI().processRequest(block, "change");
                    setState(() {});
                    // print('found it ${bananas}');
                  },
                  child: Text("def change rep"),
                ),
                Text("work"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  aa(LocalPoW pow) {
    Isolate.run(() async {});
  }
}

fakeFn(String work) {
  print("yoooo $work");
  LoadingIndicatorDialog().dismiss();
}

otherFun(data) {
  print(data);
}
