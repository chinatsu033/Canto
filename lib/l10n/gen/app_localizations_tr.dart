// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Şu anda bir şey çalmıyor';

  @override
  String get nothingPlayingHint =>
      'Herhangi bir müzik uygulamasında bir şey çalın. Canto yalnızca sistemin çalma bilgilerini okur.';

  @override
  String get loadingLyrics => 'Şarkı sözü aranıyor…';

  @override
  String get noLyrics => 'Henüz şarkı sözü yok';

  @override
  String get plainLyricsNote => 'Senkronize olmayan söz (zamanlama yok)';

  @override
  String get lyricsError => 'Şarkı sözü servislerine ulaşılamadı';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get play => 'Oynat';

  @override
  String get pause => 'Duraklat';

  @override
  String get favorite => 'Favori';

  @override
  String favoriteSent(String app) {
    return '$app uygulamasına gönderildi';
  }

  @override
  String get favoriteUnsupported =>
      'Bu oynatıcı diğer uygulamaların favori eklemesine izin vermiyor';

  @override
  String get favoriteFailed => 'Oynatıcı isteği reddetti';

  @override
  String get controlUnsupported => 'Bu oynatıcı uzaktan kontrolü kabul etmiyor';

  @override
  String get upNext => 'Sıradaki';

  @override
  String get alwaysOnTop => 'Her zaman üstte';

  @override
  String get minimize => 'Küçült';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get permissionTitle => 'Bildirim erişimi gerekli';

  @override
  String get permissionBody =>
      'Android, diğer uygulamaların medya oturumlarını yalnızca bildirim erişimi olan uygulamalarla paylaşır. Canto yalnızca medya bilgilerini okur, bildirim içeriğini asla okumaz.';

  @override
  String get grantPermission => 'Ayarları aç';

  @override
  String get sourceUnavailable => 'Bu sistemde çalma bilgisi alınamıyor';

  @override
  String get resumeFollow => 'Geçerli satıra dön';

  @override
  String lyricsFrom(String source) {
    return 'Sözler: $source';
  }

  @override
  String get seekUnsupported => 'Bu oynatıcı ileri/geri sarmayı desteklemiyor';

  @override
  String get commandFailed => 'Oynatıcı isteği kabul etmedi';

  @override
  String get instrumental => 'Enstrümantal';

  @override
  String get translation => 'Çeviri';

  @override
  String get romanization => 'Latin harfli okunuş';

  @override
  String get noTranslationHint => 'Bu şarkının henüz çevirisi yok';

  @override
  String get noRomanizationHint => 'Bu şarkının henüz Latin harfli okunuşu yok';

  @override
  String get autoLabel => 'otomatik';

  @override
  String get language => 'Dil';

  @override
  String get followSystem => 'Sistemi izle';

  @override
  String get playerActions => 'Oynatıcı eylemleri';

  @override
  String get playerActionsNone => 'Bu oynatıcı ek eylem sunmuyor';

  @override
  String get autoTranslateLabel => 'Otomatik çeviri';

  @override
  String get translatingHint => 'Çevriliyor…';

  @override
  String get modelDownloadingHint =>
      'Çeviri modeli indiriliyor (yaklaşık 30 MB, yalnızca ilk sefer)…';

  @override
  String get translateQuotaHint =>
      'Bugünkü ücretsiz çeviri kotası doldu — yarın tekrar deneyin';

  @override
  String get translateFailedHint => 'Otomatik çeviri başarısız oldu';
}
