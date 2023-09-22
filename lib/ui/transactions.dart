import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/account_history_response.dart';
import 'package:bananokeeper/placeholders/transctions.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:bananokeeper/themes.dart';

class transactionsBody extends StatefulWidget with GetItStatefulWidgetMixin {
  transactionsBody({super.key});
  @override
  _transactionsBody createState() => _transactionsBody();
}

class _transactionsBody extends State<transactionsBody>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  void initState() {
    super.initState();
  }

  final ScrollController controller = ScrollController();

  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    int accountIndex =
        watchOnly((WalletService x) => x.activeIndex, instanceName: walletName);

    String accOrgName = wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);

    List<AccountHistory> history =
        watchOnly((Account x) => x.history, instanceName: accOrgName);

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => addItemToList(account),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: Container(
            child: //[
                FutureBuilder(
              future: account.getHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (history.isEmpty) {
                    return TransactionsPlaceholder();
                  }
                  //return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  // if (!completed) {
                  //   account.handleResponse();
                  // }
                  // If we got an error
                  if (snapshot.hasError) {
                    return TransactionsPlaceholder();
                    // Center(
                    //   child: Text(
                    //     '${snapshot.error} occurred',
                    //     style: const TextStyle(fontSize: 18),
                    //   ),
                    // );
                  }
                }
                if (history.isEmpty) {
                  return unopenedCard();
                } else {
                  return _transListViewBuilder(account);
                }
                // else if (snapshot.hasData) {
                //   return _transListViewBuilder();
                // } else {
                //   return const Text("No data available");
                // }
              },
            ),
            //],
          ),
        ),
      ),
    );
  }

  _transListViewBuilder(account) {
    return ListView.builder(
      controller: controller,
      // physics: const ClampingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),

      shrinkWrap: true,
      itemCount: account.history.length,
      // prototypeItem: Padding(
      //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      //   child: Card(
      //     color: Colors.transparent,
      //     child: _buildButtonColumn(
      //         context, Colors.brown, Icons.add_box, lItems[0]),
      //   ),
      // ),
      itemBuilder: (context, index) {
        return _buildButtonColumn(context, account.history[index], index);
      },
    );
  }

  Widget _buildButtonColumn(
      BuildContext context, AccountHistory historyItem, int index) {
    double width = MediaQuery.of(context).size.width;
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    // double height = MediaQuery.of(context).size.height;
    return Center(
      child: Card(
        color: currentTheme.secondary,
        child: Container(
          decoration: BoxDecoration(
            color: currentTheme.secondary,
            borderRadius: BorderRadius.circular(10),
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
                    const SizedBox(width: 10),
                    Container(
                      width: 90,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTState(historyItem.type),
                            if (historyItem.type != 'change') ...[
                              Text(
                                "${historyItem.amount} BAN",
                                style: TextStyle(
                                  color: currentTheme.text,
                                ),
                              ),
                            ],
                          ]),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, //Center Row contents horizontally,
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, //Center Row contents vertically,
                              children: <Widget>[
                            Flexible(
                              child: Text(
                                // "${(Random().nextDouble() * 10000.0).toStringAsFixed(3)} BAN",
                                width > 850
                                    ? (historyItem.type != "change"
                                        ? historyItem.address
                                        : historyItem.newRepresentative)
                                    : Utils().shortenAccount(
                                        (historyItem.type != "change"
                                            ? historyItem.address
                                            : historyItem.newRepresentative),
                                        true),
                                style: TextStyle(color: currentTheme.text),
                              ),
                            ),
                          ])),
                    )
                    // Text(" ${height.toString()}. ${width.toString()}")
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTState(String tText) {
    if (tText == 'send') {
      return const Text(
        'SEND',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6C1B1B),
          shadows: [
            Shadow(
              blurRadius: 10.0, // shadow blur
              color: Colors.black, // shadow color
              offset: Offset(2.0, 2.0), // how much shadow will be shown
            ),
          ],
        ),
      );
    } else if (tText == "receive") {
      return const Text(
        'RECEIVE',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          shadows: [
            Shadow(
              blurRadius: 10.0, // shadow blur
              color: Colors.black, // shadow color
              offset: Offset(2.0, 2.0), // how much shadow will be shown
            ),
          ],
        ),
      );
    } else {
      return const Text(
        "CHANGE",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          shadows: [
            Shadow(
              blurRadius: 10.0, // shadow blur
              color: Colors.black, // shadow color
              offset: Offset(2.0, 2.0), // how much shadow will be shown
            ),
          ],
        ),
      );
    }
  }

  Future<void> addItemToList(account) async {
    await account.onRefreshUpdateHistory();
    await account.getOverview(true);
    await account.handleOverviewResponse(true);

    setState(() {});
  }

  Widget unopenedCard() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    // double width = MediaQuery.of(context).size.width;

    return ListView(
      controller: controller,
      // physics: const ClampingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),

      shrinkWrap: true,
      children: [
        Card(
          color: currentTheme.secondary,
          child: Container(
            decoration: BoxDecoration(
              color: currentTheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
            height: 75,
            child: Center(
              child: Ink(
                height: 70,
                width: double.infinity,
                color: currentTheme.secondary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      "Unopened Account",
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: currentTheme.fontSize - 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText(
                      "Receive Banano to open your new account.",
                      style: TextStyle(
                        color: currentTheme.textDisabled,
                        fontSize: currentTheme.fontSize - 2,
                      ),
                    ),
                  ],
                ),

                // Text(" ${height.toString()}. ${width.toString()}")
              ),
            ),
          ),
        ),
      ],
    );
  }
}
