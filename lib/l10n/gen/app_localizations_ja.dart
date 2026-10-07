// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => '再生中のメディアはありません';

  @override
  String get nothingPlayingHint =>
      '任意の音楽アプリで再生してください。Canto はシステムの再生中情報を読み取るだけです。';

  @override
  String get loadingLyrics => '歌詞を検索中…';

  @override
  String get noLyrics => '歌詞が見つかりません';

  @override
  String get plainLyricsNote => '同期なしの歌詞（タイミングなし）';

  @override
  String get lyricsError => 'LRCLIB に接続できません';

  @override
  String get retry => '再試行';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get favorite => 'お気に入り';

  @override
  String favoriteSent(String app) {
    return '$app に送信しました';
  }

  @override
  String get favoriteUnsupported => 'このプレーヤーは外部からのお気に入り登録に対応していません';

  @override
  String get favoriteFailed => 'プレーヤーがリクエストを拒否しました';

  @override
  String get controlUnsupported => 'このプレーヤーはリモート操作に対応していません';

  @override
  String get upNext => '次に再生';

  @override
  String get alwaysOnTop => '常に手前に表示';

  @override
  String get minimize => '最小化';

  @override
  String get close => '閉じる';

  @override
  String get back => '戻る';

  @override
  String get permissionTitle => '通知へのアクセスが必要です';

  @override
  String get permissionBody =>
      'Android は通知へのアクセス権を持つアプリにのみ他アプリのメディアセッションを公開します。Canto はメディア情報のみを読み取り、通知の内容は読み取りません。';

  @override
  String get grantPermission => '設定を開く';

  @override
  String get sourceUnavailable => 'このシステムでは再生中情報を取得できません';

  @override
  String get lyricsBy => '歌詞提供：LRCLIB';

  @override
  String get resumeFollow => '現在の行に戻る';
}
