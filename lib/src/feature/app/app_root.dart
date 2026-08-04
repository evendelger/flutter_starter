import 'package:flutter/material.dart';
import 'package:flutter_starter/src/core/model/model.dart';
import 'package:flutter_starter/src/core/widget/widget.dart';
import 'package:flutter_starter/src/feature/app/widget/app_configuration.dart';
import 'package:flutter_starter/src/feature/app/widget/app_scope.dart';
import 'package:flutter_starter/src/feature/user/model/user.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({
    required this.dependencies,
    required this.repositories,
    required this.initialUser,
    super.key,
  });

  final IDependenciesStorage dependencies;

  final IRepositoryStorage repositories;

  final User? initialUser;

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      storage: dependencies,
      child: RepositoryScope(
        storage: repositories,
        child: AppScope(
          initialUser: initialUser,
          child: const AppConfiguration(),
        ),
      ),
    );
  }
}
