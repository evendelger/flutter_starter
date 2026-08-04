import 'package:flutter/material.dart';
import 'package:flutter_starter/src/core/constant/constant.dart';
import 'package:flutter_test/flutter_test.dart';

/// Хелпер для рендеринга виджета с локализациями приложения
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
