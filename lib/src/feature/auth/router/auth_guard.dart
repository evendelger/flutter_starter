import 'package:auto_route/auto_route.dart';

import 'package:flutter_starter/src/core/router/router.dart';
import 'package:flutter_starter/src/feature/auth/bloc/auth_bloc.dart';

/// {@template auth_guard}
/// Гард, требующий авторизации.
///
/// В шаблоне не подключён — авторизация необязательна. Чтобы закрыть
/// ветку роутов логином, добавьте гард в соответствующий `AutoRoute`:
///
/// ```dart
/// AutoRoute(
///   path: '/',
///   page: AppWrapperRoute.page,
///   guards: [AuthGuard(authBloc)],
/// )
/// ```
/// {@endtemplate}
class AuthGuard extends AutoRouteGuard {
  /// {@macro auth_guard}
  const AuthGuard(this.authBloc);

  final AuthBloc authBloc;

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    if (authBloc.state.isAuthenticated) {
      resolver.next();
    } else {
      resolver.redirectUntil(const LoginRoute());
    }
  }
}
