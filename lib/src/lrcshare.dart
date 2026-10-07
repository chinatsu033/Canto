import 'dart:convert';
import 'lrc.dart';
import 'lrcapi.dart' show similarity, confidentMatch;
import 'lrclib.dart';
import 'lyrics_provider.dart';
import 'models.dart';
import 'net.dart';

/// One LrcShare lyric version (original / translation / romanization).
class LsVersion {
  final String lang;
  final String kind;
  final List<LrcLine> rows; // timed rows only
  const LsVersion(this.lang, this.kind, this.rows);
}

class LsSong {
  final String id;
  final String? cover;
  const LsSong(this.id, this.cover);
}

final _wordTag = RegExp(r'<\d+(?::\d+)?>');

/// Parses `/v1/lyric/:id?lyric_lines=1` -> versions (metadata rows dropped).
List<LsVersion> parseLsVersions(Map<String, dynamic> body) {
  final ll = (body['data'] as Map?)?['lyric_lines'] as Map?;
  final vs = ll?['versions'] as List?;
  if (vs == null) return const [];
  return [
    for (final v in vs.whereType<Map>())
      LsVersion(
        '${v['lang'] ?? ''}',
        '${v['kind'] ?? ''}',
        [
          for (final r in (v['rows'] as List? ?? const []).whereType<Map>())
            if (r['time_ms'] is num)
              LrcLine(Duration(milliseconds: (r['time_ms'] as num).toInt()),
                  '${r['text'] ?? ''}'.replaceAll(_wordTag, '').trim()),
        ]..sort((a, b) => a.time.compareTo(b.time)),
      )
  ];
}

/// LrcShare client: small curated catalog with original / translation /
/// romanization versions. Requests go through [HttpGate] (sequential,
/// ≥300 ms apart, 429 backoff, no cache-busting params).
class LrcShareClient {
  final HttpGate gate;
  LrcShareClient(this.gate);
  static const _host = 'api.lrcshare.com';

  Future<LsSong?> find(String title, String artist) async {
    final r = await gate.get(Uri.https(_host, '/v1/search', {
      'title': title,
      if (artist.isNotEmpty) 'artist': primaryArtist(artist),
      'type': 'song',
    }));
    if (r.statusCode != 200) return null;
    final items = ((jsonDecode(utf8.decode(r.bodyBytes)) as Map)['data']?['items'] as List?) ?? const [];
    Map? best;
    var bestScore = 0.0;
    for (final it in items.whereType<Map>()) {
      final names = [for (final a in (it['artists'] as List? ?? const []).whereType<Map>()) '${a['name']}'];
      final t = similarity(title, '${it['title']}');
      final a = artist.isEmpty ? .5 : names.map((n) => similarity(primaryArtist(artist), n)).fold(0.0, (x, y) => x > y ? x : y);
      final s = t * .65 + a * .35;
      if (!confidentMatch(t, a, artist.isNotEmpty)) continue;
      if (s > bestScore) {
        bestScore = s;
        best = it;
      }
    }
    if (best == null) return null;
    return LsSong('${best['id']}', (best['album'] as Map?)?['cover'] as String?);
  }

  Future<List<LsVersion>> versions(String id) async {
    final r = await gate.get(Uri.https(_host, '/v1/lyric/${Uri.encodeComponent(id)}', {
      'lyric_translation_lang': 'all',
      'lyric_format': 'line',
      'lyric_lines': '1',
    }));
    if (r.statusCode != 200) return const [];
    return parseLsVersions(jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
  }
}

/// Everything LrcShare knows about the current track (memory only).
class LsTrackData {
  final LsSong song;
  final List<LsVersion> versions;
  const LsTrackData(this.song, this.versions);
  LsVersion? get original =>
      versions.where((v) => v.kind == 'original' && v.rows.isNotEmpty).firstOrNull;
}

/// Fetches and memoises LrcShare data per track key, so the lyrics provider,
/// translation/romanization and cover fallback share one search + one lyric
/// request per track.
class LrcShareSession {
  final LrcShareClient client;
  LrcShareSession(this.client);
  String? _key;
  Future<LsTrackData?>? _pending;

  Future<LsTrackData?> forTrack(NowPlaying np) {
    if (_key == np.trackKey && _pending != null) return _pending!;
    _key = np.trackKey;
    return _pending = () async {
      try {
        final song = await client.find(np.title, np.artist);
        if (song == null) return null;
        return LsTrackData(song, await client.versions(song.id));
      } catch (_) {
        return null;
      }
    }();
  }

  void clear() {
    _key = null;
    _pending = null;
  }
}

class LrcShareProvider implements LyricsProvider {
  final LrcShareSession session;
  LrcShareProvider(this.session);
  @override
  String get name => 'LrcShare';
  @override
  Future<LyricsResult> fetch(NowPlaying np) async {
    final d = await session.forTrack(np);
    final o = d?.original;
    if (o == null) return const NoLyrics();
    return SyncedLyrics(o.rows);
  }
}

String _base(String lang) => lang.toLowerCase().split('-').first;

/// Translation target: zh-Hans preferred; English if the original is Chinese.
LsVersion? pickTranslation(List<LsVersion> vs, String originalLang) {
  final tr = vs.where((v) => v.kind == 'translation' && v.rows.isNotEmpty).toList();
  if (tr.isEmpty) return null;
  if (_base(originalLang) == 'zh') {
    return tr.where((v) => _base(v.lang) == 'en').firstOrNull;
  }
  final l = tr.map((v) => v.lang.toLowerCase()).toList();
  for (final want in ['zh-hans', 'zh-cn', 'zh-sg', 'zh']) {
    final i = l.indexWhere((x) => x == want || (want == 'zh' && x.startsWith('zh') && !x.contains('hant')));
    if (i >= 0) return tr[i];
  }
  return tr.where((v) => _base(v.lang) == 'zh').firstOrNull ?? tr.where((v) => _base(v.lang) == 'en').firstOrNull;
}

/// Romanization: ja-Latn / ko-Latn / zh-Latn-pinyin (jyutping as fallback).
LsVersion? pickRomanization(List<LsVersion> vs, String originalLang) {
  final ro = vs.where((v) => v.kind == 'romanization' && v.rows.isNotEmpty).toList();
  final b = _base(originalLang);
  final wants = switch (b) {
    'ja' => ['ja-latn'],
    'ko' => ['ko-latn'],
    'zh' => ['zh-latn-pinyin', 'zh-latn-jyutping'],
    _ => const <String>[],
  };
  for (final w in wants) {
    final m = ro.where((v) => v.lang.toLowerCase() == w).firstOrNull;
    if (m != null) return m;
  }
  return null;
}

/// Aligns secondary rows to the displayed original lines BY TIMESTAMP ONLY:
/// each displayed line i gets the secondary row whose time is within
/// [tolerance] of line i's time; the displayed timestamp is reused (no
/// re-timing). Returns null when fewer than [minCoverage] of the non-empty
/// displayed lines can be matched (=> toggle greyed out).
Map<int, String>? alignByTimestamp(List<LrcLine> displayed, List<LrcLine> secondary,
    {Duration tolerance = const Duration(milliseconds: 600), double minCoverage = .6}) {
  if (displayed.isEmpty || secondary.isEmpty) return null;
  final out = <int, String>{};
  var j = 0;
  var needed = 0;
  for (var i = 0; i < displayed.length; i++) {
    final t = displayed[i].time;
    if (displayed[i].text.trim().isEmpty) continue;
    needed++;
    while (j < secondary.length && secondary[j].time < t - tolerance) {
      j++;
    }
    if (j < secondary.length && (secondary[j].time - t).abs() <= tolerance && secondary[j].text.isNotEmpty) {
      out[i] = secondary[j].text;
      j++;
    }
  }
  if (needed == 0 || out.length / needed < minCoverage) return null;
  return out;
}

/// Language of the original LrcShare version (fallback: guess from text).
String originalLangOf(LsTrackData d, List<LrcLine> displayed) {
  final o = d.original;
  if (o != null && o.lang.isNotEmpty) return o.lang;
  return guessLang(displayed.map((l) => l.text).join());
}

String guessLang(String s) {
  if (RegExp(r'[\u3040-\u30ff]').hasMatch(s)) return 'ja';
  if (RegExp(r'[\uac00-\ud7af]').hasMatch(s)) return 'ko';
  if (RegExp(r'[\u4e00-\u9fff]').hasMatch(s)) return 'zh';
  return 'en';
}
