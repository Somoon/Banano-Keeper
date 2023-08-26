// import 'dart:async';

import 'package:bananokeeper/ui/transactions.dart';
import 'package:flutter/material.dart';
import '../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'active_address.dart';

class home_body extends StatefulWidget with GetItStatefulWidgetMixin {
  home_body({super.key});
  @override
  _home_body createState() => _home_body();
}

class _home_body extends State<home_body>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(child: buildMainSettings(context));
  }

  Widget buildMainSettings(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    var textColor = watchOnly((ThemeModel x) => x.curTheme.text);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ActiveAccount(),
        // -------------TRANSACTIONS TEXT
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Transactions",
                textDirection: TextDirection.ltr,
                style: TextStyle(color: textColor, fontSize: 24),
              ),
              // if (account.hasReceivables) ...[
              //   Container(
              //     width: 30,
              //     child: IconButton(
              //       style: ButtonStyle(
              //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //           RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30.0),
              //             side: BorderSide(color: currentTheme.text),
              //           ),
              //         ),
              //       ),
              //       splashRadius: 9,
              //       onPressed: () {
              //         print("i am supposed to be doing magic");
              //       },
              //       icon: Text(
              //         "+",
              //         style: TextStyle(
              //           color: currentTheme.text,
              //           fontSize: currentTheme.fontSize - 2,
              //         ),
              //       ),
              //     ),
              //   ),
              // ]
            ],
          ),
        ),

        transactionsBody(),
      ],
    );
  }
}
