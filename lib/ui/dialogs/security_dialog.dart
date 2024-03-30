import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/themes.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SecurityDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  SecurityDialog({super.key});

  @override
  SecurityDialogState createState() => SecurityDialogState();
}

class SecurityDialogState extends State<SecurityDialog> with GetItStateMixin {
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
                createChangePINButton(currentTheme),
                const Divider(
                  thickness: 1,
                ),
                createAuthOnStartUp(
                    currentTheme, authOnBootStatus, authForSmallTx)
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
      BaseTheme currentTheme, bool authOnBootStatus, bool authForSmallTx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            "Auth on startup: ",
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 16,
            ),
          ),
          Switch(
            // This bool value toggles the switch.
            value: authOnBootStatus,
            activeColor: currentTheme.text,
            activeTrackColor: Colors.black38,
            inactiveThumbColor: currentTheme.textDisabled,

            onChanged: (bool value) {
              if (authForSmallTx && !value) {
                changeSmallTxAuthValue(false);
              }
              changeAuthValue(value);
            },
          ),
        ],
      ),
    );
  }

  changeSmallTxAuthValue(bool value) {
    setState(() {
      services<UserData>().setAuthForSmallTx(value);
      services<SharedPrefsModel>().saveAuthForSmallTx(value);
    });
  }

  changeAuthValue(bool value) {
    setState(() {
      services<UserData>().setAuthOnBoot(value);
      services<SharedPrefsModel>().saveAuthOnBoot(value);
    });
  }

  Widget createChangePINButton(currentTheme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: () async {
          bool canauth = await BiometricUtil().canAuth();
          bool? verified = false;

          if (!canauth) {
            verified = await services<AppRouter>().push<bool>(VerifyPINRoute());
          } else {
            verified = await BiometricUtil()
                .authenticate(AppLocalizations.of(context)!.authMsgChangePIN);
          }

          if (verified != null && verified) {
            setState(() {
              services<AppRouter>().push(SetupPinRoute(nextPage: 'homepage'));
            });
          }
          setState(() {});
        },
        child: Text(
          AppLocalizations.of(context)!.changePINButton,
          style: TextStyle(color: currentTheme.text),
        ),
      ),
    );
  }
}
