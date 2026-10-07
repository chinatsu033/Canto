// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Nothing is playing';

  @override
  String get nothingPlayingHint =>
      'Play something in any music app. Canto only reads the system\'s now-playing info.';

  @override
  String get loadingLyrics => 'Looking up lyrics…';

  @override
  String get noLyrics => 'No lyrics yet';

  @override
  String get plainLyricsNote => 'Unsynced lyrics (no timing)';

  @override
  String get lyricsError => 'Couldn\'t reach the lyrics services';

  @override
  String get retry => 'Retry';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get favorite => 'Favorite';

  @override
  String favoriteSent(String app) {
    return 'Sent to $app';
  }

  @override
  String get favoriteUnsupported =>
      'This player doesn\'t let other apps favorite tracks';

  @override
  String get favoriteFailed => 'The player rejected the request';

  @override
  String get controlUnsupported => 'This player doesn\'t accept remote control';

  @override
  String get upNext => 'Up next';

  @override
  String get alwaysOnTop => 'Always on top';

  @override
  String get minimize => 'Minimize';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get permissionTitle => 'Notification access needed';

  @override
  String get permissionBody =>
      'Android only shares other apps\' media sessions with apps that have notification access. Canto reads only media info, never notification content.';

  @override
  String get grantPermission => 'Open settings';

  @override
  String get sourceUnavailable =>
      'Now-playing info isn\'t available on this system';

  @override
  String get resumeFollow => 'Back to current line';

  @override
  String lyricsFrom(String source) {
    return 'Lyrics from $source';
  }

  @override
  String get seekUnsupported => 'This player doesn\'t allow seeking';

  @override
  String get commandFailed => 'The player didn\'t accept the request';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Translation';

  @override
  String get romanization => 'Romanization';

  @override
  String get noTranslationHint => 'No translation for this song yet';

  @override
  String get noRomanizationHint => 'No romanization for this song yet';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow system';

  @override
  String get playerActions => 'Player actions';

  @override
  String get playerActionsNone => 'This player exposes no extra actions';
}
