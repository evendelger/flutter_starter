import 'package:flutter/material.dart';
import 'package:flutter_starter/src/core/constant/constant.dart';
import 'package:flutter_starter/src/core/extension/extension.dart';
import 'package:flutter_starter/src/core/theme/theme.dart';

/// {@template app_error}
/// Экран ошибки при неудачной инициализации приложения.
///
/// Показывается вместо `AppRoot`, поэтому поднимает свой [MaterialApp] с темой
/// и локализацией. Детали ошибки пользователю не показываются — они уже
/// в логе `mainTalker`.
/// {@endtemplate}
class AppError extends StatelessWidget {
  /// {@macro app_error}
  const AppError({this.onRetry, super.key});

  /// Повторить инициализацию; без него кнопка не показывается
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _AppErrorBody(onRetry: onRetry),
  );
}

class _AppErrorBody extends StatelessWidget {
  const _AppErrorBody({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  l10n.errorAppStart,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.errorSomethingWrong,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onRetry case final onRetry?) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(l10n.actionRetry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
