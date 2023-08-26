import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/db/dbManager.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class DBTest extends StatefulWidget with GetItStatefulWidgetMixin {
  DBTest({super.key});

  @override
  DBTestState createState() => DBTestState();
}

class DBTestState extends State<DBTest> with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var wallets_data;
  @override
  Widget build(BuildContext context) {
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
                TextButton(
                  onPressed: () async {
                    wallets_data = await services<DBManager>().getWallets();
                    print(wallets_data);
                    setState(() {});
                  },
                  child: Text("wallets"),
                ),
                TextButton(
                  onPressed: () async {
                    String walletname =
                        services<WalletsService>().wallets[0].original_name;
                    wallets_data =
                        await services<DBManager>().getWalletData(walletname);
                    // print(await services<DBManager>()
                    //     .database
                    //     .rawQuery('DROP TABLE wallets'));
                    // print(await services<DBManager>()
                    //     .database
                    //     .rawQuery('DROP TABLE active_wallet'));
                    // print(await services<DBManager>()
                    //     .database
                    //     .rawQuery('DROP TABLE contacts'));
                    // print(await services<DBManager>()
                    //     .database
                    //     .rawQuery('DROP TABLE wallet_0'));

                    setState(() {});
                  },
                  child: Text("get wallet data"),
                ),
                Text("11111"),
                AutoSizeText(wallets_data.toString()),
                Text("22222"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
