// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:nanodart/nanodart.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

class ImportWalletPage extends StatefulWidget with GetItStatefulWidgetMixin {
  // ManagementPage({super.key});

  @override
  ImportWalletPageState createState() => ImportWalletPageState();

  ImportWalletPage({super.key});
}

class ImportWalletPageState extends State<ImportWalletPage>
    with GetItStateMixin {
  final importSeedTextController = TextEditingController();
  final importMnemonicTextController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode ControllerFocusNode = FocusNode();
  FocusNode ControllerFocusNode2 = FocusNode();

  bool mnemonicIsValid = true;
  List<String> wordsErr = [];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    importSeedTextController.dispose();
    importMnemonicTextController.dispose();
    ControllerFocusNode.dispose();
    ControllerFocusNode2.dispose();
    super.dispose();
  }

  bool importState = true;

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var primary = watchOnly((ThemeModel x) => x.curTheme.primary);
    var secondary = watchOnly((ThemeModel x) => x.curTheme.secondary);
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;
    var appLocalizations = AppLocalizations.of(context);
    return SafeArea(
      minimum: EdgeInsets.only(
        top: (statusBarHeight == 0.0 ? 50 : statusBarHeight),
      ),
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: primary,
            appBar: AppBar(
              backgroundColor: secondary,
              elevation: 0.0,
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      importState = !importState;
                    });
                  },
                  // splashColor: currentTheme.text,
                  // color: currentTheme.text,
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => currentTheme.text.withOpacity(0.3)),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(currentTheme.text),
                  ),
                  child:
                      (importState ? Icon(Icons.abc_sharp) : Icon(Icons.key)),
                ),
              ],
              titleSpacing: 10.0,
              title: Text(
                (importState
                    ? appLocalizations!.importWalletTitle(appLocalizations.seed)
                    : appLocalizations!
                        .importWalletTitle(appLocalizations.mnemonicPhrase)),
                style: TextStyle(
                  color: currentTheme.text,
                  // fontSize: currentTheme.fontSize,
                ),
              ),
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: currentTheme.text,
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                color: currentTheme.primary,
              ),
              child:
                  (importState ? importSeed(context) : importMnemonic(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget importSeed(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 40),
      child: Column(
        children: [
          Text(
            appLocalizations!.enterSeed,
            style: currentTheme.textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////
          seedTextField(currentTheme),

          SizedBox(
            height: 10,
          ),

          SizedBox(
            width: 90,
            child: ElevatedButton.icon(
              onPressed: () {
                if (NanoSeeds.isValidSeed(importSeedTextController.text)) {
                  // String walletName = watchOnly((WalletsService x) =>
                  //     x.wallets[x.activeWallet].getName());
                  // var snackBar = SnackBar(
                  //   content: Text(
                  //     'Imported Wallet: $walletName',
                  //     style: TextStyle(
                  //       color: currentTheme.textDisabled,
                  //     ),
                  //   ),
                  // );

                  createWallet(importSeedTextController.text);
                  importSeedTextController.clear();

                  // scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
                }
              },
              icon: Text(
                appLocalizations.import,
              ),
              label: Icon(Icons.navigate_next),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentTheme.primaryBottomBar,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  createWallet(String seed) async {
    await services<WalletsService>().createNewWallet(seed);
    setState(() {});
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  TextFormField seedTextField(BaseTheme currentTheme) {
    var appLocalizations = AppLocalizations.of(context);
    return TextFormField(
      maxLines: null,
      focusNode: ControllerFocusNode,
      controller: importSeedTextController,
      autofocus: false,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        labelStyle: TextStyle(
            color: ControllerFocusNode.hasFocus
                ? currentTheme.textDisabled
                : currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: currentTheme.buttonOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: currentTheme.buttonOutline),
        ),
        suffixIcon: IconButton(
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedtext = cdata?.text ?? "";
            bool isCorrectHex = NanoSeeds.isValidSeed(copiedtext);

            setState(() {
              if (isCorrectHex) {
                importSeedTextController.text = copiedtext;
              }
            });
          },
          icon: Icon(Icons.paste_outlined),
          color: currentTheme.textDisabled,
        ),

        prefixIcon: IconButton(
          onPressed: () async {
            if (!Platform.isWindows) {
              var res = await Navigator.push(
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
                              importSeedTextController.text = result.text;
                              Navigator.of(context).pop();
                            },
                          ),
                          QRScannerOverlay(
                            overlayColor: Colors.black.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ));
              setState(() {
                if (res is String) {
                  importSeedTextController.text = res;
                }
              });
            } else {
              var snackBar = SnackBar(
                content: Text(
                  appLocalizations!.qrNotSupported,
                  style: TextStyle(
                    color: currentTheme.textDisabled,
                  ),
                ),
              );
              scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
            }
          },
          icon: Icon(Icons.qr_code_scanner_rounded),
          color: currentTheme.textDisabled,
        ),

        // Container(
        // margin: EdgeInsets.all(8),
        // child:
        // ),ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     minimumSize: Size(45, 40),
        //     backgroundColor: currentTheme.primaryBottomBar,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(30.0),
        //     ),
        //   ),
        //   child: Icon(Icons.paste_outlined),
        //   onPressed: () {
        //
        //   },
        // ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value!.isNotEmpty) {
          bool isCorrectHex = NanoSeeds.isValidSeed(value);

          if (!isCorrectHex) {
            return appLocalizations!.invalidSeed;
          }

          return value.length > 64 ? appLocalizations!.invalidSeedLength : null;
        }
        return null;
      },
      onChanged: (text) {
        if (text.length == 64) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      inputFormatters: [
        LengthLimitingTextInputFormatter(64),
        UppercaseInputFormatter()
      ],
      style: TextStyle(
        color: currentTheme.text,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget importMnemonic(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 40),
      child: Column(
        children: [
          Text(
            appLocalizations!.enter24Words,
            style: currentTheme.textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////
          MnemonicTextField(currentTheme),

          SizedBox(
            height: 10,
          ),

          SizedBox(
            width: 90,
            child: ElevatedButton.icon(
              onPressed: () {
                bool is24Words =
                    (importMnemonicTextController.text.split(' ').length == 24);

                if (is24Words) {
                  importMnemonicTextController.text.split(' ').forEach((word) {
                    if (!NanoMnemomics.isValidWord(word)) {
                      wordsErr.add(word);
                    }
                  });
                  if (wordsErr.isNotEmpty) {
                    setState(() {
                      wordsErr.insert(
                          0, "${appLocalizations.incorrectWords}\n ");
                      mnemonicIsValid = false;
                    });
                  } else {
                    String seed = NanoMnemomics.mnemonicListToSeed(
                        importMnemonicTextController.text.split(' '));

                    createWallet(seed);
                    importMnemonicTextController.clear();
                  }

                  // String walletName = watchOnly((WalletsService x) =>
                  //     x.wallets[x.activeWallet].getName());
                  // var snackBar = SnackBar(
                  //   content: Text(
                  //     'Imported Wallet: $walletName',
                  //     style: TextStyle(
                  //       color: currentTheme.textDisabled,
                  //     ),
                  //   ),
                  // );

                  // scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
                } else {
                  setState(() {
                    mnemonicIsValid = false;
                    wordsErr.clear();
                    wordsErr.add(appLocalizations.not24Words);
                  });
                }
              },
              icon: Text(appLocalizations.import),
              label: Icon(Icons.navigate_next),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentTheme.primaryBottomBar,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          AutoSizeText(
            (mnemonicIsValid ? "" : wordsErr.join(" ")),
            style: TextStyle(
              color: currentTheme.red,
              fontSize: currentTheme.fontSize,
            ),
          ),
          /////////////////////
        ],
      ),
    );
  }

  TextFormField MnemonicTextField(BaseTheme currentTheme) {
    var appLocalizations = AppLocalizations.of(context);
    return TextFormField(
      maxLines: null,
      focusNode: ControllerFocusNode2,
      controller: importMnemonicTextController,
      autofocus: false,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        labelStyle: TextStyle(
            color: ControllerFocusNode2.hasFocus
                ? currentTheme.textDisabled
                : currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: currentTheme.buttonOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: currentTheme.buttonOutline),
        ),
        suffixIcon: IconButton(
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedtext = cdata?.text ?? "";
            // bool isCorrectHex = NanoSeeds.isValidSeed(copiedtext);

            setState(() {
              importMnemonicTextController.text = copiedtext;
            });
          },
          icon: Icon(Icons.paste_outlined),
          color: currentTheme.textDisabled,
        ),

        prefixIcon: IconButton(
          onPressed: () async {
            if (!Platform.isWindows) {
              var res = await Navigator.push(
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
                              importMnemonicTextController.text = result.text;
                              Navigator.of(context).pop();
                            },
                          ),
                          QRScannerOverlay(
                            overlayColor: Colors.black.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ));
              setState(() {
                if (res is String) {
                  importMnemonicTextController.text = res;
                }
              });
            } else {
              var snackBar = SnackBar(
                content: Text(
                  appLocalizations!.qrNotSupported,
                  style: TextStyle(
                    color: currentTheme.textDisabled,
                  ),
                ),
              );
              scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
            }
          },
          icon: Icon(Icons.qr_code_scanner_rounded),
          color: currentTheme.textDisabled,
        ),

        // Container(
        // margin: EdgeInsets.all(8),
        // child:
        // ),ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     minimumSize: Size(45, 40),
        //     backgroundColor: currentTheme.primaryBottomBar,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(30.0),
        //     ),
        //   ),
        //   child: Icon(Icons.paste_outlined),
        //   onPressed: () {
        //
        //   },
        // ),
      ),
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      // validator: (value) {
      //   if (value!.isNotEmpty) {
      //     bool isCorrectHex = NanoSeeds.isValidSeed(value);
      //     print('isCorrectHex? $isCorrectHex');
      //     if (!isCorrectHex) {
      //       return 'Invalid seed';
      //     }
      //
      //     // return NanoMnemomics.validateMnemonic(value!.split(' '))
      //     //     ? 'Mnemonic length cannot be longer than 64 characters'
      //     //     : null;
      //   }
      //   return null;
      // },
      onChanged: (text) {
        setState(() {
          mnemonicIsValid = true;
          wordsErr.clear();
        });
        //   if (text.length == 64) {
        //     FocusManager.instance.primaryFocus?.unfocus();
        //   }
      },
      // inputFormatters: [
      // LengthLimitingTextInputFormatter(64),
      // UppercaseInputFormatter()
      // ],
      style: TextStyle(
        color: currentTheme.text,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class UppercaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
