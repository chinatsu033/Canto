// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Сейчас ничего не играет';

  @override
  String get nothingPlayingHint =>
      'Включите музыку в любом приложении. Canto только читает системные данные о воспроизведении.';

  @override
  String get loadingLyrics => 'Ищем текст песни…';

  @override
  String get noLyrics => 'Текста пока нет';

  @override
  String get plainLyricsNote => 'Несинхронизированный текст (без таймкодов)';

  @override
  String get lyricsError => 'Не удаётся связаться с сервисами текстов';

  @override
  String get retry => 'Повторить';

  @override
  String get play => 'Воспроизвести';

  @override
  String get pause => 'Пауза';

  @override
  String get favorite => 'В избранное';

  @override
  String favoriteSent(String app) {
    return 'Отправлено в $app';
  }

  @override
  String get favoriteUnsupported =>
      'Этот плеер не разрешает другим приложениям добавлять в избранное';

  @override
  String get favoriteFailed => 'Плеер отклонил запрос';

  @override
  String get controlUnsupported =>
      'Этот плеер не поддерживает удалённое управление';

  @override
  String get upNext => 'Далее в очереди';

  @override
  String get alwaysOnTop => 'Поверх всех окон';

  @override
  String get minimize => 'Свернуть';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get permissionTitle => 'Нужен доступ к уведомлениям';

  @override
  String get permissionBody =>
      'Android передаёт медиасессии других приложений только тем, у кого есть доступ к уведомлениям. Canto читает только данные о медиа и никогда — содержимое уведомлений.';

  @override
  String get grantPermission => 'Открыть настройки';

  @override
  String get sourceUnavailable =>
      'Данные о воспроизведении в этой системе недоступны';

  @override
  String get resumeFollow => 'К текущей строке';

  @override
  String lyricsFrom(String source) {
    return 'Текст: $source';
  }

  @override
  String get seekUnsupported => 'Этот плеер не поддерживает перемотку';

  @override
  String get commandFailed => 'Плеер не принял запрос';

  @override
  String get instrumental => 'Инструментал';

  @override
  String get translation => 'Перевод';

  @override
  String get romanization => 'Транслитерация';

  @override
  String get noTranslationHint => 'Для этой песни пока нет перевода';

  @override
  String get noRomanizationHint => 'Для этой песни пока нет транслитерации';

  @override
  String get autoLabel => 'авто';

  @override
  String get language => 'Язык';

  @override
  String get followSystem => 'Как в системе';

  @override
  String get playerActions => 'Действия плеера';

  @override
  String get playerActionsNone =>
      'Этот плеер не предоставляет дополнительных действий';

  @override
  String get autoTranslateLabel => 'Автоперевод';

  @override
  String get translatingHint => 'Перевод…';

  @override
  String get modelDownloadingHint =>
      'Загрузка модели перевода (около 30 МБ, только в первый раз)…';

  @override
  String get translateQuotaHint =>
      'Бесплатный лимит перевода на сегодня исчерпан — попробуйте завтра';

  @override
  String get translateFailedHint => 'Не удалось выполнить автоперевод';
}
