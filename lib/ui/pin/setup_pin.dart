// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/main_app_logic.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';

@RoutePage(name: "SetupPinRoute")
class SetupPin extends StatefulWidget with GetItStatefulWidgetMixin {
  // SetupPin({super.key});

  @override
  SetupPinState createState() => SetupPinState();

  final String nextPage;
  SetupPin(this.nextPage, {super.key});
}

class SetupPinState extends State<SetupPin> with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }

  final pinController = TextEditingController();
  FocusNode pinFocusNode = FocusNode();
  bool firstWindow = true;
  String pin = "1";
  String pinConfirmation = "11";
  int pinMatching = 2;
  String topMsg = "Enter PIN";

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // constraints: BoxConstraints(
            //   minWidth: 100,
            //   maxWidth: 500,
            //   // maxHeight: 600,
            // ),
            decoration: BoxDecoration(
              color: currentTheme.primary,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 50,
                    bottom: 50,
                  ),
                  child: AutoSizeText(
                    "Setup PIN",
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: 34,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                AutoSizeText(
                  topMsg,
                  style: TextStyle(
                    color: statusMessageColor(currentTheme),
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Pinput(
                          closeKeyboardWhenCompleted: false,
                          focusNode: pinFocusNode,
                          autofocus: true,
                          onChanged: (value) => {},
                          controller: pinController,
                          onCompleted: (localPIN) => {
                            if (firstWindow)
                              {
                                setState(() {
                                  firstWindow = false;
                                  pin = localPIN;
                                  topMsg = "Confirm your PIN please";
                                }),
                                Future.delayed(
                                    const Duration(milliseconds: 1000), () {
                                  setState(() {
                                    pinController.clear();
                                  });
                                }),
                              }
                            else
                              {
                                setState(() {
                                  pinConfirmation = localPIN;
                                }),
                                if (pin == pinConfirmation)
                                  {
                                    setState(() {
                                      pinMatching = 1;
                                      topMsg = "PIN saved.";
                                    }),
                                    Future.delayed(
                                        const Duration(milliseconds: 1000), () {
                                      setState(() {
                                        savePinLogic();
                                        firstWindow = true;
                                        pin = "";
                                        pinConfirmation = "11";
                                        pinController.clear();

                                        if (widget.nextPage == "homepage") {
                                          services<AppRouter>().pop();
                                          // Navigator.of(context).pop();
                                        } else if (widget.nextPage ==
                                            "initial") {
                                          // Navigator.pushAndRemoveUntil(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             MainAppLogic()),
                                          //     ModalRoute.withName("/homepage"));
                                          services<AppRouter>()
                                              .replaceAll([HomeRoute()]);
                                        }
                                      });
                                    })
                                  }
                                else
                                  {
                                    setState(() {
                                      pinMatching = 0;
                                      topMsg = "Error: PINs do not match.";
                                    }),
                                    Future.delayed(
                                        const Duration(milliseconds: 2000), () {
                                      setState(() {
                                        firstWindow = true;
                                        pinController.clear();
                                        pin = "";
                                        pinConfirmation = "11";
                                        pinMatching = 2;
                                        topMsg = "Enter pin";
                                      });
                                    })
                                  }
                              },
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color statusMessageColor(currentTheme) {
    switch (pinMatching) {
      case 0:
        return currentTheme.red;
      case 1:
        return currentTheme.green;
      case 2:
      default:
        return currentTheme.text;
    }
  }

  savePinLogic() {
    services<UserData>().setPin(pin);
    services<SharedPrefsModel>().savePin(pin);
  }
}
