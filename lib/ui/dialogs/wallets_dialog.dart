import 'package:bananokeeper/providers/wallet_service.dart';
import 'package:bananokeeper/providers/wallets_service.dart';
import 'package:flutter/material.dart';

import 'package:bananokeeper/providers/get_it_main.dart';
import 'package:bananokeeper/themes.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class WalletManagementDialog extends StatefulWidget
    with GetItStatefulWidgetMixin {
  WalletManagementDialog({super.key});

  @override
  WalletManagementDialogState createState() => WalletManagementDialogState();
}

class WalletManagementDialogState extends State<WalletManagementDialog>
    with GetItStateMixin {
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
    int activeWallet = watchOnly((WalletsService x) => x.activeWallet);
    var wallets = watchOnly((WalletsService x) => x.walletsList);
    String activeWalletName = services<WalletService>().getWalletName();
    var primary = watchOnly((ThemeModel x) => x.curTheme.primary);

    return Container(
      width: double.infinity,
      // constraints: BoxConstraints(
      //   minWidth: 100,
      //   maxWidth: 500,
      //   // maxHeight: 600,
      // ),
      decoration: BoxDecoration(
        color: currentTheme.secondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "placeholder for dropmenu to change active wallet (disabled if only one exist)",
              style: TextStyle(
                color: currentTheme.text,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Wallet Name",
              style: TextStyle(
                color: currentTheme.text,
                fontSize: 10,
              ),
            ),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: TextFormField(
                focusNode: walletRenameControllerFocusNode,
                controller: walletRenameController,
                autofocus: false,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  labelStyle: TextStyle(
                      color: walletRenameControllerFocusNode.hasFocus
                          ? currentTheme.textDisabled
                          : currentTheme.textDisabled),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primary),
                  ),
                  // labelText: "Wallet name",
                  // prefixIcon: Icon(Icons.search),
                  hintText: activeWalletName,
                  hintStyle: TextStyle(color: primary),

                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 30),
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text("Rename"),
                      onPressed: () {
                        doRename();
                        setState(() {});
                      },
                    ),
                  ),
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  return value!.length > 20
                      ? 'Wallet name length can be up to 20 characters.'
                      : null;
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (wallets.length > 1) {
                    services<WalletsService>().deleteWallet(0);
                    Navigator.pop(context);

                    //delete logic
                  } else {
                    //reset logic? or simply do nothing since theres only one wallet rn
                  }
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "- delete wallet - need confirm with bio/pin\n"
                    "deleting last wallet will prompt a clear app state and send user to initialPage to create/import new wallet",
                    style: TextStyle(
                      color: currentTheme.text,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 3,
            ),
            const Text("- import"),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  services<WalletsService>().createNewWallet();
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "- create new wallet",
                    style: TextStyle(
                      color: currentTheme.text,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(
              thickness: 1,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  'Close',
                  style: TextStyle(color: currentTheme.text),
                ),
              ),
            ),
          ],
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

      String walletName = services<WalletsService>()
          .walletsList[activeWallet];
      services<WalletService>(instanceName: walletName)
          .setWalletName(walletRenameController.text);
    });
  }
}
