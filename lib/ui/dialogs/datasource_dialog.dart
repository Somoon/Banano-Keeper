import 'package:bananokeeper/providers/data_source.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/pow/node_selector.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:gap/gap.dart';

class DataSourceDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  DataSourceDialog({super.key});

  @override
  DataSourceDialogState createState() => DataSourceDialogState();
}

class DataSourceDialogState extends State<DataSourceDialog>
    with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    List<String> sources = get<DataSource>().listOfAPIs.keys.toList();

    List<Widget> nodeWidgets = [];
    nodeWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          AppLocalizations.of(context)!.dataSourceDialogHeader,
          style: currentTheme.textStyle,
          maxFontSize: 12,
        ),
      ),
    );
    for (String item in sources) {
      nodeWidgets.add(createNodeButton(item, AppLocalizations.of(context)));
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
              children: nodeWidgets,
            ),
            const Gap(15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              style: currentTheme.btnStyleNoBorder,
              onPressed: () {
                services<AppRouter>().pop(context);
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

  Widget createNodeButton(String label, appLocalizations) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentSource = watchOnly((DataSource x) => x.getAPIName());
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: (services<DataSource>().getAPIName() == label)
            ? null
            : () async {
                _setSource(label);
                setState(() {});
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

  void _setSource(String nodeName) {
    setState(() {
      services<DataSource>().setAPI(nodeName);
      services<SharedPrefsModel>().saveDataSource(nodeName);
    });
  }
}
