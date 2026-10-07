// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Nessuna riproduzione in corso';

  @override
  String get nothingPlayingHint =>
      'Riproduci qualcosa in qualsiasi app musicale. Canto legge solo le informazioni di riproduzione del sistema.';

  @override
  String get loadingLyrics => 'Ricerca del testo…';

  @override
  String get noLyrics => 'Ancora nessun testo';

  @override
  String get plainLyricsNote => 'Testo non sincronizzato (senza tempi)';

  @override
  String get lyricsError => 'Impossibile raggiungere i servizi dei testi';

  @override
  String get retry => 'Riprova';

  @override
  String get play => 'Riproduci';

  @override
  String get pause => 'Pausa';

  @override
  String get favorite => 'Preferito';

  @override
  String favoriteSent(String app) {
    return 'Inviato a $app';
  }

  @override
  String get favoriteUnsupported =>
      'Questo player non consente ad altre app di aggiungere preferiti';

  @override
  String get favoriteFailed => 'Il player ha rifiutato la richiesta';

  @override
  String get controlUnsupported =>
      'Questo player non accetta il controllo remoto';

  @override
  String get upNext => 'In coda';

  @override
  String get alwaysOnTop => 'Sempre in primo piano';

  @override
  String get minimize => 'Riduci a icona';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get permissionTitle => 'Serve l\'accesso alle notifiche';

  @override
  String get permissionBody =>
      'Android condivide le sessioni multimediali delle altre app solo con le app che hanno accesso alle notifiche. Canto legge solo le informazioni multimediali, mai il contenuto delle notifiche.';

  @override
  String get grantPermission => 'Apri impostazioni';

  @override
  String get sourceUnavailable =>
      'Le informazioni di riproduzione non sono disponibili su questo sistema';

  @override
  String get resumeFollow => 'Torna alla riga corrente';

  @override
  String lyricsFrom(String source) {
    return 'Testo da $source';
  }

  @override
  String get seekUnsupported =>
      'Questo player non consente di spostarsi nel brano';

  @override
  String get commandFailed => 'Il player non ha accettato la richiesta';

  @override
  String get instrumental => 'Strumentale';

  @override
  String get translation => 'Traduzione';

  @override
  String get romanization => 'Traslitterazione';

  @override
  String get noTranslationHint => 'Nessuna traduzione per questo brano';

  @override
  String get noRomanizationHint => 'Nessuna traslitterazione per questo brano';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Lingua';

  @override
  String get followSystem => 'Come il sistema';

  @override
  String get playerActions => 'Azioni del player';

  @override
  String get playerActionsNone => 'Questo player non offre azioni aggiuntive';

  @override
  String get autoTranslateLabel => 'Traduzione automatica';

  @override
  String get translatingHint => 'Traduzione in corso…';

  @override
  String get modelDownloadingHint =>
      'Download del modello di traduzione (circa 30 MB, solo la prima volta)…';

  @override
  String get translateQuotaHint =>
      'Quota di traduzione gratuita di oggi esaurita: riprova domani';

  @override
  String get translateFailedHint => 'Traduzione automatica non riuscita';
}
