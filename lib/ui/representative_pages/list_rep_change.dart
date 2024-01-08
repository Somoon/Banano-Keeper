import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/api/representative_json.dart';
import 'package:bananokeeper/providers/account.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/themes.dart';
import 'package:bananokeeper/ui/loading_widget.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:bananokeeper/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nanodart/nanodart.dart';

class ListRepChange {
  static final ListRepChange _singleton = ListRepChange._internal();
  final ScrollController controller = ScrollController();

  late BuildContext _context;
  bool isDisplayed = false;

  factory ListRepChange() {
    return _singleton;
  }

  ListRepChange._internal();

  Future<bool?> show(
      BuildContext context,
      currentTheme,
      AppLocalizations? appLocalizations,
      List<Representative>? repList,
      Account account) async {
    if (isDisplayed) {
      return false;
    }
    _context = context;

    return showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              // key: ValueKey(
              //     isCheckedNewWallet),
              backgroundColor: currentTheme.primary,
              elevation: 2,
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.representatives,
                  style: TextStyle(
                    fontSize: 24,
                    color: currentTheme.text,
                  ),
                ),
              ),
              titleTextStyle: currentTheme.textStyle,
              contentPadding: const EdgeInsets.only(top: 15),
              content: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: currentTheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                ),
                child: SizedBox(
                  height: height * 0.65,
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: GlowingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            color: currentTheme.text,
                            child: ListView.builder(
                              controller: controller,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: repList!.length,
                              itemBuilder: (context, index) {
                                return _buildButtonColumn(
                                    context,
                                    repList[index],
                                    index,
                                    currentTheme,
                                    account,
                                    appLocalizations);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: width,
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => currentTheme.text.withOpacity(0.3)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              currentTheme.primary,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            appLocalizations!.cancel,
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
          },
        );
      },
    );
  }

  Widget _buildButtonColumn(BuildContext context, Representative rep, int index,
      BaseTheme currentTheme, Account account, appLocalizations) {
    double width = MediaQuery.of(context).size.width;

    // double height = MediaQuery.of(context).size.height;

    String repAliasOrAddress = rep.alias ?? Utils().shortenAccount(rep.address);

    String score = appLocalizations.repScore(rep.score.toString());
    String votingWeight = appLocalizations
        .repVotingWeight(rep.weightPercentage.toStringAsFixed(2));

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.primary,
          ),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => currentTheme.text.withOpacity(0.05)),
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.zero,
              ),
              minimumSize: MaterialStateProperty.all<Size>(const Size(50, 30)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              changeRep(context, account, rep.address);
            },
            child: Center(
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
                margin: const EdgeInsetsDirectional.only(bottom: 1.0),
                height: 75,
                child: Column(
                  children: [
                    Ink(
                      height: 70,
                      width: width / 1.1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              repAliasOrAddress,
                              maxLines: 1,
                              style: TextStyle(
                                color: currentTheme.text,
                                fontSize: 18,
                              ),
                            ),
                            const Gap(5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  votingWeight,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: 12,
                                  ),
                                ),
                                AutoSizeText(
                                  score,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: currentTheme.text,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 1,
          color: currentTheme.secondary,
        )
      ],
    );
  }

  changeRep(BuildContext context, Account account, String repAddress) async {
    if (NanoAccounts.isValid(NanoAccountType.BANANO, repAddress)) {
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

        bool result = await account.changeRepresentative(repAddress);

        LoadingIndicatorDialog().dismiss();
        if (result) {
          Navigator.of(context).pop(true);

          // Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
