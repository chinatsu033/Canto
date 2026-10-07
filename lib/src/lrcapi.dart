import 'dart:convert';
import 'lrc.dart';
import 'lrclib.dart';
import 'lyrics_provider.dart';
import 'models.dart';
import 'net.dart';

/// LrcAPI (api.lrc.cx), a free Chinese-oriented lyrics API.
/// Documented v1 endpoints are tried first; the service currently answers 404
/// there, so the long-standing `/jsonapi` search (JSON array with title and
/// artist, verified by similarity) is the fallback. Only timestamped results
/// count.
class LrcApiProvider implements LyricsProvider {
  final HttpGate gate;
  LrcApiProvider(this.gate);
  static const _host = 'api.lrc.cx';
  @override
  String get name => 'LrcAPI';

  @override
  Future<LyricsResult> fetch(NowPlaying np) async {
    final q = {
      'title': np.title,
      if (np.artist.isNotEmpty) 'artist': np.artist,
      if (np.album.isNotEmpty) 'album': np.album,
    };
    var anyOk = false;
    // 1) single: LRC text. Only the documented v1 endpoint is trusted here;
    // the legacy `/lyrics` endpoint returns a best guess with no metadata
    // (can be a different song), so it is NOT used — never show wrong lyrics.
    for (final path in ['/api/v1/lyrics/single']) {
      try {
        final r = await gate.get(Uri.https(_host, path, q));
        anyOk = true;
        if (r.statusCode == 200) {
          final lines = parseLrc(utf8.decode(r.bodyBytes, allowMalformed: true));
          if (lines.where((l) => l.text.isNotEmpty).length >= 2) return SyncedLyrics(lines);
          break;
        }
        if (r.statusCode != 404) break;
      } on RateLimited {
        return const LyricsError();
      } catch (_) {}
    }
    // 2) search: JSON array, pick closest title+artist with timestamps
    for (final path in ['/api/v1/lyrics/advance', '/jsonapi']) {
      try {
        final r = await gate.get(Uri.https(_host, path, q));
        anyOk = true;
        if (r.statusCode == 200) {
          final list = jsonDecode(utf8.decode(r.bodyBytes));
          if (list is List) {
            final best = bestLrcApiMatch(list.whereType<Map<String, dynamic>>().toList(), np.title, np.artist);
            if (best != null) return SyncedLyrics(best);
          }
          break;
        }
        if (r.statusCode != 404) break;
      } on RateLimited {
        return const LyricsError();
      } catch (_) {}
    }
    return anyOk ? const NoLyrics() : const LyricsError();
  }
}

String _norm(String s) => cleanTitle(s).toLowerCase().replaceAll(' ', '');

/// Similarity in [0,1] between two strings (normalised, bigram Dice).
double similarity(String a, String b) {
  final x = _norm(a), y = _norm(b);
  if (x.isEmpty || y.isEmpty) return 0;
  if (x == y) return 1;
  Set<String> grams(String s) => {for (var i = 0; i < s.length - 1; i++) s.substring(i, i + 2)};
  final gx = grams(x), gy = grams(y);
  if (gx.isEmpty || gy.isEmpty) return x.contains(y) || y.contains(x) ? .8 : 0;
  final inter = gx.intersection(gy).length;
  return 2 * inter / (gx.length + gy.length);
}

/// Picks the entry whose title+artist best match and that has timestamped
/// lyrics (`lyrics` or `lrc` field). Returns parsed lines or null.
List<LrcLine>? bestLrcApiMatch(List<Map<String, dynamic>> items, String title, String artist) {
  List<LrcLine>? bestLines;
  var bestScore = 0.0;
  for (final e in items) {
    final text = (e['lyrics'] ?? e['lrc']) as String?;
    if (text == null) continue;
    final lines = parseLrc(text);
    if (lines.where((l) => l.text.isNotEmpty).length < 2) continue; // needs timestamps
    final t = similarity(title, '${e['title'] ?? ''}');
    final a = artist.isEmpty ? .5 : similarity(primaryArtist(artist), primaryArtist('${e['artist'] ?? ''}'));
    final score = t * .65 + a * .35;
    if (!confidentMatch(t, a, artist.isNotEmpty)) continue; // never show another song's lyrics
    if (score > bestScore) {
      bestScore = score;
      bestLines = lines;
    }
  }
  return bestLines;
}

/// Both title and (if known) artist must clearly match.
bool confidentMatch(double title, double artist, bool hasArtist) => title >= .75 && (!hasArtist || artist >= .5);
