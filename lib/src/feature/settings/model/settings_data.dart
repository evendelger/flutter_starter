import 'package:flutter_starter/src/feature/settings/enum/theme_type.dart';
import 'package:flutter_starter/src/feature/settings/model/app_device_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_data.freezed.dart';

/// Настройки приложения
@freezed
abstract class SettingsData with _$SettingsData {
  const factory SettingsData({
    /// Выбранная тема
    required AppThemeType themeType,

    /// Информация о приложении и устройстве; `null`, пока не загружена
    AppDeviceInfo? appInfo,
  }) = _SettingsData;
}
