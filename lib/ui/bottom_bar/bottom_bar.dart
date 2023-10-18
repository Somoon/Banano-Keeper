// import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/ui/bottom_bar/send_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nanodart/nanodart.dart';

class BottomBarApp extends StatefulWidget with GetItStatefulWidgetMixin {
  BottomBarApp({super.key});
  @override
  BottomBarAppState createState() => BottomBarAppState();
}

class BottomBarAppState extends State<BottomBarApp> with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final addressController = TextEditingController();
  FocusNode addressControllerFocusNode = FocusNode();
  final amountController = TextEditingController();
  FocusNode amountControllerFocusNode = FocusNode();

  bool validAddr = false;
  bool validAmount = false;
  @override
  void dispose() {
    addressController.dispose();
    addressControllerFocusNode.dispose();
    amountController.dispose();
    amountControllerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    int accountIndex =
        watchOnly((WalletService x) => x.activeIndex, instanceName: walletName);

    String accOrgName = wallet.accountsList[accountIndex];

    var account = services<Account>(instanceName: accOrgName);

    // double height = MediaQuery.of(context).size.height;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: BottomAppBar(
        color: currentTheme.primaryBottomBar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
                    child: receiveTextButton(
                        currentTheme, context, height, width, account)),
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
                  child: sendTextButton(
                      currentTheme, context, height, width, account),
                ),
              ),
              // if (centerLocations.contains(fabLocation)) const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  TextButton sendTextButton(BaseTheme currentTheme, BuildContext context,
      double height, double width, Account account) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: currentTheme.text,
        backgroundColor: currentTheme.primary,
        elevation: 5,
      ),
      onPressed: () async {
        var appLocalizations = AppLocalizations.of(context);

        final sendPage = SendBottomSheet();
        if (sendPage.isDisplayed) {
          sendPage.clear();
        }
        sendPage.show(context, services<ThemeModel>().curTheme,
            appLocalizations, account);
      },
      child: SizedBox(
        width: width / 3.5,
        child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Row contents horizontally,
            crossAxisAlignment:
                CrossAxisAlignment.center, //Center Row contents vertically,
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
    );
  }

  TextButton receiveTextButton(BaseTheme currentTheme, BuildContext context,
      double height, double width, Account account) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: currentTheme.text,
        backgroundColor: currentTheme.primary,
        elevation: 5,
      ),
      onPressed: () async {
        var appLocalizations = AppLocalizations.of(context);

        showModalBottomSheet<void>(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: currentTheme.primary,
          builder: (BuildContext context) {
            // bool qrBoxOption = false;
            int qrOptionInt = 0;
            List<Widget> qrImages = [
              // ConstrainedBox(
              //   constraints: const BoxConstraints(
              //       // maxHeight: 380.0,
              //       ),
              //   child: const Image(
              //     image: AssetImage('images/qrOptionFace.png'),
              //     // width: 600,
              //   ),
              // ),
              const Image(
                image: AssetImage('images/banano.png'),
                height: 200,
                width: 200,
              ),
              FadeInImage.assetNetwork(
                image: 'https://imgproxy.moonano.net/${account.address}',
                placeholder: 'images/greymonkey.png',
                width: 200,
                fit: BoxFit.fill,
                imageErrorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Image(
                    image: AssetImage('images/banano.png'),
                    height: 200,
                    width: 200,
                  );
                },
              ),
            ];

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: currentTheme.primary,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: currentTheme.primary,
                  ),
                  // color: currentTheme.primary,
                  child: SizedBox(
                    height: height / 1.35,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            height: 5,
                            width: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              color: currentTheme.secondary,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                ),
                                child: SizedBox(
                                  child: TextButton(
                                    onPressed: () {
                                      amountController.clear();
                                      addressController.clear();
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStatePropertyAll<Color>(
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
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              children: [
                                AutoSizeText(
                                  account.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: currentTheme.text,
                                  ),
                                ),
                                const Gap(20),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25),
                                  child: Utils()
                                      .colorffix(account.address, currentTheme),
                                ),
                                const Gap(40),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 200.0,
                                      width: 200.0,
                                      color: Colors.white,
                                    ),
                                    qrImages[qrOptionInt],
                                    /*
                                    if (qrBoxOption) ...[
                                      const Image(
                                        image: AssetImage('images/banano.png'),
                                        height: 200,
                                        width: 200,
                                      ),
                                    ] else ...[
                                      FadeInImage.assetNetwork(
                                        image:
                                            'https://imgproxy.moonano.net/${account.address}',
                                        placeholder: 'images/greymonkey.png',
                                        width: 200,
                                        fit: BoxFit.fill,
                                        imageErrorBuilder:
                                            (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                          return const Image(
                                            image:
                                                AssetImage('images/banano.png'),
                                            width: 200,
                                          );
                                        },
                                      ),
                                    ],

                                     */
                                    QrImageView(
                                      data: account.address,
                                      version: QrVersions.auto,
                                      size: 200.0,
                                      backgroundColor: Colors
                                          .transparent, //currentTheme.textDisabled,
                                      // eyeStyle: const QrEyeStyle(
                                      //     eyeShape: QrEyeShape.circle,
                                      //     color: Colors.yellow),
                                      // embeddedImage:
                                      //     Image.asset('images/banano.png').image,
                                      // embeddedImageStyle: const QrEmbeddedImageStyle(
                                      //   size: Size(41.0, 41.0),
                                      //   color: Colors.blue,
                                      // ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                TextButton(
                                  style: currentTheme.btnStyleNoBorder,
                                  onPressed: () {
                                    int currentInt = qrOptionInt;
                                    setState(() {
                                      if (currentInt == qrImages.length - 1) {
                                        qrOptionInt = 0;
                                      } else {
                                        qrOptionInt++;
                                      }
                                    });
                                  },
                                  child: Text(
                                    '>',
                                    style: currentTheme.textStyle,
                                  ),
                                ),
                                /*
                                Switch(
                                  // This bool value toggles the switch.
                                  value: qrBoxOption,
                                  activeColor: currentTheme.text,
                                  activeTrackColor: Colors.black38,
                                  inactiveThumbColor: currentTheme.text,

                                  onChanged: (bool value) {
                                    // This is called when the user toggles the switch.
                                    setState(() {
                                      qrBoxOption = !qrBoxOption;
                                    });
                                  },
                                ),

                                 */
                                const Gap(40),
                                SizedBox(
                                  height: 48,
                                  width: width - 40,
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      overlayColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => currentTheme.text
                                                  .withOpacity(0.3)),
                                      // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),

                                      side:
                                          MaterialStatePropertyAll<BorderSide>(
                                        BorderSide(
                                          color: currentTheme.buttonOutline,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      Clipboard.setData(
                                        ClipboardData(text: account.address),
                                      );
                                      setState(() {});
                                    },
                                    child: AutoSizeText(
                                      appLocalizations!.copyAddress,
                                      style: TextStyle(
                                        color: currentTheme.text,
                                        fontSize: currentTheme.fontSize,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        setState(() {});
      },
      child: SizedBox(
        width: width / 3.5,
        child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Row contents horizontally,
            crossAxisAlignment:
                CrossAxisAlignment.center, //Center Row contents vertically,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.receive,
                style: TextStyle(
                  fontSize: currentTheme.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_upward_rounded),
            ]),
      ),
    );
  }
}
