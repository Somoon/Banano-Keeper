import 'dart:convert';
import 'dart:io';

import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter/services.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nanodart/nanodart.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class ChangeRepBottomSheet extends StatefulWidget
    with GetItStatefulWidgetMixin {
  ChangeRepBottomSheet({super.key});
  @override
  ChangeRepBottomSheetState createState() => ChangeRepBottomSheetState();
}

class ChangeRepBottomSheetState extends State<ChangeRepBottomSheet>
    with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final addressController = TextEditingController();
  FocusNode addressControllerFocusNode = FocusNode();

  @override
  void dispose() {
    addressController.dispose();
    addressControllerFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    int walletID = watchOnly((WalletsService x) => x.activeWallet);
    String walletName =
        watchOnly((WalletsService x) => x.walletsList[walletID]);
    WalletService wallet = services<WalletService>(instanceName: walletName);

    int accountIndex =
        watchOnly((WalletService x) => x.activeIndex, instanceName: walletName);
    String accOrgName = wallet.accountsList[accountIndex];
    var account = services<Account>(instanceName: accOrgName);

    final LocalAuthentication auth = LocalAuthentication();
    var appLocalizations = AppLocalizations.of(context);

    return createSheet(context, currentTheme, account);
  }

  createSheet(context, currentTheme, Account account) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return showModalBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: currentTheme.primary,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // services<QueueService>().add(account.getOverview(true));
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentTheme.primary,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: currentTheme.primary,
                ),
                // color: currentTheme.primary,
                child: SizedBox(
                  height: height / 1.25,
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
                                    setState(() {
                                      addressController.clear();
                                      Navigator.of(context).pop(context);
                                    });
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
                              // AutoSizeText(
                              //   AppLocalizations.of(context)!.send,
                              //   maxLines: 1,
                              //   style: TextStyle(
                              //     fontSize: 28,
                              //     fontWeight: FontWeight.bold,
                              //     color: currentTheme.text,
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // AutoSizeText(
                              //   account.name,
                              //   maxLines: 1,
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     color: currentTheme.text,
                              //     fontFamily: 'monospace',
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 25, right: 25),
                              //   child: Utils().colorffix(
                              //       account.address, currentTheme),
                              // ),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // Utils().formatBalance(
                              //     activeAccountBalance, currentTheme),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // sendAddressTextField(currentTheme, context),
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // sendAmountTextField(
                              //     account, currentTheme, context),
                              // const SizedBox(
                              //   height: 40,
                              // ),
                              // createSendButton(account, currentTheme,
                              //     appLocalizations, width),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              // createQRButton(
                              //     currentTheme, appLocalizations, width),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
