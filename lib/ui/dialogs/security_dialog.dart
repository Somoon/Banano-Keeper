import 'package:bananokeeper/providers/auth_biometric.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:flutter/material.dart';

import '../../providers/get_it_main.dart';
import '../../providers/shared_prefs_service.dart';
import '../../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

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
                createChangePINButton("Change PIN"),
                // createThemeButton("Login Auth"),
                // createThemeButton("Change PIN"),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: TextStyle(color: currentTheme.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createChangePINButton(label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          bool canauth = await BiometricUtil().canAuth();
          bool verified = false;

          if (!canauth) {
            verified = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VerifyPIN(),
              ),
            );
          } else {
            verified = await BiometricUtil()
                .authenticate("Authenticate to change PIN.");
          }

          if (verified) {
            setState(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SetupPin("homepage"),
                ),
              );
            });
          }
          setState(() {});
          // Navigator.pop(context);
        },
        child: Text(
          label,
          style: TextStyle(color: currentTheme.text),
        ),
      ),
    );
  }
}
