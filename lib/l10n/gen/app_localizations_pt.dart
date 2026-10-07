// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Nada tocando agora';

  @override
  String get nothingPlayingHint =>
      'Toque algo em qualquer app de música. O Canto só lê as informações de reprodução do sistema.';

  @override
  String get loadingLyrics => 'Procurando a letra…';

  @override
  String get noLyrics => 'Ainda sem letra';

  @override
  String get plainLyricsNote => 'Letra não sincronizada (sem tempos)';

  @override
  String get lyricsError => 'Não foi possível acessar os serviços de letras';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get play => 'Tocar';

  @override
  String get pause => 'Pausar';

  @override
  String get favorite => 'Favoritar';

  @override
  String favoriteSent(String app) {
    return 'Enviado para $app';
  }

  @override
  String get favoriteUnsupported =>
      'Este player não permite que outros apps favoritem músicas';

  @override
  String get favoriteFailed => 'O player recusou o pedido';

  @override
  String get controlUnsupported => 'Este player não aceita controle remoto';

  @override
  String get upNext => 'A seguir';

  @override
  String get alwaysOnTop => 'Sempre no topo';

  @override
  String get minimize => 'Minimizar';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get permissionTitle => 'É preciso acesso às notificações';

  @override
  String get permissionBody =>
      'O Android só compartilha as sessões de mídia de outros apps com apps que têm acesso às notificações. O Canto lê apenas as informações de mídia, nunca o conteúdo das notificações.';

  @override
  String get grantPermission => 'Abrir configurações';

  @override
  String get sourceUnavailable =>
      'As informações de reprodução não estão disponíveis neste sistema';

  @override
  String get resumeFollow => 'Voltar à linha atual';

  @override
  String lyricsFrom(String source) {
    return 'Letra de $source';
  }

  @override
  String get seekUnsupported => 'Este player não permite avançar ou voltar';

  @override
  String get commandFailed => 'O player não aceitou o pedido';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Tradução';

  @override
  String get romanization => 'Romanização';

  @override
  String get noTranslationHint => 'Esta música ainda não tem tradução';

  @override
  String get noRomanizationHint => 'Esta música ainda não tem romanização';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Idioma';

  @override
  String get followSystem => 'Seguir o sistema';

  @override
  String get playerActions => 'Ações do player';

  @override
  String get playerActionsNone => 'Este player não oferece ações extras';
}
