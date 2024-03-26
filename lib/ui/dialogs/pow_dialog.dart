import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/providers/pow/local_work.dart';
import 'package:bananokeeper/providers/pow/pow_source.dart';
import 'package:bananokeeper/providers/user_data.dart';
import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/providers/shared_prefs_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:gap/gap.dart';

class PoWDialog extends StatefulWidget with GetItStatefulWidgetMixin {
  PoWDialog({super.key});

  @override
  PoWDialogState createState() => PoWDialogState();
}

class PoWDialogState extends State<PoWDialog> with GetItStateMixin {
  int threadCount = services<UserData>().getThreadCount();

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentSource = watchOnly((PoWSource x) => x.getAPIName());
    List<String> sources = get<PoWSource>().listOfAPIS.keys.toList();

    List<Widget> powWidgets = [];
    powWidgets.add(
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: AutoSizeText(
          "Select the PoW generation source which will be used when doing a transaction.",
          style: currentTheme.textStyle,
          maxFontSize: 12,
        ),
      ),
    );
    for (String item in sources) {
      if (item == 'Local PoW') {
        if (!Platform.isWindows) {
          powWidgets.add(createLangButton(item, AppLocalizations.of(context)));
        }
      } else {
        powWidgets.add(createLangButton(item, AppLocalizations.of(context)));
      }
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
            if (currentSource == 'Local PoW') ...[
              const Gap(15),
              const Divider(
                thickness: 1,
              ),
              AutoSizeText(
                "Threads: $threadCount",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  color: currentTheme.text,
                ),
              ),
              SizedBox(
                width: 250,
                child: Slider(
                  activeColor: Colors.purple,
                  inactiveColor: Colors.purple.shade100,
                  thumbColor: Colors.pink,
                  min: 1.0,
                  max: 8.0,
                  value: threadCount.toDouble(),
                  onChanged: (value) {
                    threadCount = value.toInt();
                    services<UserData>().setThreadCount(threadCount);
                    services<SharedPrefsModel>().saveThreadCount(threadCount);
                    setState(() {});
                  },
                ),
              ),
            ],
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

  Widget createLangButton(String label, appLocalizations) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var currentSource = watchOnly((PoWSource x) => x.getAPIName());
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: currentTheme.btnStyleNoBorder,
        onPressed: (services<PoWSource>().getAPIName() == label)
            ? null
            : () async {
                if (label == 'Local PoW') {
                  if (!await Permission.bluetoothConnect.isGranted) {
                    Permission.bluetoothConnect.request();
                  }
                  services<LocalWork>().init();
                } else if (services<PoWSource>().getAPIName() == 'Local PoW') {
                  //before label assignment - localpow was enabled

                  //stop and dispose of local webserver if not in use
                  // print('shutting down webvserver');
                  await services<LocalWork>().disposelocalServer();
                }
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

  void _setSource(String poWName) {
    setState(() {
      services<PoWSource>().setAPI(poWName);
      services<SharedPrefsModel>().savePoWSource(poWName);
    });
  }
}
