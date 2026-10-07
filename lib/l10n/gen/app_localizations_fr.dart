// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Aucune lecture en cours';

  @override
  String get nothingPlayingHint =>
      'Lancez un morceau dans n\'importe quelle appli musicale. Canto lit seulement les infos de lecture du système.';

  @override
  String get loadingLyrics => 'Recherche des paroles…';

  @override
  String get noLyrics => 'Pas encore de paroles';

  @override
  String get plainLyricsNote => 'Paroles non synchronisées (sans minutage)';

  @override
  String get lyricsError => 'Impossible de joindre les services de paroles';

  @override
  String get retry => 'Réessayer';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get favorite => 'Favori';

  @override
  String favoriteSent(String app) {
    return 'Envoyé à $app';
  }

  @override
  String get favoriteUnsupported =>
      'Ce lecteur ne permet pas aux autres applis d\'ajouter des favoris';

  @override
  String get favoriteFailed => 'Le lecteur a refusé la demande';

  @override
  String get controlUnsupported =>
      'Ce lecteur n\'accepte pas la commande à distance';

  @override
  String get upNext => 'À suivre';

  @override
  String get alwaysOnTop => 'Toujours au premier plan';

  @override
  String get minimize => 'Réduire';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get permissionTitle => 'Accès aux notifications requis';

  @override
  String get permissionBody =>
      'Android ne partage les sessions multimédias des autres applis qu\'avec les applis ayant accès aux notifications. Canto lit uniquement les infos multimédias, jamais le contenu des notifications.';

  @override
  String get grantPermission => 'Ouvrir les réglages';

  @override
  String get sourceUnavailable =>
      'Les infos de lecture ne sont pas disponibles sur ce système';

  @override
  String get resumeFollow => 'Revenir à la ligne en cours';

  @override
  String lyricsFrom(String source) {
    return 'Paroles : $source';
  }

  @override
  String get seekUnsupported =>
      'Ce lecteur ne permet pas de changer la position';

  @override
  String get commandFailed => 'Le lecteur n\'a pas accepté la demande';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Traduction';

  @override
  String get romanization => 'Romanisation';

  @override
  String get noTranslationHint => 'Pas encore de traduction pour ce titre';

  @override
  String get noRomanizationHint => 'Pas encore de romanisation pour ce titre';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Langue';

  @override
  String get followSystem => 'Suivre le système';

  @override
  String get playerActions => 'Actions du lecteur';

  @override
  String get playerActionsNone =>
      'Ce lecteur ne propose aucune action supplémentaire';
}
