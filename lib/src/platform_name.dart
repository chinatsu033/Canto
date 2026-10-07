/// Human-readable music platform name from package / bundle id / AUMID /
/// MPRIS bus name; falls back to the app's display name.
String platformName(String sourceApp, String displayName) {
  final s = sourceApp.toLowerCase();
  const map = <String, String>{
    'spotify': 'Spotify',
    'com.apple.music': 'Apple Music',
    'com.apple.android.music': 'Apple Music',
    'applemusic': 'Apple Music',
    'com.apple.itunes': 'iTunes',
    'com.tencent.qqmusic': 'QQ音乐',
    'qqmusic': 'QQ音乐',
    'com.netease.cloudmusic': '网易云音乐',
    'cloudmusic': '网易云音乐',
    'netease': '网易云音乐',
    'com.kugou': '酷狗音乐',
    'kugou': '酷狗音乐',
    'cn.kuwo': '酷我音乐',
    'kuwo': '酷我音乐',
    'com.luna.music': '汽水音乐',
    'cmccwm.mobilemusic': '咪咕音乐',
    'migu': '咪咕音乐',
    'youtube.music': 'YouTube Music',
    'com.google.android.apps.youtube.music': 'YouTube Music',
    'com.google.android.youtube': 'YouTube',
    'deezer': 'Deezer',
    'tidal': 'TIDAL',
    'amazon.mp3': 'Amazon Music',
    'amazonmusic': 'Amazon Music',
    'soundcloud': 'SoundCloud',
    'jp.linecorp.linemusic': 'LINE MUSIC',
    'com.kkbox': 'KKBOX',
    'kkbox': 'KKBOX',
    'com.joox': 'JOOX',
    'vlc': 'VLC',
    'firefox': 'Firefox',
    'chromium': 'Chromium',
    'chrome': 'Chrome',
    'msedge': 'Microsoft Edge',
    'rhythmbox': 'Rhythmbox',
    'zunemusic': 'Media Player',
    'microsoft.zunemusic': 'Media Player',
  };
  for (final e in map.entries) {
    if (s.contains(e.key)) return e.value;
  }
  if (displayName.isNotEmpty && displayName != sourceApp) return displayName;
  if (s.startsWith('org.mpris.mediaplayer2.')) return sourceApp.substring(23);
  return displayName.isNotEmpty ? displayName : sourceApp;
}
