import 'package:bananokeeper/providers/localization_service.dart';
import 'package:bananokeeper/themes.dart';
import 'package:flutter/material.dart';
import 'package:bananokeeper/ui/wallet_picker.dart';
import 'package:bananokeeper/ui/sideDrawer.dart';
import 'package:bananokeeper/ui/home_body.dart';
import 'package:bananokeeper/ui/bottom_bar.dart';

import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainAppLogic extends StatefulWidget with GetItStatefulWidgetMixin {
  MainAppLogic({super.key});
  // final bool isNewUser;
  // MainAppLogic(this.isNewUser, {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MainAppLogic createState() => _MainAppLogic();
}

class _MainAppLogic extends State<MainAppLogic> with GetItStateMixin {
  // ------------------------------------
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update() => setState(() => {});

  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    var currentLocale = watchOnly((LocalizationModel x) => x.getLocale());
    var supportedLocales =
        watchOnly((LocalizationModel x) => x.supportedLocales);
    // print("not new user - in homepage aka main_app_logic ");
    double width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // -----------------------
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: currentLocale,
      // ---------------------------

      home: (width < 600 ? smallScreenLogic() : bigScreenLogic()),
    );
  }

  Widget smallScreenLogic() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Scaffold(
      //--------------- Side Drawer -----------------------
      //make it width - (20% of width)
      drawerEdgeDragWidth: 300,
      drawer: SizedBox(
        width: 300,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: currentTheme.sideDrawerColor,
          ),
          child: SideDrawer(),
        ),
      ),
      backgroundColor: currentTheme.primary,

      //--------------- Wallet Settings -----------------------
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: currentTheme.primaryAppBar,
        centerTitle: true,
        title: Column(
          children: [
            walletPicker(),
            // Divider(color: Colors.black54),
          ],
        ),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            style: currentTheme.btnStyleNoBorder,
            splashRadius: 20,
            splashColor: currentTheme.textDisabled,
            highlightColor: currentTheme.text,
            icon: const Icon(Icons.menu), //, color: Colors.black38),
            // icon: new Icon(Icons.settings),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // ------ MAIN BODY ------------------
      body: home_body(),
      bottomNavigationBar: BottomBarApp(),
    );
  }

  Widget bigScreenLogic() {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return Directionality(
      //to move text direct in localization class
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          SizedBox(
            // color: Colors.blue,
            width: 250,
            child: SideDrawer(),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: currentTheme.primary,

              //--------------- Wallet Settings -----------------------
              appBar: AppBar(
                toolbarHeight: 50,
                backgroundColor: currentTheme.primaryAppBar,
                centerTitle: true,
                title: Column(
                  children: [
                    walletPicker(),
                    // Divider(color: Colors.black54),
                  ],
                ),
                elevation: 0,
              ),
              // ------ MAIN BODY ------------------
              body: home_body(),

              bottomNavigationBar: BottomBarApp(),
            ),
          )
        ],
      ),
      //
    );
  }
}
