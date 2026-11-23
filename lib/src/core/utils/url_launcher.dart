import 'package:flutter_starter/src/core/constant/config.dart';
import 'package:flutter_starter/src/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';

/// Открытие внешних ссылок.
///
/// Каждый метод возвращает `true`, если ссылку удалось открыть: при `false`
/// UI может показать сообщение. Ошибка платформы уже залогирована.
mixin UrlLauncher {
  /// Перенаправляет в приложение для отправки почты
  static Future<bool> sendMail(String mail) => _launchUrl(
    Uri(
      scheme: 'mailto',
      path: mail,
      query: _encodeQueryParameters({'subject': Config.appName}),
    ),
  );

  /// Перенаправляет на набор номера телефона
  static Future<bool> callPhone(String phone) =>
      _launchUrl(Uri(scheme: 'tel', path: phone));

  /// Перенаправляет в браузер
  static Future<bool> openUrl(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      mainTalker.warning('UrlLauncher: некорректная ссылка «$link»');
      return false;
    }
    return _launchUrl(uri);
  }

  static String _encodeQueryParameters(Map<String, String> params) => params
      .entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');

  /// Пытается открыть ссылку во внешнем приложении
  static Future<bool> _launchUrl(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        mainTalker.warning('UrlLauncher: не удалось открыть $uri');
      }
      return launched;
    } on Object catch (error, stackTrace) {
      mainTalker.handle(error, stackTrace, 'UrlLauncher: ошибка открытия $uri');
      return false;
    }
  }
}
