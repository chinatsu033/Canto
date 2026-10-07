import 'dart:convert';
import 'lrc.dart';
import 'lyrics_provider.dart';
import 'models.dart';
import 'net.dart';
import 'lrcapi.dart' show similarity, confidentMatch;

const userAgent = 'Canto/0.1.3 (https://github.com/chinatsu033/Canto)';

sealed class LyricsResult {
  const LyricsResult();
}

class SyncedLyrics extends LyricsResult {
  final List<LrcLine> lines;
  const SyncedLyrics(this.lines);
}

class PlainLyrics extends LyricsResult {
  final List<String> lines;
  const PlainLyrics(this.lines);
}

class NoLyrics extends LyricsResult {
  const NoLyrics();
}

class LyricsError extends LyricsResult {
  const LyricsError();
}

/// Source says the track is instrumental (纯音乐) and has no lyrics.
class Instrumental extends LyricsResult {
  const Instrumental();
}

/// Turns one LRCLIB record into a result (synced > plain > none).
LyricsResult resultFromRecord(Map<String, dynamic>? rec) {
  if (rec == null) return const NoLyrics();
  final synced = rec['syncedLyrics'];
  if (synced is String && synced.trim().isNotEmpty) {
    final lines = parseLrc(synced);
    if (lines.isNotEmpty) return SyncedLyrics(lines);
  }
  final plain = rec['plainLyrics'];
  if (plain is String && plain.trim().isNotEmpty) {
    return PlainLyrics(plain.split(RegExp(r'\r?\n')));
  }
  if (rec['instrumental'] == true) return const Instrumental();
  return const NoLyrics();
}

/// Normalises a title for LRCLIB's free-text search: strips "feat.",
/// remaster/live/version tags and bracketed parts, folds full-width
/// characters to ASCII and collapses punctuation/whitespace.
String cleanTitle(String title) {
  var s = _foldWidth(title);
  s = s.replaceAll(RegExp(r'\s*[\(\[\{（【「『][^\)\]\}）】」』]*[\)\]\}）】」』]'), ' ');
  s = s.replaceAll(
      RegExp(r'\s+[-–—]\s+.*\b(remaster(ed)?|live|version|ver\.?|edit|mix|mono|stereo|demo|acoustic|instrumental)\b.*$',
          caseSensitive: false),
      ' ');
  s = s.replaceAll(RegExp(r'\s+(feat\.?|ft\.?|featuring)\s+.*$', caseSensitive: false), ' ');
  s = s.replaceAll(RegExp(r'''[!"#$%&'*+,./:;<=>?@\\^_`|~·・、。，！？：；“”‘’]'''), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Primary artist only ("A, B & C feat. D" -> "A").
String primaryArtist(String artist) {
  final s = _foldWidth(artist)
      .split(RegExp(r'\s*(,|&|、|/|;| x | feat\.? | ft\.? )\s*', caseSensitive: false))
      .first;
  return s.trim();
}

String _foldWidth(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    if (r >= 0xFF01 && r <= 0xFF5E) {
      b.writeCharCode(r - 0xFEE0);
    } else if (r == 0x3000) {
      b.write(' ');
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}

/// LRCLIB client (the only lyrics source). Lyrics are only kept in memory for
/// the current track (see [LyricsCache]); nothing is written to disk, logged,
/// or uploaded.
class LrclibClient {
  final HttpGate gate;
  LrclibClient([HttpGate? g]) : gate = g ?? HttpGate();
  static const _base = 'lrclib.net';

  Future<Map<String, dynamic>?> _get(Map<String, String> q) async {
    final r = await gate.get(Uri.https(_base, '/api/get', q));
    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) throw Exception('lrclib ${r.statusCode}');
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _search(Map<String, String> q) async {
    final r = await gate.get(Uri.https(_base, '/api/search', q));
    if (r.statusCode != 200) throw Exception('lrclib ${r.statusCode}');
    return (jsonDecode(utf8.decode(r.bodyBytes)) as List).cast<Map<String, dynamic>>();
  }

  /// Strategy: /api/get (full) -> /api/get (no album) -> /api/search
  /// (track+artist) -> /api/search (q = cleaned title + primary artist).
  /// Synced results with the closest duration win; plain is a fallback.
  Future<LyricsResult> fetch({
    required String title,
    required String artist,
    String album = '',
    Duration? duration,
  }) async {
    var anyOk = false;
    final candidates = <Map<String, dynamic>>[];

    Future<void> attempt(Future<Object?> Function() f) async {
      try {
        final v = await f();
        anyOk = true;
        if (v is Map<String, dynamic>) candidates.add(v);
        if (v is List<Map<String, dynamic>>) {
          // Search results must clearly match title+artist (never another song).
          candidates.addAll(v.where((r) => confidentMatch(similarity(title, '${r['trackName'] ?? r['name'] ?? ''}'),
              similarity(primaryArtist(artist), primaryArtist('${r['artistName'] ?? ''}')), artist.isNotEmpty)));
        }
      } catch (_) {}
    }

    if (duration != null && duration.inSeconds > 0) {
      final d = '${duration.inSeconds}';
      if (album.isNotEmpty) {
        await attempt(() => _get({'track_name': title, 'artist_name': artist, 'album_name': album, 'duration': d}));
        if (isCloseSynced(pickBest(candidates, duration), duration)) return resultFromRecord(pickBest(candidates, duration));
      }
      await attempt(() => _get({'track_name': title, 'artist_name': artist, 'duration': d}));
      if (candidates.isNotEmpty && candidates.every((r) => resultFromRecord(r) is Instrumental)) return const Instrumental();
      if (isCloseSynced(pickBest(candidates, duration), duration)) return resultFromRecord(pickBest(candidates, duration));
    }
    await attempt(() => _search({'track_name': title, if (artist.isNotEmpty) 'artist_name': artist}));
    if (!isCloseSynced(pickBest(candidates, duration), duration)) {
      final q = '${cleanTitle(title)} ${primaryArtist(artist)}'.trim();
      if (q.isNotEmpty) await attempt(() => _search({'q': q}));
    }
    final best = pickBest(candidates, duration);
    if (best != null) return resultFromRecord(best);
    if (candidates.any((r) => r['instrumental'] == true)) return const Instrumental();
    return anyOk ? const NoLyrics() : const LyricsError();
  }
}

bool isCloseSynced(Map<String, dynamic>? r, Duration? d) {
  if (r == null || !((r['syncedLyrics'] as String?)?.trim().isNotEmpty ?? false)) return false;
  if (d == null || r['duration'] is! num) return true;
  return ((r['duration'] as num) - d.inSeconds).abs() <= 3;
}

/// Synced beats plain; among them the duration closest to the track wins
/// (within ±3 s strongly preferred).
Map<String, dynamic>? pickBest(List<Map<String, dynamic>> list, Duration? duration) {
  final usable = list.where((r) => resultFromRecord(r) is SyncedLyrics || resultFromRecord(r) is PlainLyrics).toList();
  if (usable.isEmpty) return null;
  double score(Map<String, dynamic> r) {
    var s = 0.0;
    if ((r['syncedLyrics'] as String?)?.trim().isNotEmpty ?? false) {
      s += 100;
    } else if ((r['plainLyrics'] as String?)?.trim().isNotEmpty ?? false) {
      s += 10;
    }
    if (duration != null && r['duration'] is num) {
      final d = ((r['duration'] as num) - duration.inSeconds).abs().toDouble();
      s += d <= 3 ? 50 - d : (20 - d).clamp(0, 20) / 2;
    }
    return s;
  }

  usable.sort((a, b) => score(b).compareTo(score(a)));
  return usable.first;
}

/// The LRCLIB [LyricsProvider].
class LrclibProvider implements LyricsProvider {
  final LrclibClient client;
  LrclibProvider(HttpGate gate) : client = LrclibClient(gate);
  @override
  String get name => 'LRCLIB';
  @override
  Future<LyricsResult> fetch(NowPlaying np) =>
      client.fetch(title: np.title, artist: np.artist, album: np.album, duration: np.duration);
}

/// Holds lyrics for the current track only; dropped on track change.
class LyricsCache {
  String? _key;
  LyricsResult? _value;
  LyricsResult? get(String key) => key == _key ? _value : null;
  void put(String key, LyricsResult v) {
    _key = key;
    _value = v;
  }
  void clear() {
    _key = null;
    _value = null;
  }
}
