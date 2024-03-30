import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/api/account_api.dart';
import 'package:bananokeeper/api/state_block.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/queue_service.dart';
import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nanodart/nanodart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:gap/gap.dart';

class SendConfirmDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  final String inputAddress;
  final String inputAmount;
  final Account account;
  SendConfirmDialog(
      {super.key,
      required this.inputAddress,
      required this.inputAmount,
      required this.account});

  @override
  SendConfirmDialogState createState() => SendConfirmDialogState();
}

class SendConfirmDialogState extends State<SendConfirmDialog>
    with GetItStateMixin {
  int threadCount = services<UserData>().getThreadCount();

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var appLocalization = AppLocalizations.of(context)!;

    List<Widget> powWidgets = [];
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          appLocalization.sendingConfirmationDialogTitle,
          style: currentTheme.textStyle,
          maxFontSize: 20,
        ),
      ),
    );

    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          appLocalization.sending,
          style: TextStyle(
            color: currentTheme.textDisabled,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .60,
          ),
          child: AutoSizeText(
            "${widget.inputAmount} BAN",
            style: currentTheme.textStyle,
          ),
        ),
      ),
    );
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          appLocalization.to,
          style: TextStyle(
            color: currentTheme.textDisabled,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .60,
          ),
          child: Utils().colorffix(widget.inputAddress, currentTheme, 20),
        ),
      ),
    );

    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 500,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
          color: currentTheme.primary, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: powWidgets,
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  style: currentTheme.btnStyle,
                  onPressed: () {
                    services<AppRouter>().pop(false);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.close,
                    style: TextStyle(
                      color: currentTheme.text,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Gap(25),
                TextButton(
                  style: currentTheme.btnStyle.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      currentTheme.text,
                    ),
                  ),
                  onPressed: () async {
                    bool authForSmallTx =
                        watchOnly((UserData x) => x.getAuthForSmallTx());
                    Decimal amount = Decimal.parse(widget.inputAmount);
                    bool? verified = false;
                    if (authForSmallTx && amount <= Decimal.parse("10")) {
                      verified = true;
                    } else {
                      bool canauth = await BiometricUtil().canAuth();

                      if (!canauth) {
                        verified = await services<AppRouter>()
                            .push<bool>(VerifyPINRoute());
                      } else {
                        verified = await BiometricUtil().authenticate(
                            appLocalization
                                .authMsgConfirmSend(widget.inputAmount));
                      }
                    }

                    if (verified != null && verified) {
                      LoadingIndicatorDialog().show(context,
                          text: appLocalization.loadingWidgetSendMsg,
                          theme: currentTheme);

                      await services<QueueService>()
                          .add(widget.account.getOverview(true));
                      await services<QueueService>()
                          .add(widget.account.handleOverviewResponse(true));

                      String sendAmountRaw =
                          Utils().rawFromAmount(widget.inputAmount);
                      String destAddress = (widget.inputAddress);
                      var hist = await AccountAPI()
                          .getHistory(widget.account.address, 1);
                      var historyData = jsonDecode(hist.body);
                      String previous = historyData[0]['hash'];

                      var newRaw = (BigInt.parse(widget.account.getBalance()) -
                              BigInt.parse(sendAmountRaw))
                          .toString();

                      int accountType = NanoAccountType.BANANO;
                      String calculatedHash = NanoBlocks.computeStateHash(
                          accountType,
                          widget.account.address,
                          previous,
                          widget.account.representative,
                          BigInt.parse(newRaw),
                          destAddress);
                      int activeWallet =
                          services<WalletsService>().activeWallet;
                      String walletName =
                          services<WalletsService>().walletsList[activeWallet];

                      String privateKey =
                          services<WalletService>(instanceName: walletName)
                              .getPrivateKey(widget.account.index);
                      // Signing a block
                      String sign =
                          NanoSignatures.signBlock(calculatedHash, privateKey);

                      StateBlock sendBlock = StateBlock(
                          widget.account.address,
                          previous,
                          widget.account.representative,
                          newRaw,
                          destAddress,
                          sign);

                      var sendHash =
                          await AccountAPI().processRequest(sendBlock, "send");
                      FocusScope.of(context).unfocus();
                      LoadingIndicatorDialog().dismiss();

                      //if
                      //{"error":"Invalid block balance for given subtype"}
                      //else
                      if (jsonDecode(sendHash)['hash'] != null &&
                          NanoHelpers.isHexString(
                              jsonDecode(sendHash)['hash'])) {
                        await widget.account.setBalance(newRaw);
                        await services<QueueService>()
                            .add(widget.account.onRefreshUpdateHistory());

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

                        // Navigator.of(context).pop(true);
                        services<AppRouter>().pop(true);
                      } else {
                        //ERR?
                        if (kDebugMode) {
                          print(sendHash);
                        }
                      }
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: TextStyle(
                      color: currentTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
