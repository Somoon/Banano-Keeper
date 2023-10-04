import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nanodart/nanodart.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class ManualRepChange {
  static final ManualRepChange _singleton = ManualRepChange._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  bool isValidAddress = false;
  String repName = "";
  String score = "";
  String weight = "";
  Representative? rep;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  factory ManualRepChange() {
    return _singleton;
  }

  ManualRepChange._internal();

  Future<bool?> show(BuildContext context, currentTheme, double height,
      appLocalizations, Account account) async {
    if (isDisplayed) {
      return false;
    }
    _context = context;
    isValidAddress = false;

    return showModalBottomSheet<bool>(
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
                  child: SizedBox(
                    height: height / 1.25,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: ScaffoldMessenger(
                        key: scaffoldMessengerKey,
                        child: Scaffold(
                          resizeToAvoidBottomInset: false,
                          backgroundColor: currentTheme.primary,
                          body: Center(
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  height: 5,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
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
                                              Navigator.of(context).pop(false);
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
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Column(
                                    children: [
                                      AutoSizeText(
                                        appLocalizations!.changeRepTitle,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: currentTheme.text,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(25.0),
                                        child: Column(
                                          children: [
                                            const Gap(80),
                                            sendAddressTextField(currentTheme,
                                                context, setState),
                                            if (isValidAddress &&
                                                rep != null) ...[
                                              displayAdditionalInfo(
                                                  currentTheme,
                                                  appLocalizations),
                                            ] else ...[
                                              // const Gap(80),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          bottomNavigationBar: displayButtons(context, setState,
                              currentTheme, account, appLocalizations),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  displayButtons(BuildContext context, StateSetter setState,
      BaseTheme currentTheme, Account account, appLocalizations) {
    return SizedBox(
      height: 170,
      child: BottomAppBar(
        color: currentTheme.primary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: currentTheme.btnStyle,
                  onPressed: () async {
                    changeRep(context, account);
                  },
                  child: Text(
                    appLocalizations!.changeButton,
                    // AppLocalizations.of(context)!.add,
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: currentTheme.fontSize,
                    ),
                  ),
                ),
              ),
              const Gap(30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
                    // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),

                    side: MaterialStatePropertyAll<BorderSide>(
                      BorderSide(
                        color: currentTheme.buttonOutline,
                        width: 1,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      addressController.clear();
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text(
                    appLocalizations!.cancel,
                    // AppLocalizations.of(context)!.add,
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: currentTheme.fontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayAdditionalInfo(currentTheme, appLocalizations) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(30),
          AutoSizeText(
            appLocalizations!.repAlias(repName),
            maxLines: 1,
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 16,
            ),
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weight,
                style: TextStyle(
                  color: currentTheme.offColor,
                ),
              ),
              const Gap(20),
              Text(
                score,
                style: TextStyle(
                  color: currentTheme.offColor,
                ),
              ),
            ],
          ),
          const Gap(40),
        ],
      ),
    );
  }

  final addressController = TextEditingController();
  FocusNode addressControllerFocusNode = FocusNode();
  TextFormField sendAddressTextField(
      BaseTheme currentTheme, BuildContext context, StateSetter setState) {
    return TextFormField(
      maxLines: 3,
      minLines: 1,
      textAlign: TextAlign.center,
      focusNode: addressControllerFocusNode,
      controller: addressController,
      autofocus: false,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: currentTheme.secondary,
        isDense: false,
        isCollapsed: false,
        contentPadding: const EdgeInsets.all(10),
        hintText: AppLocalizations.of(context)!.enterAddressHint,
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: IconButton(
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedText = cdata?.text ?? "";
            bool isCorrectHex =
                NanoAccounts.isValid(NanoAccountType.BANANO, copiedText);

            setState(() {
              if (isCorrectHex) {
                addressController.text = copiedText;
                isValidAddress = true;
                rep = services<UserData>().getRepData(addressController.text);
                repName = rep?.alias ?? "";
                score = (rep?.score != null ? "Score: ${rep?.score}/100" : "");
                weight =
                    "Voting weight: ${rep?.weightPercentage.toStringAsFixed(2)}%";
              } else {
                isValidAddress = false;
              }
            });
          },
          icon: const Icon(
            Icons.paste_outlined,
          ),
          color: currentTheme.textDisabled,
        ),
        // Container(
        //   margin: const EdgeInsets.all(8),
        //   // width: 15,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       minimumSize: const Size(15, 35),
        //       backgroundColor: currentTheme.primaryBottomBar,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(30.0),
        //       ),
        //     ),
        //     child: Icon(
        //       size: 18,
        //       Icons.paste_outlined,
        //       color: currentTheme.text,
        //     ),
        //     onPressed: () async {
        //       ClipboardData? cdata =
        //           await Clipboard.getData(Clipboard.kTextPlain);
        //       String copiedText = cdata?.text ?? "";
        //       bool isCorrectHex =
        //           NanoAccounts.isValid(NanoAccountType.BANANO, copiedText);
        //
        //       if (isCorrectHex) {
        //         addressController.text = copiedText;
        //       }
        //     },
        //   ),
        // ),
        prefixIcon: IconButton(
          onPressed: () async {
            if (!Platform.isWindows) {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: Stack(
                        children: [
                          QRCodeDartScanView(
                            scanInvertedQRCode: true,
                            typeScan: TypeScan.live,
                            formats: const [BarcodeFormat.QR_CODE],
                            resolutionPreset:
                                QRCodeDartScanResolutionPreset.high,
                            onCapture: (Result result) {
                              // print(result.text);
                              if (result is String &&
                                  NanoAccounts.isValid(
                                      NanoAccountType.BANANO, result.text)) {
                                addressController.text = result.text;
                                isValidAddress = true;
                                rep = services<UserData>()
                                    .getRepData(addressController.text);
                                repName = rep?.alias ?? "";
                                score = (rep?.score != null
                                    ? "Score: ${rep?.score}/100"
                                    : "");
                                weight =
                                    "Voting weight: ${rep?.weightPercentage.toStringAsFixed(2)}%";

                                Navigator.of(context).pop();
                              } else {
                                isValidAddress = false;
                              }
                            },
                          ),
                          QRScannerOverlay(
                            overlayColor: Colors.black.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ));
              setState(() {});
            } else {
              var snackBar = SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.qrNotSupported,
                  style: TextStyle(
                    color: currentTheme.textDisabled,
                  ),
                ),
              );
              scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
            }
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
          color: currentTheme.textDisabled,
        ),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          if (value.length >= 64) {
            if (NanoAccounts.isValid(NanoAccountType.BANANO, value)) {
              isValidAddress = true;
              rep = services<UserData>().getRepData(addressController.text);
              repName = rep?.alias ?? "";
              score = (rep?.score != null
                  ? AppLocalizations.of(context)!
                      .repScore(rep?.score.toString() ?? "0.00")
                  : "");
              weight = AppLocalizations.of(context)!.repVotingWeight(
                  rep?.weightPercentage.toStringAsFixed(2) ?? "0.00");
            } else {
              isValidAddress = false;
              return AppLocalizations.of(context)!.addressFieldErrAddr;
            }
          }
        }
        // isValidAddress = false;
        return null;
      },
      style: TextStyle(
        color: currentTheme.text,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
    );
  }

  changeRep(BuildContext context, Account account) async {
    if (NanoAccounts.isValid(NanoAccountType.BANANO, addressController.text)) {
      bool canauth = await BiometricUtil().canAuth();
      bool verified = false;

      if (!canauth) {
        verified = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VerifyPIN(),
              ),
            ) ??
            false;
      } else {
        verified = await BiometricUtil()
            .authenticate(AppLocalizations.of(context)!.authMsgChangeRep);
        //appLocalizations.authMsgWalletDel);
      }

      if (verified) {
        LoadingIndicatorDialog().show(context,
            text: AppLocalizations.of(context)!.loadingWidgetChangeRepMsg);

        bool result =
            await account.changeRepresentative(addressController.text);
        LoadingIndicatorDialog().dismiss();
        if (result) {
          addressController.clear();
          Navigator.of(context).pop(true);

          // Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  dismiss() {
    if (isDisplayed) {
      addressController.dispose();
      addressControllerFocusNode.dispose();
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
