// Placeholder text only; no real lyrics.
import 'dart:async';
import 'dart:convert';
import 'package:canto/src/controller.dart';
import 'package:canto/src/favorite_style.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/lyrics_provider.dart';
import 'package:canto/src/net.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FixedProvider implements LyricsProvider {
  @override
  final String name;
  final LyricsResult r;
  _FixedProvider(this.name, this.r);
  @override
  Future<LyricsResult> fetch(NowPlaying np) async => r;
}

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
    expect(resultFromRecord({'instrumental': true}), isA<Instrumental>());
    expect(resultFromRecord(null), isA<NoLyrics>());
  });

  test('client uses /api/get with UA, falls back to /api/search on 404', () async {
    final seen = <Uri>[];
    final client = LrclibClient(HttpGate(client: MockClient((req) async {
      seen.add(req.url);
      expect(req.headers['User-Agent'], userAgent);
      if (req.url.path == '/api/get') return http.Response('{}', 404);
      return http.Response(
          jsonEncode([
            {'trackName': 'T', 'artistName': 'A', 'duration': 50, 'syncedLyrics': '[00:01.00]Wrong'},
            {'trackName': 'T', 'artistName': 'A', 'duration': 201, 'syncedLyrics': '[00:01.00]Right placeholder'},
          ]),
          200);
    })));
    final r = await client.fetch(title: 'T', artist: 'A', album: 'B', duration: const Duration(seconds: 200));
    expect(seen.first.path, '/api/get');
    expect(seen.first.queryParameters, {'track_name': 'T', 'artist_name': 'A', 'album_name': 'B', 'duration': '200'});
    expect(seen.last.path, '/api/search');
    expect((r as SyncedLyrics).lines.single.text, 'Right placeholder');
  });

  test('falls back to q= search with cleaned title when nothing synced is close', () async {
    final seen = <Uri>[];
    final client = LrclibClient(HttpGate(client: MockClient((req) async {
      seen.add(req.url);
      if (req.url.path == '/api/get') return http.Response('{}', 404);
      if (req.url.queryParameters.containsKey('q')) {
        return http.Response(jsonEncode([
          {'trackName': 'Song Title', 'artistName': 'Main Artist', 'duration': 230, 'syncedLyrics': '[00:01.00]Far'},
          {'trackName': 'Song Title', 'artistName': 'Main Artist', 'duration': 199, 'syncedLyrics': '[00:01.00]Close placeholder'},
          {'trackName': 'Other', 'artistName': 'Else', 'duration': 200, 'syncedLyrics': '[00:01.00]Unrelated'},
        ]), 200);
      }
      return http.Response(jsonEncode([{'trackName': 'Song Title', 'artistName': 'Main Artist', 'duration': 200, 'plainLyrics': 'Plain only'}]), 200);
    })));
    final r = await client.fetch(
        title: 'Ｓｏｎｇ Title (Remastered 2011) feat. Someone', artist: 'Main Artist & Guest', duration: const Duration(seconds: 200));
    expect(seen.map((u) => u.path), ['/api/get', '/api/search', '/api/search']);
    expect(seen.last.queryParameters['q'], 'Song Title Main Artist');
    expect((r as SyncedLyrics).lines.single.text, 'Close placeholder');
  });

  test('plain lyrics are used when no synced result exists', () async {
    final client = LrclibClient(HttpGate(client: MockClient((req) async {
      if (req.url.path == '/api/get') return http.Response(jsonEncode({'duration': 200, 'plainLyrics': 'P1'}), 200);
      return http.Response('[]', 200);
    })));
    expect(await client.fetch(title: 'T', artist: 'A', duration: const Duration(seconds: 200)), isA<PlainLyrics>());
  });

  test('cleanTitle / primaryArtist', () {
    expect(cleanTitle('Track Name - 2011 Remaster'), 'Track Name');
    expect(cleanTitle('Track (Live at Somewhere) [Bonus]'), 'Track');
    expect(cleanTitle('歌名（Live版）'), '歌名');
    expect(cleanTitle('Name ft. X'), 'Name');
    expect(cleanTitle('ＡＢＣ！'), 'ABC');
    expect(primaryArtist('A, B & C'), 'A');
    expect(primaryArtist('甲、乙'), '甲');
  });

  test('pickBest prefers synced with closest duration', () {
    final best = pickBest([
      {'duration': 200, 'plainLyrics': 'x'},
      {'duration': 260, 'syncedLyrics': '[00:01.00]a'},
      {'duration': 202, 'syncedLyrics': '[00:01.00]b'},
    ], const Duration(seconds: 200));
    expect(best!['duration'], 202);
  });

  test('provider chain reports the source name', () async {
    final chain = ProviderChain([_FixedProvider('A', const NoLyrics()), _FixedProvider('LRCLIB', const PlainLyrics(['x']))]);
    final (r, src) = await chain.fetch(_np('t'));
    expect(r, isA<PlainLyrics>());
    expect(src, 'LRCLIB');
  });

  test('network error -> LyricsError', () async {
    final client = LrclibClient(HttpGate(client: MockClient((_) async => throw Exception('offline'))));
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
    final ctl = CantoController(source: _NullSource(), fetchLyrics: (np) => (pending[np.title] = Completer<LyricsResult>()).future.then((r) => (r, 'LRCLIB')));
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
