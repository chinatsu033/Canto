// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Es wird nichts abgespielt';

  @override
  String get nothingPlayingHint =>
      'Spiele etwas in einer beliebigen Musik-App ab. Canto liest nur die Wiedergabeinfos des Systems.';

  @override
  String get loadingLyrics => 'Songtext wird gesucht…';

  @override
  String get noLyrics => 'Noch kein Songtext';

  @override
  String get plainLyricsNote =>
      'Nicht synchronisierter Songtext (ohne Zeitangaben)';

  @override
  String get lyricsError => 'Songtext-Dienste nicht erreichbar';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get favorite => 'Favorit';

  @override
  String favoriteSent(String app) {
    return 'An $app gesendet';
  }

  @override
  String get favoriteUnsupported =>
      'Dieser Player erlaubt anderen Apps keine Favoriten';

  @override
  String get favoriteFailed => 'Der Player hat die Anfrage abgelehnt';

  @override
  String get controlUnsupported => 'Dieser Player lässt sich nicht fernsteuern';

  @override
  String get upNext => 'Als Nächstes';

  @override
  String get alwaysOnTop => 'Immer im Vordergrund';

  @override
  String get minimize => 'Minimieren';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get permissionTitle => 'Zugriff auf Benachrichtigungen nötig';

  @override
  String get permissionBody =>
      'Android teilt Mediensitzungen anderer Apps nur mit Apps, die Zugriff auf Benachrichtigungen haben. Canto liest nur Medieninfos, nie Benachrichtigungsinhalte.';

  @override
  String get grantPermission => 'Einstellungen öffnen';

  @override
  String get sourceUnavailable =>
      'Wiedergabeinfos sind auf diesem System nicht verfügbar';

  @override
  String get resumeFollow => 'Zur aktuellen Zeile';

  @override
  String lyricsFrom(String source) {
    return 'Songtext von $source';
  }

  @override
  String get seekUnsupported => 'Dieser Player unterstützt kein Spulen';

  @override
  String get commandFailed => 'Der Player hat die Anfrage nicht angenommen';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Übersetzung';

  @override
  String get romanization => 'Umschrift';

  @override
  String get noTranslationHint =>
      'Für diesen Song gibt es noch keine Übersetzung';

  @override
  String get noRomanizationHint =>
      'Für diesen Song gibt es noch keine Umschrift';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Sprache';

  @override
  String get followSystem => 'Wie System';

  @override
  String get playerActions => 'Player-Aktionen';

  @override
  String get playerActionsNone =>
      'Dieser Player bietet keine zusätzlichen Aktionen';

  @override
  String get autoTranslateLabel => 'Automatisch übersetzt';

  @override
  String get translatingHint => 'Wird übersetzt…';

  @override
  String get modelDownloadingHint =>
      'Übersetzungsmodell wird geladen (ca. 30 MB, nur beim ersten Mal)…';

  @override
  String get translateQuotaHint =>
      'Das heutige kostenlose Übersetzungskontingent ist aufgebraucht – morgen erneut versuchen';

  @override
  String get translateFailedHint => 'Automatische Übersetzung fehlgeschlagen';
}
