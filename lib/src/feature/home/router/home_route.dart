import 'package:auto_route/auto_route.dart';

import 'package:flutter_starter/src/core/router/router.dart';

/// {@template home_routes}
/// Роуты для вкладки домашнего экрана
/// {@endtemplate}
abstract final class HomeRoutes {
  /// Путь роута домашнего экрана
  static const String _homePath = 'home';

  /// Роуты-табы (дети MainRoute/AutoTabsRouter)
  static List<AutoRoute> get tabRoutes => [
    AutoRoute(
      path: _homePath,
      page: HomeRoute.page,
    ),
  ];
}
