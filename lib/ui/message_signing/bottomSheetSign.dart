import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/dialogs/info_dialog.dart';
import 'package:bananokeeper/ui/representative_pages/list_rep_change.dart';
import 'package:bananokeeper/ui/representative_pages/manual_rep_change.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nanodart/nanodart.dart';
// import 'package:nanodart/src/crypto/tweetnacl_blake2b.dart';
import 'package:pointycastle/digests/blake2b.dart';
import 'dart:typed_data';

class MsgSignPage {
  static final MsgSignPage _singleton = MsgSignPage._internal();
  late BuildContext _context;
  bool isDisplayed = false;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  factory MsgSignPage() {
    return _singleton;
  }

  MsgSignPage._internal();

  Future<bool?> show(
    BuildContext context,
    currentTheme,
  ) async {
    if (isDisplayed) {
      return false;
    }
    double height = MediaQuery.of(context).size.height;
    String weight = "a";
    // "Voting weight: ${rep?.weightPercentage.toStringAsFixed(2)}%";
    return showModalBottomSheet<bool>(
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: currentTheme.primary,
        builder: (BuildContext context) {
          bool additionalInfo = false;

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
                                                  AppLocalizations.of(context)!
                                                      .repInfoDialogTitle,
                                                  AppLocalizations.of(context)!
                                                      .repInfoDialogExplanation,
                                                  currentTheme);
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
                                            .representative,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: currentTheme.text,
                                        ),
                                      ),
                                      const Gap(50),
                                      AutoSizeText(
                                        AppLocalizations.of(context)!
                                            .currentRep,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: currentTheme.text,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Gap(15),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 35.0,
                                          right: 35.0,
                                        ),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 100,
                                          ),
                                          decoration: BoxDecoration(
                                            color: currentTheme.secondary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10.0, 15.0, 10.0, 15.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Center(
                                                  child: AutoSizeText(
                                                    "aa",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: currentTheme.text,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const Gap(10),

                                                // AutoSizeText(
                                                //   account.getRep(),
                                                //   maxLines: 2,
                                                //   style: TextStyle(
                                                //     fontSize: 14,
                                                //     color: currentTheme.text,
                                                //     fontFamily: 'monospace',
                                                //   ),
                                                // ),
                                                Utils().colorffix(
                                                    "asd", currentTheme),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(40),
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
              );
            },
          );
        });
  }

  displayButtons(BuildContext context, StateSetter setState,
      BaseTheme currentTheme, double height) {
    var appLocalizations = AppLocalizations.of(context);
    return SizedBox(
      height: 170,
      child: BottomAppBar(
        color: currentTheme.primary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 15),
          child: Column(
            children: [
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
                    var appLocalizations = AppLocalizations.of(context);
                    // bool? result = await ListRepChange().show(context,
                    //     currentTheme, appLocalizations, repList, account);

//Wallet and address

                    int walletIndex = services<WalletsService>().activeWallet;

                    String orgWalletName =
                        services<WalletsService>().walletsList[walletIndex];
                    // String activeWalletName =
                    //     services<WalletService>(instanceName: orgWalletName)
                    //         .getWalletName();

                    WalletService wallet =
                        services<WalletService>(instanceName: orgWalletName);

                    int accountIndex =
                        services<WalletService>(instanceName: orgWalletName)
                            .getActiveIndex();

                    String accOrgName = wallet.accountsList[accountIndex];

                    // String accountName =
                    //     services<Account>(instanceName: accOrgName).getName();

                    var account = services<Account>(instanceName: accOrgName);

                    String privateKey = wallet.getPrivateKey(account.index);
                    String publicKey = wallet.getPublicKey(privateKey);

                    // var privateKeyBytes = NanoHelpers.hexToBytes(privateKey);
                    // var publicKeyBytes = NanoHelpers.hexToBytes(publicKey);
                    int accountType = NanoAccountType.BANANO;
                    String bananoMessagePreamble = 'bananomsg-';

                    //Message
                    String message = "${bananoMessagePreamble}Test test 123";

                    var messageBytes = //NanoHelpers.hexToBytes(message);
                        NanoHelpers.stringToBytesUtf8(message);
                    // NanoSignatures.signBlock(calculatedHash, privateKey);

                    // TweetNaclFast.cryptoHashOff();
                    Uint8List out = Uint8List(32);
                    Blake2bDigest blake2b = Blake2bDigest(digestSize: 32);
                    blake2b.update(messageBytes, 0, messageBytes.length);
                    blake2b.doFinal(out, 0);
                    print(out);

                    String rep = NanoHelpers.byteToHex(out);
                    print(rep);
                    //32053372FA739D07633392896BB0B592451ADB74F09A654AF773A2910C51C461

                    String calculatedHash = Utils().getDummyBlockHash(
                        accountType,
                        account.address,
                        "".padLeft(64, "0"), //previous 0 x64
                        rep, //rep empty
                        BigInt.parse("0"),
                        "".padLeft(64, "0"));

                    String sign =
                        NanoSignatures.signBlock(calculatedHash, privateKey);

                    print("MSG $message");
                    print("SIGN $sign");
                    /////////////////////////////////

                    String messageToBeChecked = "Test test 123";

                    String givenAddr =
                        'ban_1toozhg5en6pa4ghoi5hp5ez59o86i1i54pkkp8h8o68grscdxzqwj6sx4xp';
                    String extractedKey =
                        NanoAccounts.extractPublicKey(givenAddr);

                    Uint8List extractedKeyBytes =
                        NanoHelpers.hexToBytes(extractedKey);

                    String givenSign =
                        '48F7EB30A0D43AD23DDD04CB3F8CA1C66A4C3565ACC1A0EB63CD5B4D9A7C6C18BFBD433C0E231D0869981D9763859CF55973152BBF89944E60E3FD8195EDDF0C';
                    Uint8List givenSignBytes =
                        NanoHelpers.hexToBytes(givenSign);

                    var blockBytes = Utils().getDumBlockHashBytes(
                        extractedKeyBytes, messageToBeChecked);

                    bool verify = Utils().detachedVerify(
                        blockBytes, givenSignBytes, extractedKeyBytes);
                    print("verify ok? $verify");

                    // String pubKey =
                    setState(() {
                      // if (result != null && result) {
                      //   Navigator.of(context).pop(true);
                      // }
                    });
                  },
                  child: Text(
                    appLocalizations!.chooseFromList,
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
                      // if (result != null && result) {
                      //   Navigator.of(context).pop(true);
                      // }
                      // properly make sure field is cleared
                      ManualRepChange().addressController.clear();
                    });
                  },
                  child: Text(
                    appLocalizations.enterManually,
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

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
