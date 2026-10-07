// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'No se está reproduciendo nada';

  @override
  String get nothingPlayingHint =>
      'Reproduce algo en cualquier app de música. Canto solo lee la información de reproducción del sistema.';

  @override
  String get loadingLyrics => 'Buscando la letra…';

  @override
  String get noLyrics => 'Aún no hay letra';

  @override
  String get plainLyricsNote => 'Letra sin sincronizar (sin tiempos)';

  @override
  String get lyricsError => 'No se pudo conectar con los servicios de letras';

  @override
  String get retry => 'Reintentar';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausa';

  @override
  String get favorite => 'Favorito';

  @override
  String favoriteSent(String app) {
    return 'Enviado a $app';
  }

  @override
  String get favoriteUnsupported =>
      'Este reproductor no permite que otras apps marquen favoritos';

  @override
  String get favoriteFailed => 'El reproductor rechazó la solicitud';

  @override
  String get controlUnsupported => 'Este reproductor no acepta control remoto';

  @override
  String get upNext => 'A continuación';

  @override
  String get alwaysOnTop => 'Siempre visible';

  @override
  String get minimize => 'Minimizar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get permissionTitle => 'Se necesita acceso a las notificaciones';

  @override
  String get permissionBody =>
      'Android solo comparte las sesiones multimedia de otras apps con las apps que tienen acceso a las notificaciones. Canto solo lee la información multimedia, nunca el contenido de las notificaciones.';

  @override
  String get grantPermission => 'Abrir ajustes';

  @override
  String get sourceUnavailable =>
      'La información de reproducción no está disponible en este sistema';

  @override
  String get resumeFollow => 'Volver a la línea actual';

  @override
  String lyricsFrom(String source) {
    return 'Letra de $source';
  }

  @override
  String get seekUnsupported =>
      'Este reproductor no permite cambiar la posición';

  @override
  String get commandFailed => 'El reproductor no aceptó la solicitud';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Traducción';

  @override
  String get romanization => 'Romanización';

  @override
  String get noTranslationHint => 'Esta canción aún no tiene traducción';

  @override
  String get noRomanizationHint => 'Esta canción aún no tiene romanización';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Idioma';

  @override
  String get followSystem => 'Igual que el sistema';

  @override
  String get playerActions => 'Acciones del reproductor';

  @override
  String get playerActionsNone =>
      'Este reproductor no ofrece acciones adicionales';

  @override
  String get autoTranslateLabel => 'Traducción automática';

  @override
  String get translatingHint => 'Traduciendo…';

  @override
  String get modelDownloadingHint =>
      'Descargando el modelo de traducción (unos 30 MB, solo la primera vez)…';

  @override
  String get translateQuotaHint =>
      'Se agotó la cuota gratuita de traducción de hoy; inténtalo mañana';

  @override
  String get translateFailedHint => 'Falló la traducción automática';
}
