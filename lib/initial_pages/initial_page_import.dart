// ignore_for_file: prefer_const_constructors
import 'dart:ui';
import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/ui/management/import_wallet.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/db/dbManager.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nanodart/nanodart.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

@RoutePage(name: "InitialPageImportRoute")
class InitialPageImport extends StatefulWidget with GetItStatefulWidgetMixin {
  InitialPageImport({super.key});

  @override
  InitialPageImportState createState() => InitialPageImportState();
}

class InitialPageImportState extends State<InitialPageImport>
    with GetItStateMixin {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final importSeedTextController = TextEditingController();
  final importMnemonicTextController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode ControllerFocusNode = FocusNode();
  FocusNode ControllerFocusNode2 = FocusNode();
  bool importState = true;
  bool mnemonicIsValid = true;
  List<String> wordsErr = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    importSeedTextController.dispose();
    importMnemonicTextController.dispose();
    ControllerFocusNode.dispose();
    ControllerFocusNode2.dispose();
    super.dispose();
  }

  bool isCheckedNewWallet = false;
  bool createStateNewWallet = true;
  String seed = Utils().generateSeed();

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalizations = AppLocalizations.of(context);

    return SafeArea(
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: currentTheme.primaryAppBar,
              automaticallyImplyLeading: false,
              centerTitle: true,
              titleSpacing: 10.0,
              titleTextStyle: currentTheme.textStyle,
              title: AutoSizeText(
                (importState
                    ? appLocalizations!.importWalletTitle(appLocalizations.seed)
                    : appLocalizations!
                        .importWalletTitle(appLocalizations.mnemonicPhrase)),
                maxLines: 1,
              ),
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
            ),
            body: Container(
              decoration: BoxDecoration(
                color: currentTheme.primary,
              ),
              child:
                  (importState ? importSeed(context) : importMnemonic(context)),
            ),
            bottomNavigationBar: Container(
              color: currentTheme.primary,
              width: double.infinity,
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => currentTheme.text.withOpacity(0.3)),
                    ),
                    onPressed: () {
                      services<WalletsService>().deleteWallet(0);
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      appLocalizations.back,
                      style: TextStyle(
                        color: currentTheme.text,
                        fontSize: currentTheme.fontSize,
                      ),
                    ),
                  ),
                  /////////////////////////////////////////

                  if (importState) ...[
                    importSeedButton(currentTheme, appLocalizations),
                  ] else ...[
                    importMnemonicButton(currentTheme, appLocalizations),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return currentTheme.text;
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
        ],
      ),
    );
  }

  SizedBox importSeedButton(BaseTheme currentTheme, appLocalizations) {
    return SizedBox(
      width: 90,
      child: TextButton(
        onPressed: () async {
          if (NanoSeeds.isValidSeed(importSeedTextController.text)) {
            bool? ok = await services<AppRouter>()
                .push(SetupPinRoute(nextPage: 'initial'));

            if (ok != null && ok) {
              services<WalletsService>().setLatestWalletID(0);

              await services<WalletsService>()
                  .createNewWallet(importSeedTextController.text);
              // importSeedTextController.clear();
              await services<WalletsService>().setActiveWallet(0);

              String walletName = services<WalletsService>().walletsList[0];

              services<WalletService>(instanceName: walletName)
                  .setActiveIndex(0);
              services<SharedPrefsModel>().initliazeValues();
              setState(() {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => SetupPin("initial"),
                //   ),
                // );
              });
            }
          }
        },
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => currentTheme.text.withOpacity(0.3)),
        ),
        child: Text(
          appLocalizations.next,
          style: TextStyle(
            color: (isCheckedNewWallet
                ? currentTheme.text
                : currentTheme.textDisabled),
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  TextFormField seedTextField(BaseTheme currentTheme) {
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
                isCheckedNewWallet = true;
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
                  AppLocalizations.of(context)!.qrNotSupported,
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
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value!.length >= 64) {
          if (value.isNotEmpty) {
            bool isCorrectHex = NanoSeeds.isValidSeed(value);
            print('isCorrectHex? $isCorrectHex');
            if (!isCorrectHex) {
              return AppLocalizations.of(context)!.invalidSeed;
            }
            isCheckedNewWallet = true;
            return value.length > 64
                ? AppLocalizations.of(context)!.invalidSeedLength
                : null;
          }
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

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 40),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.enter24Words,
            style: currentTheme.textStyle,
          ),
          SizedBox(
            height: 10,
          ),
          ///////////////////////////
          mnemonicTextField(currentTheme),

          SizedBox(
            height: 10,
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

  SizedBox importMnemonicButton(BaseTheme currentTheme, appLocalizations) {
    return SizedBox(
      width: 90,
      child: TextButton(
        onPressed: () async {
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
                    0, "${AppLocalizations.of(context)!.incorrectWords} \n ");
                mnemonicIsValid = false;
              });
            } else {
              String seed = NanoMnemomics.mnemonicListToSeed(
                  importMnemonicTextController.text.split(' '));
              if (NanoSeeds.isValidSeed(seed)) {
                services<WalletsService>().setLatestWalletID(0);

                await services<WalletsService>().createNewWallet(seed);
                importMnemonicTextController.clear();
                services<WalletsService>().setActiveWallet(0);

                String walletName = services<WalletsService>().walletsList[0];

                services<WalletService>(instanceName: walletName)
                    .setActiveIndex(0);
                services<SharedPrefsModel>().initliazeValues();
                setState(() {
                  services<AppRouter>()
                      .push(SetupPinRoute(nextPage: 'initial'));
                });
              }
            }
          } else {
            setState(() {
              mnemonicIsValid = false;
              wordsErr.clear();
              wordsErr.add(AppLocalizations.of(context)!.not24Words);
            });
          }
        },
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
              (states) => currentTheme.text.withOpacity(0.3)),
        ),
        child: Text(
          appLocalizations.next,
          style: TextStyle(
            color: (isCheckedNewWallet
                ? currentTheme.text
                : currentTheme.textDisabled),
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  TextFormField mnemonicTextField(BaseTheme currentTheme) {
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
                  AppLocalizations.of(context)!.qrNotSupported,
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
          isCheckedNewWallet = true;
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
