// Placeholder text only; no real lyrics.
import 'dart:async';
import 'dart:convert';
import 'package:canto/src/controller.dart';
import 'package:canto/src/favorite_style.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _NullSource extends NowPlayingSource {
  @override
  Future<NowPlaying?> current() async => null;
  @override
  Future<CommandResult> favorite() async => CommandResult.unsupported;
  @override
  Future<CommandResult> playPause() async => CommandResult.unsupported;
}

NowPlaying _np(String title) => NowPlaying(title: title, artist: 'Artist', positionAt: DateTime.now(), duration: const Duration(seconds: 200));

void main() {
  test('record -> synced > plain > none', () {
    expect(resultFromRecord({'syncedLyrics': '[00:01.00]Placeholder', 'plainLyrics': 'Placeholder'}), isA<SyncedLyrics>());
    expect(resultFromRecord({'syncedLyrics': null, 'plainLyrics': 'P1\nP2'}), isA<PlainLyrics>());
    expect(resultFromRecord({'instrumental': true}), isA<NoLyrics>());
    expect(resultFromRecord(null), isA<NoLyrics>());
  });

  test('client uses /api/get with UA, falls back to /api/search on 404', () async {
    final seen = <Uri>[];
    final client = LrclibClient(MockClient((req) async {
      seen.add(req.url);
      expect(req.headers['User-Agent'], userAgent);
      if (req.url.path == '/api/get') return http.Response('{}', 404);
      return http.Response(
          jsonEncode([
            {'duration': 50, 'syncedLyrics': '[00:01.00]Wrong'},
            {'duration': 201, 'syncedLyrics': '[00:01.00]Right placeholder'},
          ]),
          200);
    }));
    final r = await client.fetch(title: 'T', artist: 'A', album: 'B', duration: const Duration(seconds: 200));
    expect(seen.first.path, '/api/get');
    expect(seen.first.queryParameters, {'track_name': 'T', 'artist_name': 'A', 'album_name': 'B', 'duration': '200'});
    expect(seen.last.path, '/api/search');
    expect((r as SyncedLyrics).lines.single.text, 'Right placeholder');
  });

  test('network error -> LyricsError', () async {
    final client = LrclibClient(MockClient((_) async => throw Exception('offline')));
    expect(await client.fetch(title: 'T', artist: 'A'), isA<LyricsError>());
  });

  test('cache holds only the current track', () {
    final c = LyricsCache()..put('a', const NoLyrics());
    expect(c.get('a'), isNotNull);
    c.put('b', const NoLyrics());
    expect(c.get('a'), isNull);
    c.clear();
    expect(c.get('b'), isNull);
  });

  test('controller drops lyrics on track change and ignores stale results', () async {
    final pending = <String, Completer<LyricsResult>>{};
    final ctl = CantoController(source: _NullSource(), fetchLyrics: (np) => (pending[np.title] = Completer()).future);
    await ctl.update(_np('one'));
    pending['one']!.complete(const SyncedLyrics([]));
    await Future<void>.delayed(Duration.zero);
    expect(ctl.lyrics, isA<SyncedLyrics>());
    await ctl.update(_np('two'));
    expect(ctl.lyrics, isNull); // previous track's lyrics gone immediately
    await ctl.update(_np('three'));
    pending['two']!.complete(const PlainLyrics(['stale']));
    await Future<void>.delayed(Duration.zero);
    expect(ctl.lyrics, isNull); // stale result for 'two' dropped
    await ctl.update(null);
    expect(ctl.lyrics, isNull);
  });

  test('favorite icon by source app', () {
    expect(favoriteIconFor('com.spotify.music'), FavoriteIcon.plus);
    expect(favoriteIconFor('org.mpris.MediaPlayer2.spotify'), FavoriteIcon.plus);
    expect(favoriteIconFor('com.apple.Music'), FavoriteIcon.star);
    expect(favoriteIconFor('AppleInc.AppleMusicWin_nzyj5cx40ttqa!App'), FavoriteIcon.star);
    expect(favoriteIconFor('com.tencent.qqmusic'), FavoriteIcon.heart);
    expect(favoriteIconFor('com.netease.cloudmusic'), FavoriteIcon.heart);
    expect(favoriteIconFor('com.kugou.android'), FavoriteIcon.heart);
    expect(favoriteIconFor('org.videolan.vlc'), FavoriteIcon.heart);
  });
}
