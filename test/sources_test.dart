// Synthetic fixtures only: every lyric line here is invented placeholder text.
import 'dart:convert';
import 'package:canto/src/lrc.dart';
import 'package:canto/src/lrcapi.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/lrcshare.dart';
import 'package:canto/src/lyrics_provider.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/net.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _P implements LyricsProvider {
  @override
  final String name;
  final LyricsResult r;
  final List<String> log;
  _P(this.name, this.r, this.log);
  @override
  Future<LyricsResult> fetch(NowPlaying np) async {
    log.add(name);
    return r;
  }
}

final _np = NowPlaying(title: 'Fake Song', artist: 'Fake Artist', positionAt: DateTime(2026), duration: const Duration(seconds: 200));
final _synced = SyncedLyrics(parseLrc('[00:01.00]one\n[00:02.00]two'));

void main() {
  group('provider order', () {
    test('LRCLIB synced stops the chain', () async {
      final log = <String>[];
      final (r, src) = await ProviderChain([_P('LRCLIB', _synced, log), _P('LrcAPI', _synced, log), _P('LrcShare', _synced, log)]).fetch(_np);
      expect(log, ['LRCLIB']);
      expect(src, 'LRCLIB');
      expect(r, isA<SyncedLyrics>());
    });
    test('plain from LRCLIB does not stop; later synced wins', () async {
      final log = <String>[];
      final (r, src) = await ProviderChain([
        _P('LRCLIB', const PlainLyrics(['p']), log),
        _P('LrcAPI', const NoLyrics(), log),
        _P('LrcShare', _synced, log),
      ]).fetch(_np);
      expect(log, ['LRCLIB', 'LrcAPI', 'LrcShare']);
      expect(src, 'LrcShare');
      expect(r, isA<SyncedLyrics>());
    });
    test('falls back to plain, then none', () async {
      final log = <String>[];
      var (r, src) = await ProviderChain([_P('LRCLIB', const PlainLyrics(['p']), log), _P('LrcAPI', const NoLyrics(), log)]).fetch(_np);
      expect(r, isA<PlainLyrics>());
      expect(src, 'LRCLIB');
      (r, src) = await ProviderChain([_P('A', const NoLyrics(), log), _P('B', const NoLyrics(), log)]).fetch(_np);
      expect(r, isA<NoLyrics>());
      expect(src, isNull);
    });
    test('instrumental ends the search', () async {
      final log = <String>[];
      final (r, _) = await ProviderChain([_P('LRCLIB', const Instrumental(), log), _P('LrcAPI', _synced, log)]).fetch(_np);
      expect(r, isA<Instrumental>());
      expect(log, ['LRCLIB']);
    });
    test('LRCLIB instrumental record -> Instrumental', () async {
      final c = LrclibClient(HttpGate(client: MockClient((req) async {
        if (req.url.path == '/api/get') {
          return http.Response(jsonEncode({'instrumental': true, 'syncedLyrics': null, 'plainLyrics': null, 'duration': 200}), 200);
        }
        return http.Response('[]', 200);
      })));
      expect(await c.fetch(title: 'T', artist: 'A', duration: const Duration(seconds: 200)), isA<Instrumental>());
    });
  });

  group('HttpGate', () {
    test('429 -> exponential backoff then success, UA headers set', () async {
      final sleeps = <Duration>[];
      var n = 0;
      final gate = HttpGate(
        client: MockClient((req) async {
          expect(req.headers['User-Agent'], userAgent);
          expect(req.headers['X-User-Agent'], userAgent);
          n++;
          return n <= 2 ? http.Response('', 429) : http.Response('ok', 200);
        }),
        sleep: (d) async => sleeps.add(d),
      );
      final r = await gate.get(Uri.https('lrclib.net', '/api/get'));
      expect(r.statusCode, 200);
      expect(sleeps, [const Duration(seconds: 1), const Duration(seconds: 2)]);
    });
    test('persistent 429 -> RateLimited and host cooldown (no request sent)', () async {
      final sleeps = <Duration>[];
      var n = 0;
      final gate = HttpGate(
        client: MockClient((_) async {
          n++;
          return http.Response('', 429);
        }),
        sleep: (d) async => sleeps.add(d),
      );
      await expectLater(gate.get(Uri.https('api.lrc.cx', '/x')), throwsA(isA<RateLimited>()));
      expect(n, 3);
      expect(sleeps, [const Duration(seconds: 1), const Duration(seconds: 2)]);
      await expectLater(gate.get(Uri.https('api.lrc.cx', '/x')), throwsA(isA<RateLimited>()));
      expect(n, 3);
    });
    test('Retry-After is honoured', () async {
      final sleeps = <Duration>[];
      var n = 0;
      final gate = HttpGate(
        client: MockClient((_) async => ++n == 1 ? http.Response('', 429, headers: {'retry-after': '7'}) : http.Response('', 200)),
        sleep: (d) async => sleeps.add(d),
      );
      await gate.get(Uri.https('lrclib.net', '/'));
      expect(sleeps, [const Duration(seconds: 7)]);
    });
    test('requests are sequential and LrcShare is spaced >=300ms', () async {
      var inFlight = 0, maxInFlight = 0;
      var clock = DateTime(2026);
      final sleeps = <Duration>[];
      final gate = HttpGate(
        client: MockClient((_) async {
          inFlight++;
          if (inFlight > maxInFlight) maxInFlight = inFlight;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          inFlight--;
          return http.Response('', 200);
        }),
        now: () => clock,
        sleep: (d) async {
          sleeps.add(d);
          clock = clock.add(d);
        },
      );
      await Future.wait([
        for (var i = 0; i < 3; i++) gate.get(Uri.https('api.lrcshare.com', '/v1/search', {'title': 'x'})),
      ]);
      expect(maxInFlight, 1);
      expect(sleeps, [const Duration(milliseconds: 300), const Duration(milliseconds: 300)]);
    });
  });

  group('LrcAPI', () {
    test('best match prefers closest title+artist with timestamps', () {
      final lines = bestLrcApiMatch([
        {'id': 1, 'title': 'Fake Song', 'artist': 'Fake Artist', 'lyrics': 'untimed text only'},
        {'id': 2, 'title': 'Other Tune', 'artist': 'Someone', 'lyrics': '[00:01.00]wrong a\n[00:02.00]wrong b'},
        {'id': 3, 'title': 'Fake Song (Live)', 'artist': 'Fake Artist', 'lyrics': '[00:01.00]right a\n[00:02.00]right b'},
      ], 'Fake Song', 'Fake Artist');
      expect(lines!.first.text, 'right a');
    });
    test('no acceptable match -> null', () {
      expect(bestLrcApiMatch([
        {'title': 'Completely Different', 'artist': 'Nobody', 'lrc': '[00:01.00]a\n[00:02.00]b'},
      ], 'Fake Song', 'Fake Artist'), isNull);
    });
    test('provider: v1 404 -> /jsonapi verified match (never blind /lyrics)', () async {
      final paths = <String>[];
      final p = LrcApiProvider(HttpGate(client: MockClient((req) async {
        paths.add(req.url.path);
        if (req.url.path.startsWith('/api/v1')) return http.Response('{"detail":"Not Found"}', 404);
        return http.Response(
            jsonEncode([
              {'title': 'Unrelated', 'artist': 'X', 'lrc': '[00:01.00]no\n[00:03.00]no'},
              {'title': 'Fake Song', 'artist': 'Fake Artist', 'lrc': '[00:01.00]alpha\n[00:03.00]beta'},
            ]),
            200);
      })));
      final r = await p.fetch(_np);
      expect(paths, ['/api/v1/lyrics/single', '/api/v1/lyrics/advance', '/jsonapi']);
      expect((r as SyncedLyrics).lines.length, 2);
    });
  });

  group('LrcShare', () {
    final body = {
      'code': 200,
      'data': {
        'lyric_lines': {
          'primary_lang': 'ja',
          'versions': [
            {
              'lang': 'ja',
              'kind': 'original',
              'rows': [
                {'seq': 1, 'time_ms': null, 'text': '[ti:meta]'},
                {'seq': 2, 'time_ms': 1000, 'text': '<0>fake<120> one'},
                {'seq': 3, 'time_ms': 3000, 'text': 'fake two'},
              ]
            },
            {'lang': 'ja-Latn', 'kind': 'romanization', 'rows': [
              {'seq': 2, 'time_ms': 1000, 'text': 'feiku wan'},
              {'seq': 3, 'time_ms': 3000, 'text': 'feiku tsu'},
            ]},
            {'lang': 'en', 'kind': 'translation', 'rows': [
              {'seq': 2, 'time_ms': 1000, 'text': 'EN one'},
            ]},
            {'lang': 'zh-Hans', 'kind': 'translation', 'rows': [
              {'seq': 2, 'time_ms': 1000, 'text': 'ZH one'},
              {'seq': 3, 'time_ms': 3000, 'text': 'ZH two'},
            ]},
          ]
        }
      }
    };
    test('version parsing (kinds, langs, word tags stripped, meta rows dropped)', () {
      final vs = parseLsVersions(body);
      expect(vs.map((v) => '${v.kind}:${v.lang}'), ['original:ja', 'romanization:ja-Latn', 'translation:en', 'translation:zh-Hans']);
      expect(vs.first.rows.map((r) => r.text), ['fake one', 'fake two']);
    });
    test('translation zh-Hans preferred; English when original is Chinese', () {
      final vs = parseLsVersions(body);
      expect(pickTranslation(vs, 'ja')!.lang, 'zh-Hans');
      expect(pickTranslation(vs, 'zh-Hant')!.lang, 'en');
      expect(pickRomanization(vs, 'ja')!.lang, 'ja-Latn');
      expect(pickRomanization(vs, 'ko'), isNull);
      expect(pickRomanization([const LsVersion('zh-Latn-pinyin', 'romanization', [LrcLine(Duration.zero, 'x')])], 'zh')!.lang,
          'zh-Latn-pinyin');
    });
    test('alignment reuses displayed timestamps; impossible -> null', () {
      final displayed = parseLrc('[00:01.05]shown one\n[00:02.00]\n[00:03.10]shown two');
      final ro = parseLsVersions(body)[1].rows;
      final m = alignByTimestamp(displayed, ro)!;
      expect(m, {0: 'feiku wan', 2: 'feiku tsu'}); // keyed by displayed line index
      final shifted = [for (final r in ro) LrcLine(r.time + const Duration(seconds: 5), r.text)];
      expect(alignByTimestamp(displayed, shifted), isNull);
    });
    test('session: one search + one lyric request per track, memoised', () async {
      final paths = <String>[];
      final session = LrcShareSession(LrcShareClient(HttpGate(
        client: MockClient((req) async {
          paths.add(req.url.path);
          if (req.url.path == '/v1/search') {
            expect(req.url.queryParameters.keys.toSet(), {'title', 'artist', 'type'}); // no cache-busting params
            return http.Response(jsonEncode({
              'code': 200,
              'data': {
                'items': [
                  {'id': 's1', 'title': 'Fake Song', 'artists': [{'name': 'Fake Artist'}], 'album': {'cover': 'https://example.invalid/c.png'}}
                ]
              }
            }), 200);
          }
          expect(req.url.queryParameters, {'lyric_translation_lang': 'all', 'lyric_format': 'line', 'lyric_lines': '1'});
          return http.Response(jsonEncode(body), 200);
        }),
        sleep: (_) async {},
      )));
      final a = await session.forTrack(_np);
      final b = await session.forTrack(_np);
      expect(identical(a, b), isTrue);
      expect(paths, ['/v1/search', '/v1/lyric/s1']);
      expect(a!.song.cover, 'https://example.invalid/c.png');
      expect((await LrcShareProvider(session).fetch(_np)) is SyncedLyrics, isTrue);
    });
  });
}
