import 'package:auto_route/auto_route.dart';
part 'app_router.gr.dart';
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
@AutoRouterConfig()
class AppRouter extends $AppRouter {

  @override
  List<AutoRoute> get routes => [
    /// routes go here
  ];
}