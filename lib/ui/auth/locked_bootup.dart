import 'package:auto_route/annotations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:bananokeeper/themes.dart';

@RoutePage<bool>(name: "LockedBootupRoute")
class LockedBootup extends StatefulWidget with GetItStatefulWidgetMixin {
  LockedBootup({Key? key}) : super(key: key);

  @override
  _LockedBootupState createState() => _LockedBootupState();
}

class _LockedBootupState extends State<LockedBootup> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Container(
      decoration: BoxDecoration(color: currentTheme.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Gap(1),
          AutoSizeText(
            "App Locked",
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(40),
          SizedBox(
            height: 50,
            child: OutlinedButton(
              style: currentTheme.btnStyle,
              onPressed: () async {
                bool canauth = await BiometricUtil().canAuth();
                bool? verified = false;

                if (!canauth) {
                  verified =
                      await services<AppRouter>().push<bool>(VerifyPINRoute());
                } else {
                  verified = await BiometricUtil().authenticate("Authenticate");
                  //AppLocalizations.of(context)!.authMsgChangeRep
                }
                if (verified != null && verified) {
                  services<AppRouter>().pop(true);
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(
                "Unlock app",
                // AppLocalizations.of(context)!.add,
                style: TextStyle(
                  color: currentTheme.text,
                  fontSize: currentTheme.fontSize,
                ),
              ),
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
