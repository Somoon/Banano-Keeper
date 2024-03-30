import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/ui/dialogs/security_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdvancedDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  AdvancedDialog({super.key});

  @override
  AdvancedDialogState createState() => AdvancedDialogState();
}

class AdvancedDialogState extends State<AdvancedDialog> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    bool authOnBootStatus = watchOnly((UserData x) => x.getAuthOnBoot());
    bool authForSmallTx = watchOnly((UserData x) => x.getAuthForSmallTx());

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
          children: <Widget>[
            Column(
              children: [
                createAuthOnStartUp(
                    currentTheme, authForSmallTx, authOnBootStatus),
              ],
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              style: currentTheme.btnStyleNoBorder,
              onPressed: () {
                services<AppRouter>().pop();
              },
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: currentTheme.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding createAuthOnStartUp(
      BaseTheme currentTheme, bool authForSmallTx, bool authOnBootStatus) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            AppLocalizations.of(context)!.advancedSettingsnoAuthSmallTxText,
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 16,
            ),
          ),
          Switch(
            value: authForSmallTx,
            activeColor: currentTheme.text,
            activeTrackColor: Colors.black38,
            inactiveThumbColor: currentTheme.textDisabled,
            onChanged: (bool value) {
              if (value) {
                confirmationDialog(context, currentTheme, authOnBootStatus);
              } else {
                changeSmallTxAuthValue(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> confirmationDialog(BuildContext context, BaseTheme currentTheme,
      bool authOnBootStatus) async {
    var appLocalizations = AppLocalizations.of(context);

    return showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AlertDialog(
              backgroundColor: currentTheme.secondary,
              elevation: 2,
              title: Center(
                child: Text(appLocalizations!.noAuthSmallTxConfirmTitle),
              ),
              titleTextStyle: TextStyle(
                color: currentTheme.text,
                fontSize: currentTheme.fontSize,
              ),
              content: Text(appLocalizations.noAuthSmallTxConfirmText),
              contentTextStyle: TextStyle(
                color: currentTheme.textDisabled,
                fontSize: currentTheme.fontSize - 3,
              ),
              actions: [
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        style: currentTheme.btnStyleNoBorder,
                        onPressed: () async {
                          if (authOnBootStatus) {
                            bool canauth = await BiometricUtil().canAuth();
                            bool? verified = false;

                            if (!canauth) {
                              verified = await services<AppRouter>()
                                      .push(VerifyPINRoute()) ??
                                  false;
                            } else {
                              verified = await BiometricUtil().authenticate(
                                  appLocalizations.authMsgWalletDel);
                            }

                            if (verified != null && verified) {
                              setState(() {
                                Navigator.of(context).pop();
                                changeSmallTxAuthValue(true);
                              });
                            }
                          } else {
                            final snackBar = SnackBar(
                              content: Text(
                                  appLocalizations.noAuthOnBootSmallTxSnackBar),
                              // action: SnackBarAction(
                              //   label: 'Security',
                              //   onPressed: () {
                              //     SecurityDialog();
                              //   },
                              // ),
                            );

                            // Find the ScaffoldMessenger in the widget tree
                            // and use it to show a SnackBar.
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: Text(
                          appLocalizations.confirm,
                          style: currentTheme.textStyle,
                        ),
                      ),
                      TextButton(
                        style: currentTheme.btnStyleNoBorder,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          appLocalizations.cancel,
                          style: currentTheme.textStyle,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  changeSmallTxAuthValue(bool value) {
    setState(() {
      services<UserData>().setAuthForSmallTx(value);
      services<SharedPrefsModel>().saveAuthForSmallTx(value);
    });
  }
}
