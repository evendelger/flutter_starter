enum AppThemeType {
  light,
  dark,
  system;

  /// Значение по имени. Неизвестное имя (например, сохранённое до
  /// переименования значения) даёт `null`, а не исключение.
  static AppThemeType? tryParse(String? name) =>
      values.where((type) => type.name == name).firstOrNull;
}
