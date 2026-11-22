// CLI-скрипт: вывод в stdout — это его интерфейс.
// ignore_for_file: avoid_print

/// Статический анализ проекта (`make analyze`).
///
/// Запускает `dart analyze` и завершается с ошибкой на **любом** замечании
/// (включая info), кроме одного известного класса: депрекейта
/// `package:flutter/material.dart` / `cupertino.dart` в пользу пакетов
/// `material_ui` / `cupertino_ui` (Flutter 3.47+).
///
/// Миграция на `material_ui` — отдельная задача: это не реэкспорт, а копия
/// классов, и пока сторонние пакеты (auto_route, talker_flutter, …) работают
/// с типами из `package:flutter`, частичный переход ломает совместимость типов.
/// После миграции этот фильтр нужно удалить, а скрипт заменить на
/// `flutter analyze`.
///
/// Аргументы пробрасываются в `dart analyze` (например, путь).
library;

import 'dart:io';

Future<void> main(List<String> args) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'analyze',
    '--format=machine',
    ...args,
  ]);

  final stdoutText = result.stdout as String;
  final stderrText = result.stderr as String;
  final lines = '$stdoutText\n$stderrText'
      .split('\n')
      .where((line) => line.trim().isNotEmpty);

  final issues = <_Issue>[];
  final unparsed = <String>[];
  for (final line in lines) {
    final issue = _Issue.tryParse(line);
    if (issue != null) {
      issues.add(issue);
    } else {
      unparsed.add(line);
    }
  }

  final tolerated = issues.where((issue) => issue.isPendingMigration).toList();
  final reported = issues.where((issue) => !issue.isPendingMigration).toList();

  // `dart analyze`: 0 — чисто, 1–3 — найдены замечания (info/warning/error).
  // Всё остальное — сбой самого анализатора (нет pub get, битый конфиг).
  final analyzerFailed = result.exitCode > 3 || result.exitCode < 0;
  if (analyzerFailed || (issues.isEmpty && result.exitCode != 0)) {
    unparsed.forEach(print);
    print('dart analyze завершился с кодом ${result.exitCode}');
    exit(result.exitCode == 0 ? 1 : result.exitCode);
  }

  reported.forEach(print);

  if (tolerated.isNotEmpty) {
    print(
      'Пропущено ${tolerated.length} депрекейтов material.dart / '
      'cupertino.dart (ждут миграции на material_ui, см. tool/analyze.dart).',
    );
  }

  if (reported.isEmpty) {
    print('No issues found!');
    return;
  }

  print('${reported.length} issue(s) found.');
  exit(1);
}

/// Одна строка `dart analyze --format=machine`:
/// `SEVERITY|TYPE|CODE|FILE|LINE|COLUMN|LENGTH|MESSAGE`.
final class _Issue {
  const _Issue({
    required this.severity,
    required this.code,
    required this.file,
    required this.line,
    required this.column,
    required this.message,
  });

  static _Issue? tryParse(String raw) {
    // В сообщении `|` экранируется как `\|`
    final parts = raw
        .replaceAll(r'\|', '\u0000')
        .split('|')
        .map((part) => part.replaceAll('\u0000', '|'))
        .toList();
    if (parts.length < 8) return null;
    if (!const {'INFO', 'WARNING', 'ERROR'}.contains(parts[0])) return null;

    return _Issue(
      severity: parts[0].toLowerCase(),
      code: parts[2].toLowerCase(),
      file: _relative(parts[3]),
      line: parts[4],
      column: parts[5],
      message: parts.sublist(7).join('|'),
    );
  }

  static String _relative(String path) {
    final root = '${Directory.current.path}${Platform.pathSeparator}';
    return path.startsWith(root) ? path.substring(root.length) : path;
  }

  final String severity;
  final String code;
  final String file;
  final String line;
  final String column;
  final String message;

  /// Депрекейт, который уйдёт вместе с миграцией на material_ui / cupertino_ui
  bool get isPendingMigration =>
      code == 'deprecated_member_use' &&
      (message.contains('package:material_ui') ||
          message.contains('package:cupertino_ui'));

  @override
  String toString() => '$severity • $message • $file:$line:$column • $code';
}
