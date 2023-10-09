import 'package:auto_route/auto_route.dart';
import 'package:bananokeeper/app_router.dart';
import 'package:bananokeeper/initial_pages/initial_page_import.dart';
import 'package:bananokeeper/initial_pages/initial_page_new_information.dart';
import 'package:bananokeeper/initial_pages/initial_page_one.dart';
import 'package:bananokeeper/ui/management/import_wallet.dart';
import 'package:bananokeeper/ui/management/management_page.dart';
import 'package:bananokeeper/main_app_logic.dart';
import 'package:bananokeeper/ui/message_signing/bottomSheetSign.dart';
import 'package:bananokeeper/ui/message_signing/message_sign_verification.dart';
import 'package:bananokeeper/ui/pin/setup_pin.dart';
import 'package:bananokeeper/ui/pin/verify_pin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            path: '/home',
            guards: [UserIsSetup()],
            page: Home.page,
            initial: true),
        AutoRoute(path: '/WalletsManagement', page: Management.page),
        AutoRoute(path: '/Importwallet', page: ImportWalletRoute.page),
        AutoRoute(path: '/AccountsManagement', page: Management.page),
        AutoRoute(path: '/InitialImport', page: InitialPageImportRoute.page),
        AutoRoute(
            path: '/InitialPageInformation',
            page: InitialPageInformationRoute.page),
        AutoRoute(path: '/InitialPage', page: InitialPage.page),
        AutoRoute(path: '/VerifyPIN', page: VerifyPINRoute.page),
        AutoRoute(path: '/SetupPin', page: SetupPinRoute.page),
        // AutoRoute(path: '/MessageSign', page: MsgSignRoute.page),
        // AutoRoute(path: '/SignVerify', page: MsgSignVerifyRoute.page),
      ];
}

class UserIsSetup extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    if (sharedPref.containsKey("isInitialized")) {
      resolver.next(true);
    } else {
      router.push(InitialPage());
    }
  }
}
