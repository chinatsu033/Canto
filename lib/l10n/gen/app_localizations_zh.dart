// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => '当前没有正在播放的内容';

  @override
  String get nothingPlayingHint => '在任意音乐 App 中播放音乐。Canto 只读取系统的正在播放信息。';

  @override
  String get loadingLyrics => '正在查找歌词…';

  @override
  String get noLyrics => '未找到歌词';

  @override
  String get plainLyricsNote => '非同步歌词（无时间轴）';

  @override
  String get lyricsError => '无法连接 LRCLIB';

  @override
  String get retry => '重试';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get favorite => '收藏';

  @override
  String favoriteSent(String app) {
    return '已发送到 $app';
  }

  @override
  String get favoriteUnsupported => '该播放器不支持由其他 App 收藏';

  @override
  String get favoriteFailed => '播放器拒绝了请求';

  @override
  String get controlUnsupported => '该播放器不接受远程控制';

  @override
  String get upNext => '播放队列';

  @override
  String get alwaysOnTop => '窗口置顶';

  @override
  String get minimize => '最小化';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get permissionTitle => '需要通知使用权';

  @override
  String get permissionBody =>
      'Android 只向拥有通知使用权的 App 提供其他 App 的媒体会话。Canto 只读取媒体信息，不读取通知内容。';

  @override
  String get grantPermission => '打开设置';

  @override
  String get sourceUnavailable => '此系统无法提供正在播放信息';

  @override
  String get lyricsBy => '歌词来自 LRCLIB';

  @override
  String get resumeFollow => '回到当前行';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => '目前沒有正在播放的內容';

  @override
  String get nothingPlayingHint => '在任意音樂 App 中播放音樂。Canto 只讀取系統的正在播放資訊。';

  @override
  String get loadingLyrics => '正在查找歌詞…';

  @override
  String get noLyrics => '找不到歌詞';

  @override
  String get plainLyricsNote => '非同步歌詞（無時間軸）';

  @override
  String get lyricsError => '無法連線 LRCLIB';

  @override
  String get retry => '重試';

  @override
  String get play => '播放';

  @override
  String get pause => '暫停';

  @override
  String get favorite => '收藏';

  @override
  String favoriteSent(String app) {
    return '已傳送到 $app';
  }

  @override
  String get favoriteUnsupported => '該播放器不支援由其他 App 收藏';

  @override
  String get favoriteFailed => '播放器拒絕了請求';

  @override
  String get controlUnsupported => '該播放器不接受遠端控制';

  @override
  String get upNext => '播放佇列';

  @override
  String get alwaysOnTop => '視窗置頂';

  @override
  String get minimize => '最小化';

  @override
  String get close => '關閉';

  @override
  String get back => '返回';

  @override
  String get permissionTitle => '需要通知存取權';

  @override
  String get permissionBody =>
      'Android 只向擁有通知存取權的 App 提供其他 App 的媒體工作階段。Canto 只讀取媒體資訊，不讀取通知內容。';

  @override
  String get grantPermission => '開啟設定';

  @override
  String get sourceUnavailable => '此系統無法提供正在播放資訊';

  @override
  String get lyricsBy => '歌詞來自 LRCLIB';

  @override
  String get resumeFollow => '回到目前行';
}
