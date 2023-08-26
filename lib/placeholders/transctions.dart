// import 'dart:async';

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class TransactionsPlaceholder extends StatefulWidget
    with GetItStatefulWidgetMixin {
  TransactionsPlaceholder({super.key});

  TPState createState() => TPState();
}

final ScrollController controller = ScrollController();

class TPState extends State<TransactionsPlaceholder>
    with WidgetsBindingObserver, GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    double width = MediaQuery.of(context).size.width;

    return ListView(
      controller: controller,
      // physics: const ClampingScrollPhysics(),
      physics: const AlwaysScrollableScrollPhysics(),

      shrinkWrap: true,
      children: [
        cardBuilder(currentTheme, width, "send"),
        cardBuilder(currentTheme, width, "receive"),
        cardBuilder(currentTheme, width, "send"),
        cardBuilder(currentTheme, width, "receive"),
        cardBuilder(currentTheme, width, "send"),
        cardBuilder(currentTheme, width, "receive"),
      ],
    );
  }

  Widget cardBuilder(BaseTheme currentTheme, double width, String type) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: Center(
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
                  child: Row(children: [
                    const SizedBox(width: 10),
                    Container(
                      width: 90,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTState(type),
                            Text(
                              "${(Random().nextDouble() * 1000.0).toStringAsFixed(3)} BAN",
                              style: TextStyle(
                                color: currentTheme.text,
                              ),
                            ),
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
                                "ban_123455667890",
                                style: TextStyle(color: currentTheme.text),
                              ),
                            ),
                          ])),
                    )
                    // Text(" ${height.toString()}. ${width.toString()}")
                  ]),
                ),
              ],
            ),
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
    } else {
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
    }
  }
}
