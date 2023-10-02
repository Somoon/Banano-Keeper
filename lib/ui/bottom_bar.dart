// import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bananokeeper/providers/user_data.dart';
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
        final LocalAuthentication auth = LocalAuthentication();
        var appLocalizations = AppLocalizations.of(context);
        // String activeAccountBalance = watchOnly((WalletsService x) => x
        //     .wallets[x.activeWallet]
        //     .accounts[x.wallets[x.activeWallet].getActiveIndex()]
        //     .getBalance());
        int walletIndex = services<WalletsService>().activeWallet;
        String walletName = services<WalletsService>().walletsList[walletIndex];

        int accountIndex =
            services<WalletService>(instanceName: walletName).activeIndex;

        String accOrgName = services<WalletService>(instanceName: walletName)
            .accountsList[accountIndex];

        String activeAccountBalance =
            watchOnly((Account x) => x.getBalance(), instanceName: accOrgName);

        String userCurrency = watchOnly((UserData x) => x.currency);

        bool? sent = false;
        sent = await showModalBottomSheet(
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
                services<QueueService>().add(account.getOverview(true));
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
                                          amountController.clear();
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
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Column(
                                children: [
                                  AutoSizeText(
                                    AppLocalizations.of(context)!.send,
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
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25, right: 25),
                                    child: Utils().colorffix(
                                        account.address, currentTheme),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Utils().formatBalance(activeAccountBalance,
                                      currentTheme, userCurrency),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  sendAddressTextField(currentTheme, context),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  sendAmountTextField(
                                      account, currentTheme, context),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  createSendButton(account, currentTheme,
                                      appLocalizations, width),
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
          },
        );
        addressController.clear();
        amountController.clear();
        // if (sent) {
        //   await account.onRefreshUpdateHistory();
        //   await account.getOverview(true);
        //   await account.handleOverviewResponse(true);
        // }
        // sent = false;
        setState(() {
          update = !update;
        });
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

  bool update = false;
  TextButton receiveTextButton(BaseTheme currentTheme, BuildContext context,
      double height, double width, Account account) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: currentTheme.text,
        backgroundColor: currentTheme.primary,
        elevation: 5,
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
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: currentTheme.primary,
              ),
              // color: currentTheme.primary,
              child: SizedBox(
                height: height / 1.55,
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

  Widget createSendButton(
      Account account, currentTheme, appLocalizations, width) {
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
          if (amountController.text != "" &&
              NanoAccounts.isValid(
                  NanoAccountType.BANANO, addressController.text)) {
            Decimal amount = Decimal.parse(amountController.text);

            Decimal maxAmount = Utils().amountFromRaw(account.getBalance());
            if ((amount > Decimal.parse("0") && amount <= maxAmount)) {
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
                    .authenticate(appLocalizations.authMsgWalletDel);
              }

              if (verified) {
                LoadingIndicatorDialog().show(context,
                    text: AppLocalizations.of(context)!.loadingWidgetSendMsg);

                await services<QueueService>().add(account.getOverview(true));
                await services<QueueService>()
                    .add(account.handleOverviewResponse(true));

                String sendAmountRaw =
                    Utils().rawFromAmount(amountController.text);
                String destAddress = addressController.text;
                var hist = await AccountAPI().getHistory(account.address, 1);
                var historyData = jsonDecode(hist.body);
                String previous = historyData[0]['hash'];

                var newRaw = (BigInt.parse(account.getBalance()) -
                        BigInt.parse(sendAmountRaw))
                    .toString();

                int accountType = NanoAccountType.BANANO;
                String calculatedHash = NanoBlocks.computeStateHash(
                    accountType,
                    account.address,
                    previous,
                    account.representative,
                    BigInt.parse(newRaw),
                    destAddress);
                int activeWallet = services<WalletsService>().activeWallet;
                String walletName =
                    services<WalletsService>().walletsList[activeWallet];

                String privateKey =
                    services<WalletService>(instanceName: walletName)
                        .getPrivateKey(account.index);
                // Signing a block
                String sign =
                    NanoSignatures.signBlock(calculatedHash, privateKey);

                StateBlock sendBlock = StateBlock(account.address, previous,
                    account.representative, newRaw, destAddress, sign);

                var sendHash = await AccountAPI()
                    .processRequest(sendBlock.toJson(), "send");

                // Close the dialog programmatically
                // We use "mounted" variable to get rid of the "Do not use BuildContexts across async gaps" warning
                LoadingIndicatorDialog().dismiss();

                //if
                //{"error":"Invalid block balance for given subtype"}
                //else v
                if (jsonDecode(sendHash)['hash'] != null &&
                    NanoHelpers.isHexString(jsonDecode(sendHash)['hash'])) {
                  await account.setBalance(newRaw);
                  await services<QueueService>()
                      .add(account.onRefreshUpdateHistory());
                } else {
                  //ERR?
                  if (kDebugMode) {
                    print(sendHash);
                  }
                }

                setState(() {
                  amountController.clear();
                  addressController.clear();
                  Navigator.of(context).pop(true);
                });
              }
            }
          }
        },
        child: AutoSizeText(
          AppLocalizations.of(context)!.send,
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
                addressController.text = data['address'];
              }
              if (data['amountRaw'] != "") {
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
                appLocalizations!.qrNotSupported,
                style: TextStyle(
                  color: currentTheme.textDisabled,
                ),
              ),
            );
            scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
          }
        },
        child: AutoSizeText(
          appLocalizations!.scanQRCode,
          style: TextStyle(
            color: currentTheme.text,
            fontSize: currentTheme.fontSize,
          ),
        ),
      ),
    );
  }

  TextFormField sendAmountTextField(
      Account account, BaseTheme currentTheme, BuildContext context) {
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
          // left: 8,
          right: 8,
        ),
        hintText: AppLocalizations.of(context)!.enterAmountHint,
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          // width: 15,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(15, 35),
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
              Decimal? isNum;
              ClipboardData? cdata =
                  await Clipboard.getData(Clipboard.kTextPlain);
              try {
                isNum = Decimal.parse(cdata?.text ?? "");
              } catch (_) {}

              setState(() {
                if (isNum != null) {
                  amountController.text = isNum.toString();
                }
              });
            },
          ),
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
              AppLocalizations.of(context)!.maxAmountIcon,
              maxLines: 1,
              style: TextStyle(
                color: currentTheme.text,
              ),
              maxFontSize: 10,
              minFontSize: 7,
            ),
            onPressed: () {
              setState(() {
                amountController.text =
                    Utils().amountFromRaw(account.getBalance()).toString();
              });
            },
          ),
        ),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value != null) {
          Decimal? valueInt = Decimal.tryParse(value);

          try {
            if (valueInt != null) {
              var maxAmount = Utils().amountFromRaw(account.getBalance());
              if (valueInt == Decimal.parse("0")) {
                validAmount = false;
                return AppLocalizations.of(context)!.amountFieldErrZero;
              }
              if (valueInt < Decimal.parse("0")) {
                validAmount = false;
                return AppLocalizations.of(context)!.amountFieldErrNegative;
              }
              if (valueInt > maxAmount) {
                validAmount = false;
                return AppLocalizations.of(context)!.amountFieldErrMore;
              }

              setState(() {
                validAmount = true;
              });
            }
          } catch (_) {}
        }
        validAmount = false;
        return null;
      },
      style: TextStyle(color: currentTheme.text),
    );
  }

  TextFormField sendAddressTextField(
      BaseTheme currentTheme, BuildContext context) {
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
        hintText: AppLocalizations.of(context)!.enterAddressHint,
        hintStyle: TextStyle(color: currentTheme.textDisabled),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // hintText: tempName, //activeWalletName,
        // hintStyle:
        //     TextStyle(color: currentTheme.textDisabled),

        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          // width: 15,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(15, 35),
              backgroundColor: currentTheme.primaryBottomBar,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Icon(
              size: 18,
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
          if (value.length >= 64) {
            if (NanoAccounts.isValid(NanoAccountType.BANANO, value)) {
              validAddr = true;
            } else {
              validAddr = false;
              return AppLocalizations.of(context)!.addressFieldErrAddr;
            }
          }
        }
        validAddr = false;
        return null;
      },
      style: TextStyle(
        color: currentTheme.text,
        fontFamily: 'monospace',
        fontSize: 13,
      ),
    );
  }
}

////////////////////////////////////
