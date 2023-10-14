import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
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
                // createStartupBehaviourButton(),

                // createThemeButton("Login Auth"),
              ],
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
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

  Widget createChangePINButton(currentTheme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
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
          // Navigator.pop(context);
        },
        child: Text(
          AppLocalizations.of(context)!.changePINButton,
          style: TextStyle(color: currentTheme.text),
        ),
      ),
    );
  }
}
