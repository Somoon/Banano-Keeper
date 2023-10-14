// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ImportWalletRoute.name: (routeData) {
      final args = routeData.argsAs<ImportWalletRouteArgs>(
          orElse: () => const ImportWalletRouteArgs());
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: ImportWalletPage(key: args.key),
      );
    },
    InitialPageImportRoute.name: (routeData) {
      final args = routeData.argsAs<InitialPageImportRouteArgs>(
          orElse: () => const InitialPageImportRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InitialPageImport(key: args.key),
      );
    },
    InitialPageInformationRoute.name: (routeData) {
      final args = routeData.argsAs<InitialPageInformationRouteArgs>(
          orElse: () => const InitialPageInformationRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InitialPageInformation(key: args.key),
      );
    },
    InitialPage.name: (routeData) {
      final args = routeData.argsAs<InitialPageArgs>(
          orElse: () => const InitialPageArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InitialPageOne(key: args.key),
      );
    },
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MainAppLogic(key: args.key),
      );
    },
    Management.name: (routeData) {
      final args = routeData.argsAs<ManagementArgs>();
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: ManagementPage(
          args.pageContent,
          args.pageTitle,
          key: args.key,
        ),
      );
    },
    SetupPinRoute.name: (routeData) {
      final args = routeData.argsAs<SetupPinRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SetupPin(
          args.nextPage,
          key: args.key,
        ),
      );
    },
    VerifyPINRoute.name: (routeData) {
      final args = routeData.argsAs<VerifyPINRouteArgs>(
          orElse: () => const VerifyPINRouteArgs());
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: VerifyPIN(key: args.key),
      );
    },
  };
}

/// generated route for
/// [ImportWalletPage]
class ImportWalletRoute extends PageRouteInfo<ImportWalletRouteArgs> {
  ImportWalletRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ImportWalletRoute.name,
          args: ImportWalletRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ImportWalletRoute';

  static const PageInfo<ImportWalletRouteArgs> page =
      PageInfo<ImportWalletRouteArgs>(name);
}

class ImportWalletRouteArgs {
  const ImportWalletRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ImportWalletRouteArgs{key: $key}';
  }
}

/// generated route for
/// [InitialPageImport]
class InitialPageImportRoute extends PageRouteInfo<InitialPageImportRouteArgs> {
  InitialPageImportRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          InitialPageImportRoute.name,
          args: InitialPageImportRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'InitialPageImportRoute';

  static const PageInfo<InitialPageImportRouteArgs> page =
      PageInfo<InitialPageImportRouteArgs>(name);
}

class InitialPageImportRouteArgs {
  const InitialPageImportRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'InitialPageImportRouteArgs{key: $key}';
  }
}

/// generated route for
/// [InitialPageInformation]
class InitialPageInformationRoute
    extends PageRouteInfo<InitialPageInformationRouteArgs> {
  InitialPageInformationRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          InitialPageInformationRoute.name,
          args: InitialPageInformationRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'InitialPageInformationRoute';

  static const PageInfo<InitialPageInformationRouteArgs> page =
      PageInfo<InitialPageInformationRouteArgs>(name);
}

class InitialPageInformationRouteArgs {
  const InitialPageInformationRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'InitialPageInformationRouteArgs{key: $key}';
  }
}

/// generated route for
/// [InitialPageOne]
class InitialPage extends PageRouteInfo<InitialPageArgs> {
  InitialPage({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          InitialPage.name,
          args: InitialPageArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'InitialPage';

  static const PageInfo<InitialPageArgs> page = PageInfo<InitialPageArgs>(name);
}

class InitialPageArgs {
  const InitialPageArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'InitialPageArgs{key: $key}';
  }
}

/// generated route for
/// [MainAppLogic]
class Home extends PageRouteInfo<HomeArgs> {
  Home({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Home.name,
          args: HomeArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'Home';

  static const PageInfo<HomeArgs> page = PageInfo<HomeArgs>(name);
}

class HomeArgs {
  const HomeArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for
/// [ManagementPage]
class Management extends PageRouteInfo<ManagementArgs> {
  Management({
    required Widget pageContent,
    required String pageTitle,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Management.name,
          args: ManagementArgs(
            pageContent: pageContent,
            pageTitle: pageTitle,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Management';

  static const PageInfo<ManagementArgs> page = PageInfo<ManagementArgs>(name);
}

class ManagementArgs {
  const ManagementArgs({
    required this.pageContent,
    required this.pageTitle,
    this.key,
  });

  final Widget pageContent;

  final String pageTitle;

  final Key? key;

  @override
  String toString() {
    return 'ManagementArgs{pageContent: $pageContent, pageTitle: $pageTitle, key: $key}';
  }
}

/// generated route for
/// [SetupPin]
class SetupPinRoute extends PageRouteInfo<SetupPinRouteArgs> {
  SetupPinRoute({
    required String nextPage,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SetupPinRoute.name,
          args: SetupPinRouteArgs(
            nextPage: nextPage,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'SetupPinRoute';

  static const PageInfo<SetupPinRouteArgs> page =
      PageInfo<SetupPinRouteArgs>(name);
}

class SetupPinRouteArgs {
  const SetupPinRouteArgs({
    required this.nextPage,
    this.key,
  });

  final String nextPage;

  final Key? key;

  @override
  String toString() {
    return 'SetupPinRouteArgs{nextPage: $nextPage, key: $key}';
  }
}

/// generated route for
/// [VerifyPIN]
class VerifyPINRoute extends PageRouteInfo<VerifyPINRouteArgs> {
  VerifyPINRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          VerifyPINRoute.name,
          args: VerifyPINRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'VerifyPINRoute';

  static const PageInfo<VerifyPINRouteArgs> page =
      PageInfo<VerifyPINRouteArgs>(name);
}

class VerifyPINRouteArgs {
  const VerifyPINRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'VerifyPINRouteArgs{key: $key}';
  }
}
