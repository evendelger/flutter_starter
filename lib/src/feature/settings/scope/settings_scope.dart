import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/src/core/extension/extension.dart';
import 'package:flutter_starter/src/core/widget/widget.dart';
import 'package:flutter_starter/src/feature/settings/bloc/settings_bloc.dart';
import 'package:flutter_starter/src/feature/settings/enum/theme_type.dart';
import 'package:flutter_starter/src/feature/settings/model/app_device_info.dart';

ThemeMode _themeMode(SettingsState state) => switch (state.data.themeType) {
  AppThemeType.light => ThemeMode.light,
  AppThemeType.dark => ThemeMode.dark,
  AppThemeType.system => ThemeMode.system,
};

/// {@template settings_scope}
/// Настройки приложения: тема и информация о приложении и устройстве
/// {@endtemplate}
class SettingsScope extends StatelessWidget {
  /// {@macro settings_scope}
  const SettingsScope({required this.child, super.key});

  final Widget child;

  static const BlocScope<SettingsEvent, SettingsState, SettingsBloc> _scope =
      BlocScope();

  // --- Data --- //

  static ScopeData<AppDeviceInfo?> get appInfoOf => _scope.select(
    (state) => state.data.appInfo,
  );

  static ScopeData<AppThemeType> get appThemeOf => _scope.select(
    (state) => state.data.themeType,
  );

  /// [ThemeMode] для `MaterialApp.themeMode`
  static ScopeData<ThemeMode> get themeModeOf => _scope.select(_themeMode);

  // --- Methods --- //

  static UnaryScopeMethod<AppThemeType> get setTheme => _scope.unary(
    (context, theme) => SettingsEvent.setTheme(themeType: theme),
  );

  @override
  Widget build(BuildContext context) => BlocProvider<SettingsBloc>(
    create: (context) =>
        SettingsBloc(settingsRepository: context.repository.settings)
          ..add(const SettingsEvent.getData()),
    child: child,
  );
}
