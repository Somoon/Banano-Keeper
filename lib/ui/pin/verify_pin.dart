// ignore_for_file: prefer_const_constructors

import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';

@RoutePage<bool>(name: "VerifyPINRoute")
class VerifyPIN extends StatefulWidget with GetItStatefulWidgetMixin {
  final String header;
  VerifyPIN({super.key, this.header = ""});

  @override
  VerifyPINState createState() => VerifyPINState();
}

class VerifyPINState extends State<VerifyPIN> with GetItStateMixin {
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
  int incorrectAttempt = 0;
  String topMsg = "";
  String userPIN = services<UserData>().getPin();

  @override
  Widget build(BuildContext context) {
    String header = (widget.header != "")
        ? widget.header
        : AppLocalizations.of(context)!.verifyPIN;

    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: currentTheme.primary,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10, top: 10),
                      child: SizedBox(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              // Navigator.of(context).pop(false);
                              services<AppRouter>().pop(false);
                            });
                          },
                          style: ButtonStyle(
                            foregroundColor: MaterialStatePropertyAll<Color>(
                                currentTheme.textDisabled),
                            // backgroundColor:
                            //     MaterialStatePropertyAll<
                            //         Color>(primary),
                          ),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 50,
                    bottom: 50,
                  ),
                  child: AutoSizeText(
                    header,
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
                    color: currentTheme.red,
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
                            if (localPIN != userPIN)
                              {
                                incorrectAttempt++,
                                setState(() {
                                  topMsg = "PIN incorrect.";
                                }),
                                Future.delayed(
                                    const Duration(milliseconds: 1500), () {
                                  setState(() {
                                    if (incorrectAttempt >= 3) {
                                      // services<AppRouter>().pop<bool>(false);
                                      Navigator.of(context).pop(false);
                                    }
                                    pinController.clear();
                                    topMsg = "";
                                  });
                                })
                              }
                            else
                              {
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  setState(() {
                                    pinController.clear();
                                    // services<AppRouter>().pop<bool>(true);
                                    Navigator.of(context).pop(true);
                                  });
                                })
                              }
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
}
