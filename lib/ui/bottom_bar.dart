// import 'dart:async';

import 'package:bananokeeper/ui/send/send_menu_1.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../themes.dart';

class BottomBarApp extends StatefulWidget with GetItStatefulWidgetMixin {
  BottomBarApp({super.key});
  @override
  BottomBarAppState createState() => BottomBarAppState();
}

class BottomBarAppState extends State<BottomBarApp> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(child: buildMainSettings(context));
  }

  Widget buildMainSettings(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return BottomAppBar(
      color: currentTheme.primaryBottomBar,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Receive button --------
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 215,
                ),
                child: SizedBox(
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: currentTheme.text,
                        backgroundColor: currentTheme.primary // foreground
                        ),
                    onPressed: () {
                      showModal(context, "meow");
                    },
                    child: SizedBox(
                      width: width / 3.5,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, //Center Row contents horizontally,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, //Center Row contents vertically,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.receive,
                              // "Receive",
                              style: TextStyle(
                                  fontSize: currentTheme.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: currentTheme.text),
                            ),
                            const Icon(Icons.arrow_downward_rounded),
                          ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              //Send button --------

              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 215,
                ),
                child: SizedBox(
                  height: 40,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: currentTheme.text,
                        backgroundColor: currentTheme.primary // foreground
                        ),
                    onPressed: () {
                      // showModal(context, "meow");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SendMenu1(),
                        ),
                      );
                    },
                    child: SizedBox(
                      // color: Colors.grey.shade400,
                      // padding: const EdgeInsets.all(8),
                      // Change button text when light changes state.
                      width: width / 3.5,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, //Center Row contents horizontally,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, //Center Row contents vertically,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.send,
                              style: TextStyle(
                                fontSize: currentTheme.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.arrow_upward_rounded),
                          ]),
                    ),
                  ),
                ),
              ),
              // if (centerLocations.contains(fabLocation)) const Spacer(),
            ],
          )),
    );
  }
}

//// ------- Use this to show Receive/Send popups
void showModal(BuildContext context, String dataS) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: Text('Example Dialog $dataS'),
      actions: <TextButton>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        )
      ],
    ),
  );
}
