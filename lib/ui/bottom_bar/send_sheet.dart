import 'dart:convert';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nanodart/nanodart.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'dart:io';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

// @RoutePage<bool>(name: "SendRoute")
class SendBottomSheet {
  static final SendBottomSheet _singleton = SendBottomSheet._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  int selectedIndex = -1;
  bool showSign = false;
  final addressController = TextEditingController();
  FocusNode addressControllerFocusNode = FocusNode();
  final amountController = TextEditingController();
  FocusNode amountControllerFocusNode = FocusNode();

  bool validAddr = false;
  bool validAmount = false;

  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  factory SendBottomSheet() {
    return _singleton;
  }

  SendBottomSheet._internal();

  Future<bool?> show(BuildContext context, BaseTheme currentTheme,
      appLocalizations, Account account) async {
    if (isDisplayed) {
      return false;
    }
    _context = context;

    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    isDisplayed = true;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    //Wallet and address

    final LocalAuthentication auth = LocalAuthentication();
    var appLocalizations = AppLocalizations.of(context);

    int walletIndex = services<WalletsService>().activeWallet;
    String walletName = services<WalletsService>().walletsList[walletIndex];

    int accountIndex =
        services<WalletService>(instanceName: walletName).activeIndex;

    String accOrgName = services<WalletService>(instanceName: walletName)
        .accountsList[accountIndex];

    return await showModalBottomSheet(
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
            String activeAccountBalance =
                services<Account>(instanceName: accOrgName).getBalance();

            String userCurrency = services<UserData>().currency;
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
                                      Navigator.of(context).pop();
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
                                padding:
                                    const EdgeInsets.only(left: 25, right: 25),
                                child: Utils()
                                    .colorffix(account.address, currentTheme),
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
    // addressController.clear();
    // amountController.clear();

    /////////////////////////
    // if (sent) {
    //   await account.onRefreshUpdateHistory();
    //   await account.getOverview(true);
    //   await account.handleOverviewResponse(true);
    // }
    // sent = false;
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
              bool? verified = false;

              if (!canauth) {
                verified =
                    await services<AppRouter>().push<bool>(VerifyPINRoute());
              } else {
                verified = await BiometricUtil()
                    .authenticate(appLocalizations.authMsgWalletDel);
              }

              if (verified != null && verified) {
                LoadingIndicatorDialog().show(_context,
                    text: AppLocalizations.of(_context)!.loadingWidgetSendMsg,
                    theme: currentTheme);

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

                var sendHash =
                    await AccountAPI().processRequest(sendBlock, "send");
                FocusScope.of(_context).unfocus();
                LoadingIndicatorDialog().dismiss();

                //if
                //{"error":"Invalid block balance for given subtype"}
                //else
                if (jsonDecode(sendHash)['hash'] != null &&
                    NanoHelpers.isHexString(jsonDecode(sendHash)['hash'])) {
                  await account.setBalance(newRaw);
                  await services<QueueService>()
                      .add(account.onRefreshUpdateHistory());

                  //have wallet walletName
                  //need accountOrgName

                  int accountIndex =
                      services<WalletService>(instanceName: walletName)
                          .activeIndex;
                  String accountOrgName =
                      services<WalletService>(instanceName: walletName)
                          .accountsList[accountIndex];
                  var account2 =
                      services<Account>(instanceName: accountOrgName);
                  await account2.setBalance(newRaw);
                  await services<QueueService>()
                      .add(account2.onRefreshUpdateHistory());

                  amountController.clear();
                  addressController.clear();
                  Navigator.of(_context).pop(true);
                } else {
                  //ERR?
                  if (kDebugMode) {
                    print(sendHash);
                  }
                }

                // setState(() {

                //   Navigator.of(context).pop(true);
                // });
              }
            }
          }
        },
        child: AutoSizeText(
          AppLocalizations.of(_context)!.send,
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
                _context,
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

            // setState(() {?
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
            // });/
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

              // setState(() {
              if (isNum != null) {
                amountController.text = isNum.toString();
              }
              // });
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
              // setState(() {
              amountController.text =
                  Utils().amountFromRaw(account.getBalance()).toString();
              // });
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

              // setState(() {
              validAmount = true;
              // });
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

              // setState(() {
              if (isCorrectHex) {
                addressController.text = copiedText;
              }
              // });
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

  clear() {
    addressController.clear();
    // addressControllerFocusNode.clear();
    amountController.clear();
    // amountControllerFocusNode.dispose();
    isDisplayed = false;
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
