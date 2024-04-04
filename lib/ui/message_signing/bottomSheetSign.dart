import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:auto_route/annotations.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/dialogs/info_dialog.dart';
import 'package:bananokeeper/ui/message_signing/message_sign_verification.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nanodart/nanodart.dart';
// import 'package:nanodart/src/crypto/tweetnacl_blake2b.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'dart:io';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

// @RoutePage<bool>(name: "MsgSignRoute")
class MsgSignPage {
  static final MsgSignPage _singleton = MsgSignPage._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  int selectedIndex = -1;
  bool showSign = false;
  Map<String, String?> deepLinkData = {};
  final ScrollController pageController = ScrollController();

  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  factory MsgSignPage() {
    return _singleton;
  }

  MsgSignPage._internal();

  Future<bool?> show(
    BuildContext context,
    BaseTheme currentTheme,
  ) async {
    if (isDisplayed) {
      return false;
    }
    _context = context;

    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    isDisplayed = true;
    double height = MediaQuery.of(context).size.height;

    //Wallet and address

    int walletIndex = services<WalletsService>().activeWallet;

    String orgWalletName = services<WalletsService>().walletsList[walletIndex];
    // String activeWalletName =
    //     services<WalletService>(instanceName: orgWalletName)
    //         .getWalletName();

    WalletService wallet = services<WalletService>(instanceName: orgWalletName);

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
              int accountIndex =
                  services<WalletService>(instanceName: orgWalletName)
                      .getActiveIndex();
              if (selectedIndex == -1) selectedIndex = accountIndex;

              String accOrgName = wallet.accountsList[selectedIndex];

              // String accountName =
              //     services<Account>(instanceName: accOrgName).getName();

              var account = services<Account>(instanceName: accOrgName);
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: GestureDetector(
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
                              child: ListView(
                                scrollDirection: Axis.vertical,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        height: 5,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                                            .messageSingingInfoDialogTitle,
                                                        AppLocalizations.of(
                                                                context)!
                                                            .messageSingingInfoDialogExplanation,
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
                                                    Navigator.of(context)
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
                                                  .messageSigningTitle,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: currentTheme.text,
                                              ),
                                            ),
                                            const Gap(40),
                                            createPopupMenuMethod(
                                                context,
                                                currentTheme,
                                                account,
                                                setState,
                                                wallet),
                                            const Gap(30),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 25.0,
                                                right: 25.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  messageTextField(currentTheme,
                                                      context, setState),
                                                  if (showSign) ...[
                                                    const Gap(30),
                                                    signTextField(currentTheme,
                                                        context, setState),
                                                  ]
                                                ],
                                              ),
                                            ),
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
                                ],
                              ),
                            ),
                            bottomNavigationBar: displayButtons(
                                context,
                                setState,
                                currentTheme,
                                height,
                                wallet,
                                account),
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

  Center createPopupMenuMethod(BuildContext context, BaseTheme currentTheme,
      Account account, StateSetter setState, WalletService wallet) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        //Center Row contents horizontally,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Idea: add shortcut to wallet page here?
          // IconButton(
          //   onPressed: (() {}),
          //   icon: const Icon(
          //     Icons.account_balance_wallet_outlined,
          //     color: Colors.white,
          //   ),
          // ),
          PopupMenuButton(
            splashRadius: 0,
            constraints: const BoxConstraints(maxHeight: 250),
            tooltip: AppLocalizations.of(context)!.selectAddressHint,
            // position: PopupMenuPosition.under,
            offset: const Offset(0, 50),
            color: currentTheme.primary,
            initialValue: account.getAddress(),
            // Callback that sets the selected popup menu item.
            onSelected: (item) {
              setState(() {
                selectedIndex = item;
              });
            },
            itemBuilder: (BuildContext context) =>
                createDropDownMenuItems(wallet, currentTheme),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                decoration: BoxDecoration(
                  color: currentTheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(
                  15.0,
                  10,
                  15,
                  10,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AutoSizeText(
                        Utils().shortenAccount(account.getAddress()),
                        maxLines: 3,
                        style: currentTheme.textStyle.copyWith(fontSize: 14.0),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: currentTheme.text,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry> createDropDownMenuItems(
      WalletService wallet, BaseTheme currentTheme) {
    // var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    // var wallet = watchOnly((WalletsService x) => x.wallets[x.activeWallet]);

    var ddmi = <PopupMenuEntry>[];
    for (int i = 0; i < wallet.accountsList.length; i++) {
      ddmi.add(PopupMenuItem(
        value: i,
        child: Text(
          services<Account>(instanceName: wallet.accountsList[i])
              .getAddress()
              .substring(0, 16),
          // wallet.accounts[i].getAddress().substring(0, 16),
          style: currentTheme.textStyle.copyWith(fontSize: 14.0),
        ),
      ));
    }
    return ddmi;
  }

  displayButtons(
      BuildContext context,
      StateSetter setState,
      BaseTheme currentTheme,
      double height,
      WalletService wallet,
      Account account) {
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
                      if (messageController.text != null &&
                          messageController.text != "") {
                        signMessage(
                            context, wallet, account, setState, currentTheme);
                      } else {
                        errMsg = appLocalizations!.signPageErrorMessage;
                      }
                    });
                  },
                  child: Text(
                    appLocalizations!.signButtonText,
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
                    bool? result = await MsgSignVerifyPage().show(
                      context,
                      currentTheme,
                    );
                    setState(() {});
                  },
                  child: Text(
                    appLocalizations.verifyButtonText,
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
  signMessage(BuildContext context, WalletService wallet, Account account,
      StateSetter setState, BaseTheme currentTheme) {
    String privateKey = wallet.getPrivateKey(account.index);

    //Message
    String message = messageController.text;

    var messageBytes = //NanoHelpers.hexToBytes(message);
        NanoHelpers.stringToBytesUtf8(message);
    // NanoSignatures.signBlock(calculatedHash, privateKey);
    Uint8List bananoMessagePreambleBytes =
        NanoHelpers.stringToBytesUtf8(Utils().bananoMessagePreamble);

    // TweetNaclFast.cryptoHashOff();
    Uint8List out = Uint8List(32);
    Blake2bDigest blake2b = Blake2bDigest(digestSize: 32);
    blake2b.update(
        bananoMessagePreambleBytes, 0, bananoMessagePreambleBytes.length);
    blake2b.update(messageBytes, 0, messageBytes.length);
    blake2b.doFinal(out, 0);

    String rep = NanoHelpers.byteToHex(out);

    String calculatedHash = Utils().getDummyBlockHash(
      account.address,
      rep, //rep empty
    );

    String sign = NanoSignatures.signBlock(calculatedHash, privateKey);

    signController.text = sign;

    showSign = true;

    if (deepLinkData['callback'] != null && deepLinkData['callback'] != '') {
      print('SEND  VERIFICATION');

      sendVerification(currentTheme);
      deepLinkData['callback'] = ""; //to avoid spam
    }

    setState(() {});
  }

  sendVerification(BaseTheme currentTheme) async {
    String cbURL = deepLinkData['callback']!;
    http.Response response;

    response = await http.put(
      Uri.parse(cbURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'signature': signController.text,
        'banano_address': deepLinkData['address'],
        'message': deepLinkData['message'],
      }),
    );

    if (response.statusCode == 200) {
      var rData = jsonDecode(response.body);
      String message = 'Message signature sent.';
      if (rData['success'] != null && rData['success']) {
        message = 'Message signature verified successfully';
      }

      EasyLoading.instance
        ..toastPosition = EasyLoadingToastPosition.center
        ..displayDuration = const Duration(seconds: 8)
        ..loadingStyle = EasyLoadingStyle.dark
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..backgroundColor = Colors.green
        ..indicatorColor = Colors.yellow
        ..textColor = Colors.yellow
        ..maskColor = Colors.blue.withOpacity(0.5)
        ..userInteractions = true
        ..dismissOnTap = true;
      EasyLoading.showSuccess(
        message,
      );
    }
    print('SENDER VERIFICATION');
    print(response.statusCode);
    print(response.body);
    // services<AppRouter>().pop(true);
  }

  final messageController = TextEditingController();
  FocusNode messageControllerFocusNode = FocusNode();
  ScrollController messageScrollController = ScrollController();

  Scrollbar messageTextField(
      BaseTheme currentTheme, BuildContext context, StateSetter setState) {
    return Scrollbar(
      controller: messageScrollController,
      interactive: true,
      child: TextFormField(
        scrollController: messageScrollController,
        maxLines: 5,
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
                              typeScan: TypeScan.live,
                              scanInvertedQRCode: true,
                              onCapture: (Result result) {
                                setState(() {
                                  try {
                                    if (result.text != "") {
                                      Uri? uri = Uri.tryParse(result.text);
                                      String? scheme = uri?.scheme;
                                      if (scheme == 'bansign') {
                                        Map<String, String?> data =
                                            uri!.queryParameters;

                                        messageController.text =
                                            data['message'] ?? "";

                                        deepLinkData['callback'] =
                                            data['url'] ?? "";
                                        deepLinkData['url'] = data['url'] ?? "";
                                        deepLinkData['address'] =
                                            data['address'] ?? "";

                                        Navigator.of(context).pop(true);
                                      }
                                    }
                                  } catch (_) {}
                                });
                              },
                            ),
                            QRScannerOverlay(
                              overlayColor: Colors.black.withOpacity(0.9),
                              scanAreaWidth: 250.0,
                              scanAreaHeight: 300.0,
                            ),
                          ],
                        ),
                      ),
                    ));
                // setState(() {});
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
      ),
    );
  }

  final signController = TextEditingController();
  TextFormField signTextField(
      BaseTheme currentTheme, BuildContext context, StateSetter setState) {
    return TextFormField(
      readOnly: true,
      maxLines: 4,
      minLines: 1,
      textAlign: TextAlign.center,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: IconButton(
          splashRadius: 1,
          onPressed: () async {
            setState(() {
              Clipboard.setData(
                ClipboardData(text: signController.text),
              );
            });
          },
          icon: const Icon(
            Icons.paste_outlined,
          ),
          color: currentTheme.textDisabled,
        ),
      ),
      style: TextStyle(
        color: currentTheme.text,
        // fontFamily: 'monospace',
        fontSize: 13,
      ),
    );
  }

  clear() {
    showSign = false;
    selectedIndex = -1;
    messageController.clear();
    signController.clear();
    errMsg = '';
    deepLinkData = {};
    isDisplayed = false;
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
