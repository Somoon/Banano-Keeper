import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/pow_source.dart';
import 'package:flutter/material.dart';

import '../../providers/get_it_main.dart';
import '../../providers/shared_prefs_service.dart';
import '../../themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class PoWDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  PoWDialog({super.key});

  @override
  PoWDialogState createState() => PoWDialogState();
}

class PoWDialogState extends State<PoWDialog> with GetItStateMixin {
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: AutoSizeText(
                    "Select the source which will be used when doing a transaction.",
                    style: currentTheme.textStyle,
                    maxFontSize: 12,
                  ),
                ),
                createButton("Kalium"),
                // createButton("Booster"),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              onPressed: () {
                services<AppRouter>().pop(context);
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

  Widget createButton(label) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _setSource(label);
          setState(() {});
          // Navigator.pop(context);
        },
        child: Text(
          label,
          style: TextStyle(
              color: (getTextColor(label)
                  ? currentTheme.text
                  : currentTheme.textDisabled)),
        ),
      ),
    );
  }

  getTextColor(PoWName) {
    String selectedPoWName = watchOnly((PoWSource x) => x.getAPIName());

    if (selectedPoWName == PoWName) return false;
    return true;
  }

  void _setSource(String PoWName) {
    setState(() {
      services<PoWSource>().setAPI(PoWName);
      services<SharedPrefsModel>().savePoWSource(PoWName);
    });
  }
}
