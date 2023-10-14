import 'package:auto_size_text/auto_size_text.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PoWDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  PoWDialog({super.key});

  @override
  PoWDialogState createState() => PoWDialogState();
}

class PoWDialogState extends State<PoWDialog> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    List<String> sources = get<PoWSource>().listOfAPIS.keys.toList();

    List<Widget> powWidgets = [];
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          "Select the source which will be used when doing a transaction.",
          style: currentTheme.textStyle,
          maxFontSize: 12,
        ),
      ),
    );
    for (String item in sources) {
      powWidgets.add(createLangButton(item, AppLocalizations.of(context)));
    }

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
              children: powWidgets,
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

  Widget createLangButton(String label, appLocalizations) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentSource = watchOnly((PoWSource x) => x.getAPIName());
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: () {
          _setSource(label);
          setState(() {});
          // Navigator.pop(context);
        },
        child: Text(
          // appLocalizations!.
          label,
          style: TextStyle(
              color: (currentSource != label
                  ? currentTheme.text
                  : currentTheme.textDisabled)),
        ),
      ),
    );
  }

  void _setSource(String PoWName) {
    setState(() {
      services<PoWSource>().setAPI(PoWName);
      services<SharedPrefsModel>().savePoWSource(PoWName);
    });
  }
}
