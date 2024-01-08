// import 'dart:async';

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/api/account_history_response.dart';
import 'package:bananokeeper/placeholders/transctions.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/active_address.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:auto_size_text/auto_size_text.dart';

class home_body extends StatefulWidget with GetItStatefulWidgetMixin {
  home_body({super.key});
  @override
  _home_body createState() => _home_body();
}

class _home_body extends State<home_body>
    with WidgetsBindingObserver, GetItStateMixin {
  final ScrollController controller = ScrollController();
  bool returnToTopButton = false;
  late Account _acc;
  late final Future myFuture = getFuture();
  bool firstBoot = true;
  TextEditingController nameController = TextEditingController();
  bool bottomLoadingIcon = false;

  @override
  void initState() {
    controller.addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() async {
    double showoffset = 10.0;
    if (controller.offset > showoffset) {
      returnToTopButton = true;
      setState(() {});
    } else {
      returnToTopButton = false;
      setState(() {});
    }

    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      bottomLoadingIcon = true;
      // await Future.delayed(const Duration(milliseconds: 150), () {
      await services<QueueService>().add(fetchMoreTrans(_acc));
      // });
      bottomLoadingIcon = false;
      setState(() {});
    }
  }

  getFuture() async {
    if (firstBoot) {
      await _acc.getHistory();
      firstBoot = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    int accountIndex =
        watchOnly((WalletService x) => x.activeIndex, instanceName: walletName);

    String accOrgName = wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);
    bool hasReceivables =
        watchOnly((Account x) => x.hasReceivables, instanceName: accOrgName);
    _acc = account;
    List<AccountHistory> history =
        watchOnly((Account x) => x.history, instanceName: accOrgName);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height,
        maxWidth: width,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ActiveAccount(),

          // FutureBuilder(
          //   future: account.getOverview(true),
          //   //account.getOverview(true),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       if (!accountOpen) {
          //         return displayActiveCard(currentTheme, width, currentAccount,
          //             account, wallet, true);
          //       }
          //     } else if (snapshot.connectionState == ConnectionState.done) {
          //       account.handleOverviewResponse(true);
          //       // If we got an error
          //       if (snapshot.hasError) {
          //         return displayActiveCard(currentTheme, width, currentAccount,
          //             account, wallet, true);
          //       }
          //     }
          //     if (!accountOpen) {
          //       return displayActiveCard(
          //           currentTheme, width, currentAccount, account, wallet, true);
          //     } else {
          //       return displayActiveCard(currentTheme, width, currentAccount,
          //           account, wallet, false);
          //     }
          //   },
          // ),
          // -------------TRANSACTIONS TEXT
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.transactions,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: currentTheme.text, fontSize: 24),
                ),
                if (hasReceivables) ...[
                  Container(
                    width: 20,
                    child: IconButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(color: currentTheme.text),
                          ),
                        ),
                      ),
                      splashRadius: 9,
                      onPressed: () {
                        print("i am supposed to be doing magic");
                      },
                      icon: Text(
                        "+",
                        style: TextStyle(
                          color: currentTheme.text,
                          fontSize: currentTheme.fontSize - 2,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),

          // transactionsBody(),

          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: AnimatedOpacity(
                duration:
                    const Duration(milliseconds: 500), //show/hide animation
                opacity: returnToTopButton ? 1.0 : 0.0,
                child: FloatingActionButton(
                  onPressed: () {
                    controller.animateTo(
                        //go to top of scroll
                        0, //scroll offset to go
                        duration: const Duration(
                            milliseconds: 250), //duration of scroll
                        curve: Curves.fastOutSlowIn //scroll type
                        );
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
              ),
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CustomMaterialIndicator(
                    edgeOffset: 50,
                    onRefresh: () => addItemToList(account),
                    // onStateChanged: (change) {
                    //   if (change.didChange(to: IndicatorState.complete)) {
                    //     _renderCompleteState = true;
                    //   } else if (change.didChange(to: IndicatorState.idle)) {
                    //     _renderCompleteState = false;
                    //   }
                    // },
                    withRotation: false,
                    // durations: const RefreshIndicatorDurations(
                    //   completeDuration: Duration(seconds: 2),
                    // ),
                    indicatorBuilder:
                        (BuildContext context, IndicatorController controller) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: currentTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child:
                            // _renderCompleteState
                            //     ? const Icon(
                            //         Icons.check,
                            //         color: Colors.white,
                            //       )
                            //     :
                            SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: currentTheme.text,
                            value: controller.isDragging || controller.isArmed
                                ? controller.value.clamp(0.0, 1.0)
                                : null,
                          ),
                        ),
                      );
                    },
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: Container(
                        child: FutureBuilder(
                          future: myFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              if (history.isEmpty) {
                                return TransactionsPlaceholder();
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return TransactionsPlaceholder();
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
                      ),
                    ),
                  ),
                  if (bottomLoadingIcon) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: currentTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          backgroundColor: currentTheme.primary,
                        ),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          GestureDetector(
            onTap: () {
              //change currency showing here ------------------------
            },
            child: Text(
              " (\$5)",
              style: TextStyle(color: currentTheme.offColor),
            ),
          ),
        ]);
  }

  _transListViewBuilder(account) {
    // _itemCount = account.history.length;

    return ListView.builder(
      controller: controller,
      // physics: const ClampingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),

      shrinkWrap: false,
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
                            getTState(historyItem.type, context),
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

  Widget getTState(String tText, BuildContext context) {
    if (tText == 'send') {
      return Text(
        AppLocalizations.of(context)!.sendCard,
        textAlign: TextAlign.center,
        style: const TextStyle(
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
      return Text(
        AppLocalizations.of(context)!.receiveCard,
        textAlign: TextAlign.center,
        style: const TextStyle(
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
      return Text(
        AppLocalizations.of(context)!.changeCard,
        textAlign: TextAlign.center,
        style: const TextStyle(
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
    await services<QueueService>().add(account.onRefreshUpdateHistory());
    await services<QueueService>().add(account.getOverview(true));
    await services<QueueService>().add(account.handleOverviewResponse(true));
    setState(() {});
  }

  Future<void> fetchMoreTrans(Account account) async {
    int offset = account.history.length;
    int size = 25;
    await services<QueueService>()
        .add(account.onRefreshUpdateHistory(offset, size));
  }

  Widget unopenedCard() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    // double width = MediaQuery.of(context).size.width;

    return ListView(
      controller: controller,
      // physics: const ClampingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),

      shrinkWrap: false,
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
                      AppLocalizations.of(context)!.unopenedAccount,
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
                      AppLocalizations.of(context)!.unopenedReceiveMsg,
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
