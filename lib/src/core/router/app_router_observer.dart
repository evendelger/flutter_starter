import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/src/core/utils/logger.dart';

class AppRouterObserver extends AutoRouterObserver {
  static const _logName = '[Router]';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(
      action: 'PUSH   ',
      from: _routeName(previousRoute),
      to: _routeName(route),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(
      action: 'POP    ',
      from: _routeName(route),
      to: _routeName(previousRoute),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log(
      action: 'REPLACE',
      from: _routeName(oldRoute),
      to: _routeName(newRoute),
    );
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    mainTalker.debug('$_logName TAB INIT  /${route.path}');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    mainTalker.debug(
      '$_logName TAB       /${previousRoute.path} → /${route.path}',
    );
  }

  String? _routeName(Route<dynamic>? route) {
    final settings = route?.settings;
    if (settings is AutoRoutePage) {
      final path = settings.routeData.match;
      return path.isEmpty ? null : path;
    }
    final raw = settings?.name;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  void _log({required String action, String? from, String? to}) {
    final fromPart = from != null ? '$from  →  ' : '';
    final toPart = to ?? '—';
    mainTalker.debug('$_logName $action  $fromPart$toPart');
  }
}
