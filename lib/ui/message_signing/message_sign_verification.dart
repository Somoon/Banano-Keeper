import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';

import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/dialogs/info_dialog.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nanodart/nanodart.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

// @RoutePage<bool>(name: "MsgSignVerifyRoute")
class MsgSignVerifyPage {
  static final MsgSignVerifyPage _singleton = MsgSignVerifyPage._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  int selectedIndex = -1;
  bool showResult = false;
  bool signValid = false;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  factory MsgSignVerifyPage() {
    return _singleton;
  }

  MsgSignVerifyPage._internal();

  Future<bool?> show(
    BuildContext context,
    BaseTheme currentTheme,
  ) async {
    if (isDisplayed) {
      return false;
    }
    double height = MediaQuery.of(context).size.height;

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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
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
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: currentTheme.secondary,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                  ),
                                  Row(
                                    //was end
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: SizedBox(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                InfoDialog().show(
                                                    context,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .messageVerifyInfoDialogTitle,
                                                    AppLocalizations.of(
                                                            context)!
                                                        .messageVerifyInfoDialogExplanation,
                                                    currentTheme);
                                              });
                                            },
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStatePropertyAll<
                                                          Color>(
                                                      currentTheme
                                                          .textDisabled),
                                              // backgroundColor:
                                              //     MaterialStatePropertyAll<
                                              //         Color>(primary),
                                            ),
                                            child: const Icon(
                                                Icons.info_outline_rounded),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: SizedBox(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                // addressController.clear();
                                                services<AppRouter>()
                                                    .pop(false);
                                              });
                                            },
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStatePropertyAll<
                                                          Color>(
                                                      currentTheme
                                                          .textDisabled),
                                              // backgroundColor:
                                              //     MaterialStatePropertyAll<
                                              //         Color>(primary),
                                            ),
                                            child: const Icon(Icons.close),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    child: Column(
                                      children: [
                                        AutoSizeText(
                                          AppLocalizations.of(context)!
                                              .messageVerifyTitle,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: currentTheme.text,
                                          ),
                                        ),
                                        const Gap(30),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 25.0,
                                            right: 25.0,
                                          ),
                                          child: Column(
                                            children: [
                                              createTextFieldTitle(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .enterAddressLabel,
                                                  currentTheme),
                                              addressTextField(currentTheme,
                                                  context, setState),
                                              const Gap(30),
                                              createTextFieldTitle(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .enterMessageLabel,
                                                  currentTheme),
                                              messageTextField(currentTheme,
                                                  context, setState),
                                              const Gap(30),
                                              createTextFieldTitle(
                                                  context,
                                                  AppLocalizations.of(context)!
                                                      .enterSignLabel,
                                                  currentTheme),
                                              signTextField(currentTheme,
                                                  context, setState),
                                            ],
                                          ),
                                        ),
                                        const Gap(30),
                                        if (showResult) ...[
                                          AutoSizeText(
                                            (signValid
                                                ? AppLocalizations.of(context)!
                                                    .signValidMessage
                                                : AppLocalizations.of(context)!
                                                    .signInvalidMessage),
                                            style: TextStyle(
                                              fontSize: currentTheme.fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: (signValid
                                                  ? Colors.green
                                                  : Colors.red),
                                            ),
                                          )
                                        ],
                                        if (errMsg != '') ...[
                                          const Gap(20),
                                          AutoSizeText(
                                            errMsg,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            bottomNavigationBar: displayButtons(
                                context, setState, currentTheme, height),
                          ),
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

  Widget createTextFieldTitle(
      BuildContext context, label, BaseTheme currentTheme) {
    return Align(
      alignment: (!Utils().isDirectionRTL(context)
          ? Alignment.centerLeft
          : Alignment.centerRight),
      child: Text(
        label,
        style: TextStyle(
          color: currentTheme.textDisabled,
          fontSize: currentTheme.fontSize - 3,
        ),
      ),
    );
  }

  displayButtons(BuildContext context, StateSetter setState,
      BaseTheme currentTheme, double height) {
    var appLocalizations = AppLocalizations.of(context);
    return SizedBox(
      height: 170,
      child: BottomAppBar(
        color: currentTheme.primary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
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
                    var appLocalizations = AppLocalizations.of(context);
                    // bool? result = await ListRepChange().show(context,
                    //     currentTheme, appLocalizations, repList, account);
                    setState(() {
                      if (messageController.text == "") {
                        errMsg = appLocalizations!.signPageErrorMessage;
                      }
                      //else iff addr null
                      //else if sign null

                      else {
                        verifyMessage(context, setState);
                      }
                    });
                  },
                  child: Text(
                    appLocalizations!.verifyButtonText,
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
                    // bool? result = await ManualRepChange().show(
                    //     context,
                    //     currentTheme,
                    //     height,
                    //     AppLocalizations.of(context),
                    //     account);
                    setState(() {
                      clear();
                      Navigator.of(context).pop(true);
                    });
                  },
                  child: Text(
                    appLocalizations.close,
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

  String errMsg = '';
  // Timer t = Timer(const Duration(seconds: 1), () {});

  verifyMessage(BuildContext context, StateSetter setState) {
    try {
      String messageToBeChecked = messageController.text;
      String givenAddr = addressController.text;
      // 'ban_1fcyrps8j5uokeah34ud531nuu9wkqrb9xkkadk8qinefx11c6oxeia5utbk';
      String extractedKey = NanoAccounts.extractPublicKey(givenAddr);

      Uint8List extractedKeyBytes = NanoHelpers.hexToBytes(extractedKey);

      String givenSign = signController.text;
      Uint8List givenSignBytes = NanoHelpers.hexToBytes(givenSign);

      var blockBytes =
          Utils().getDumBlockHashBytes(extractedKeyBytes, messageToBeChecked);

      bool verify =
          Utils().detachedVerify(blockBytes, givenSignBytes, extractedKeyBytes);

      setState(() {
        signValid = verify;

        showResult = true;
      });
      // if (t.isActive) {
      //   t.cancel();
      // }
      // t = Timer(const Duration(seconds: 5000), () {
      //   setState(() {
      //     showResult = false;
      //   });
      // });
      // Future.delayed(const Duration(milliseconds: 5000), () {
      //   setState(() {
      //     showResult = false;
      //   });
      // });
    } catch (e) {
      print("verify message err");
      print(e);
    }
  }

  final messageController = TextEditingController();
  FocusNode messageControllerFocusNode = FocusNode();
  TextFormField messageTextField(
      BaseTheme currentTheme, BuildContext context, StateSetter setState) {
    return TextFormField(
      maxLines: 3,
      minLines: 1,
      textAlign: TextAlign.center,
      focusNode: messageControllerFocusNode,
      controller: messageController,
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
        hintText: AppLocalizations.of(context)!.enterMessageHint,
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: IconButton(
          splashRadius: 1,
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedText = cdata?.text ?? "";

            setState(() {
              messageController.text = copiedText;
            });
          },
          icon: const Icon(
            Icons.paste_outlined,
          ),
          color: currentTheme.textDisabled,
        ),

        prefixIcon: IconButton(
          splashRadius: 1,
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
                              if (result is String) {
                                messageController.text = result.text;

                                Navigator.of(context).pop();
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
      style: TextStyle(
        color: currentTheme.text,
        // fontFamily: 'monospace',
        fontSize: 13,
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          errMsg = '';
        }
        return null;
      },
    );
  }

  final addressController = TextEditingController();
  FocusNode addressControllerFocusNode = FocusNode();
  TextFormField addressTextField(
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
        suffixIcon: IconButton(
          splashRadius: 1,
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedText = cdata?.text ?? "";

            setState(() {
              addressController.text = copiedText;
            });
          },
          icon: const Icon(
            Icons.paste_outlined,
          ),
          color: currentTheme.textDisabled,
        ),
        prefixIcon: IconButton(
          splashRadius: 1,
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
                              if (result is String) {
                                messageController.text = result.text;

                                Navigator.of(context).pop();
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
      style: TextStyle(
        color: currentTheme.text,
        // fontFamily: 'monospace',
        fontSize: 13,
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          errMsg = '';
        }
        return null;
      },
    );
  }

  final signController = TextEditingController();
  FocusNode signControllerFocusNode = FocusNode();
  TextFormField signTextField(
      BaseTheme currentTheme, BuildContext context, StateSetter setState) {
    return TextFormField(
      maxLines: 3,
      minLines: 1,
      textAlign: TextAlign.center,
      focusNode: signControllerFocusNode,
      controller: signController,
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
        hintText: AppLocalizations.of(context)!.enterMessageHint,
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: IconButton(
          splashRadius: 1,
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedText = cdata?.text ?? "";

            setState(() {
              signController.text = copiedText;
            });
          },
          icon: const Icon(
            Icons.paste_outlined,
          ),
          color: currentTheme.textDisabled,
        ),
        prefixIcon: IconButton(
          splashRadius: 1,
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
                              if (result is String) {
                                signController.text = result.text;

                                Navigator.of(context).pop();
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
      style: TextStyle(
        color: currentTheme.text,
        // fontFamily: 'monospace',
        fontSize: 13,
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          errMsg = '';
        }
        return null;
      },
    );
  }

  clear() {
    showResult = false;
    selectedIndex = -1;
    messageController.clear();
    addressController.clear();
    signController.clear();
    errMsg = '';
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
