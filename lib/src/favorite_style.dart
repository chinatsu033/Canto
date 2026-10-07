enum FavoriteIcon { plus, heart, star }

const _cnApps = [
  'com.tencent.qqmusic', 'qqmusic', 'com.netease.cloudmusic', 'cloudmusic',
  'netease', 'com.kugou', 'kugou', 'cn.kuwo', 'kuwo', 'com.tencent.blackkey',
  'com.luna.music', 'migu', 'cmccwm.mobilemusic', 'com.xiami',
];

/// Picks the favorite icon based on the source player's id.
FavoriteIcon favoriteIconFor(String sourceApp) {
  final s = sourceApp.toLowerCase();
  if (s.contains('spotify')) return FavoriteIcon.plus;
  if (s.contains('com.apple.music') ||
      s == 'com.apple.itunes' ||
      s.contains('applemusic') ||
      s.contains('apple.music') ||
      s.contains('appleinc.applemusic')) {
    return FavoriteIcon.star;
  }
  for (final c in _cnApps) {
    if (s.contains(c)) return FavoriteIcon.heart;
  }
  return FavoriteIcon.heart;
}
