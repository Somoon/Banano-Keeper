// import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/send/send_menu_1.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nanodart/nanodart.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:bananokeeper/themes.dart';
import 'dart:io';

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
    var account = watchOnly((WalletsService x) => x.wallets[x.activeWallet]
        .accounts[x.wallets[x.activeWallet].getActiveIndex()]);

    // double height = MediaQuery.of(context).size.height;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: BottomAppBar(
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
            )),
      ),
    );
  }

  TextButton sendTextButton(BaseTheme currentTheme, BuildContext context,
      double height, double width, Account account) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: currentTheme.text,
          backgroundColor: currentTheme.primary // foreground
          ),
      onPressed: () async {
        final LocalAuthentication auth = LocalAuthentication();
        var appLocalizations = AppLocalizations.of(context);
        num activeAccountBalance = watchOnly((WalletsService x) => x
            .wallets[x.activeWallet]
            .accounts[x.wallets[x.activeWallet].getActiveIndex()]
            .getBalance());
        showModalBottomSheet<void>(
          enableDrag: true,
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: currentTheme.primary,
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentTheme.primary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                    Navigator.of(context).pop(context);
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
                                "Send",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: currentTheme.text,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              AutoSizeText(
                                account.name,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: currentTheme.text,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 25, right: 25),
                                child: Utils()
                                    .colorffix(account.address, currentTheme),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Utils().formatBalance(
                                  activeAccountBalance, currentTheme),
                              const SizedBox(
                                height: 20,
                              ),
                              sendAddressTextField(currentTheme),
                              const SizedBox(
                                height: 20,
                              ),
                              sendAmountTextField(currentTheme),
                              const SizedBox(
                                height: 40,
                              ),
                              createSendButton(
                                  currentTheme, appLocalizations, width),
                              const SizedBox(
                                height: 10,
                              ),
                              createQRButton(
                                  currentTheme, appLocalizations, width),
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
          backgroundColor: currentTheme.primary // foreground
          ),
      onPressed: () async {
        final LocalAuthentication auth = LocalAuthentication();
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
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentTheme.primary,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
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
                                  Navigator.of(context).pop(context);
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
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Utils()
                                  .colorffix(account.address, currentTheme),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            QrImageView(
                              data: account.address,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: currentTheme.textDisabled,
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              height: 48,
                              width: width - 40,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateColor.resolveWith(
                                      (states) =>
                                          currentTheme.text.withOpacity(0.3)),
                                  // backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                                  Clipboard.setData(
                                    ClipboardData(text: account.address),
                                  );
                                  setState(() {});
                                },
                                child: AutoSizeText(
                                  "Copy address",
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

  Widget createSendButton(currentTheme, appLocalizations, width) {
    return SizedBox(
      height: 48,
      width: width - 40,
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
          if (addressController.text.length > 1 &&
              amountController.text.length > 1) {}
        },
        child: AutoSizeText(
          "Send",
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  Widget createQRButton(currentTheme, appLocalizations, width) {
    return SizedBox(
      height: 48,
      width: width - 40,
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
                          resolutionPreset: QRCodeDartScanResolutionPreset.high,
                          onCapture: (Result result) async {
                            // print(result.text);

                            Navigator.of(context).pop(result.text);
                          },
                        ),
                        QRScannerOverlay(
                          overlayColor: Colors.black.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                ));
            var data = await Utils().getQRCodeData(res);

            setState(() {
              if (data['address'] != "") {
                print("address ${data['address']}");
                addressController.text = data['address'];
              }
              if (data['amountRaw'] != "") {
                print(
                    "amount ${data['amountRaw']} -> ${Utils().amountFromRaw(data['amountRaw'])}");
                amountController.text =
                    Utils().amountFromRaw(data['amountRaw']).toString();
              }
              // if (res is String) {

              // importSeedTextController.text = res;
              // }
            });
          } else {
            var snackBar = SnackBar(
              content: Text(
                'QR Scan is not supported on windows.',
                style: TextStyle(
                  color: currentTheme.textDisabled,
                ),
              ),
            );
            scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
          }
        },
        child: AutoSizeText(
          "Scan QR Code",
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  TextFormField sendAmountTextField(BaseTheme currentTheme) {
    return TextFormField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      focusNode: amountControllerFocusNode,
      controller: amountController,
      autofocus: false,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: currentTheme.secondary,
        isDense: true,
        isCollapsed: true,
        contentPadding: const EdgeInsets.only(
          left: 8,
          right: 8,
        ),
        hintText: "Enter Amount",
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(15, 30),
            backgroundColor: currentTheme.primaryBottomBar,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Icon(
            Icons.paste_outlined,
            color: currentTheme.text,
          ),
          onPressed: () async {
            ClipboardData? cdata =
                await Clipboard.getData(Clipboard.kTextPlain);
            String copiedText = cdata?.text ?? "";
            bool isCorrectHex =
                NanoAccounts.isValid(NanoAccountType.BANANO, copiedText);

            setState(() {
              if (isCorrectHex) {
                amountController.text = copiedText;
              }
            });
          },
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(10, 30),
              backgroundColor: currentTheme.primaryBottomBar,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: AutoSizeText(
              "MAX",
              maxLines: 1,
              style: TextStyle(
                color: currentTheme.text,
              ),
              maxFontSize: 10,
              minFontSize: 7,
            ),
            onPressed: () async {
              ClipboardData? cdata =
                  await Clipboard.getData(Clipboard.kTextPlain);
              String copiedText = cdata?.text ?? "";
              bool isCorrectHex =
                  NanoAccounts.isValid(NanoAccountType.BANANO, copiedText);

              setState(() {
                if (isCorrectHex) {
                  addressController.text = copiedText;
                }
              });
            },
          ),
        ),
      ),
      // autovalidateMode: AutovalidateMode.always,
      // validator: (value) {
      //   return value!.length > 64
      //       ? 'Wallet name length can be up to 20 characters.'
      //       : null;
      // },
      style: TextStyle(color: currentTheme.text),
    );
  }

  TextFormField sendAddressTextField(BaseTheme currentTheme) {
    return TextFormField(
      maxLines: 2,
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
        contentPadding: const EdgeInsets.only(
          left: 8,
          right: 8,
        ),
        hintText: "Enter Address",
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(15, 30),
              backgroundColor: currentTheme.primaryBottomBar,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Icon(
              Icons.paste_outlined,
              color: currentTheme.text,
            ),
            onPressed: () async {
              ClipboardData? cdata =
                  await Clipboard.getData(Clipboard.kTextPlain);
              String copiedText = cdata?.text ?? "";
              bool isCorrectHex =
                  NanoAccounts.isValid(NanoAccountType.BANANO, copiedText);

              setState(() {
                if (isCorrectHex) {
                  addressController.text = copiedText;
                }
              });
            },
          ),
        ),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          if (NanoAccounts.isValid(NanoAccountType.BANANO, value)) {
            if (value.length != 64) {
              return 'Wallet name length can be up to 20 characters.';
            }
          }
        }

        return null;
      },
      style: TextStyle(color: currentTheme.text),
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
