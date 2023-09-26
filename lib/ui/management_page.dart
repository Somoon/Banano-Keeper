import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class ManagementPage extends StatefulWidget with GetItStatefulWidgetMixin {
  // ManagementPage({super.key});

  @override
  ManagementPageState createState() => ManagementPageState();

  final Widget pageContent;
  final String pageTitle;
  ManagementPage(this.pageContent, this.pageTitle, {super.key});
}

class ManagementPageState extends State<ManagementPage> with GetItStateMixin {
  final walletRenameController = TextEditingController();

  FocusNode walletRenameControllerFocusNode = FocusNode();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    walletRenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);
    var primary = watchOnly((ThemeModel x) => x.curTheme.primary);
    var secondary = watchOnly((ThemeModel x) => x.curTheme.secondary);
    var statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return SafeArea(
      minimum: EdgeInsets.only(
        top: (statusBarHeight == 0.0 ? 50 : statusBarHeight),
      ),
      child: Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: secondary,
          elevation: 0.0,
          titleSpacing: 10.0,
          title: Text(
            widget.pageTitle,
            style: TextStyle(
              color: currentTheme.text,
              // fontSize: currentTheme.fontSize,
            ),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              setState(() {
                Navigator.of(context).pop();
              });
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: currentTheme.text,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: currentTheme.primary,
          ),
          child: widget.pageContent,
        ),
      ),
    );
  }

  createButton(String label, Widget stuff) {
    var currentTheme = watchOnly((ThemeModel x) => x.curTheme);

    return TextButton(
      onPressed: () {
        stuff;
      },
      child: Text(
        label,
        style: TextStyle(color: currentTheme.text),
      ),
    );
  }

  void doRename() {
    setState(() {
      int activeWallet = watchOnly((WalletsService x) => x.activeWallet);
String walletName = services<WalletsService>().walletsList[activeWallet];
      services<WalletService>(instanceName: walletName)
          .setWalletName(walletRenameController.text);
    });
  }
}
