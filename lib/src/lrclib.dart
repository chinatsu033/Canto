import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lrc.dart';

const userAgent = 'Canto/0.1.0 (https://github.com/chinatsu033/Canto)';

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

/// Turns one LRCLIB record into a result (synced > plain > none).
LyricsResult resultFromRecord(Map<String, dynamic>? rec) {
  if (rec == null || rec['instrumental'] == true) return const NoLyrics();
  final synced = rec['syncedLyrics'];
  if (synced is String && synced.trim().isNotEmpty) {
    final lines = parseLrc(synced);
    if (lines.isNotEmpty) return SyncedLyrics(lines);
  }
  final plain = rec['plainLyrics'];
  if (plain is String && plain.trim().isNotEmpty) {
    return PlainLyrics(plain.split(RegExp(r'\r?\n')));
  }
  return const NoLyrics();
}

/// LRCLIB client. Lyrics are only kept in memory for the current track
/// (see [LyricsCache]); nothing is written to disk, logged, or uploaded.
class LrclibClient {
  final http.Client _http;
  LrclibClient([http.Client? c]) : _http = c ?? http.Client();
  static const _base = 'lrclib.net';
  Map<String, String> get _headers => {'User-Agent': userAgent, 'Lrclib-Client': userAgent};

  Future<LyricsResult> fetch({
    required String title,
    required String artist,
    String album = '',
    Duration? duration,
  }) async {
    try {
      if (duration != null && duration.inSeconds > 0) {
        final uri = Uri.https(_base, '/api/get', {
          'track_name': title,
          'artist_name': artist,
          if (album.isNotEmpty) 'album_name': album,
          'duration': '${duration.inSeconds}',
        });
        final r = await _http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
        if (r.statusCode == 200) {
          final res = resultFromRecord(jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
          if (res is! NoLyrics) return res;
        }
        // 404 = not found; other errors (e.g. 5xx) also fall back to search.
      }
      final uri = Uri.https(_base, '/api/search', {
        'track_name': title,
        if (artist.isNotEmpty) 'artist_name': artist,
      });
      final r = await _http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
      if (r.statusCode != 200) return const LyricsError();
      final list = (jsonDecode(utf8.decode(r.bodyBytes)) as List).cast<Map<String, dynamic>>();
      return resultFromRecord(pickBest(list, duration));
    } catch (_) {
      return const LyricsError();
    }
  }
}

/// Prefers synced results whose duration is within 3s of the track.
Map<String, dynamic>? pickBest(List<Map<String, dynamic>> list, Duration? duration) {
  if (list.isEmpty) return null;
  int score(Map<String, dynamic> r) {
    var s = 0;
    final hasSynced = (r['syncedLyrics'] as String?)?.isNotEmpty ?? false;
    if (hasSynced) s += 10;
    if (duration != null && r['duration'] is num) {
      final d = ((r['duration'] as num) - duration.inSeconds).abs();
      if (d <= 3) {
        s += 20;
      } else if (d <= 10) {
        s += 5;
      }
    }
    return s;
  }
  final sorted = [...list]..sort((a, b) => score(b).compareTo(score(a)));
  return sorted.first;
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
