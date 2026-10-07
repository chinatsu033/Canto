// Synthetic placeholder data only.
import 'dart:convert';
import 'package:canto/main.dart';
import 'package:canto/src/controller.dart';
import 'package:canto/src/lrc.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/lrcshare.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/net.dart';
import 'package:canto/src/platform_name.dart';
import 'package:canto/src/romanize.dart';
import 'package:canto/src/source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Src extends NowPlayingSource {
  final calls = <String>[];
  @override
  Future<NowPlaying?> current() async => null;
  @override
  Future<CommandResult> favorite() async {
    calls.add('favorite');
    return CommandResult.unsupported;
  }

  @override
  Future<CommandResult> playPause() async => CommandResult.ok;
  @override
  Future<CommandResult> goToQueueItem(String id, int offset) async {
    calls.add('goTo $id $offset');
    return CommandResult.ok;
  }
}

void main() {
  group('local romanization', () {
    test('pinyin', () => expect(pinyinLine('你好'), 'nǐ hǎo'));
    test('kana -> romaji incl. yoon, sokuon, long vowel', () {
      expect(romajiLine('ちょっと まって'), 'chotto matte');
      expect(romajiLine('コーヒー'), 'koohii');
      expect(romajiLine('しゃしん'), 'shashin');
    });
    test('kanji line is skipped (no reading)', () => expect(romajiLine('今日はいい'), isNull));
    test('hangul -> RR', () => expect(hangulLine('안녕하세요'), 'annyeonghaseyo'));
    test('autoRomanize keeps line indices (timestamps untouched)', () {
      final lines = parseLrc('[00:01.00]你好\n[00:02.00]\n[00:03.00]世界');
      expect(autoRomanize(lines), {0: 'nǐ hǎo', 2: 'shì jiè'});
      expect(autoRomanize(parseLrc('[00:01.00]hello')), isNull);
    });
  });

  test('platform names', () {
    expect(platformName('com.spotify.music', 'Spotify'), 'Spotify');
    expect(platformName('com.tencent.qqmusic', 'QQ Music'), 'QQ音乐');
    expect(platformName('com.netease.cloudmusic', ''), '网易云音乐');
    expect(platformName('com.kugou.android', ''), '酷狗音乐');
    expect(platformName('com.apple.Music', 'Music'), 'Apple Music');
    expect(platformName('org.mpris.MediaPlayer2.someplayer', 'Some Player'), 'Some Player');
    expect(platformName('x.y.z', 'My App'), 'My App');
  });

  test('LrcShare loose matching: falls back to cleaned title-only search', () async {
    final queries = <Map<String, String>>[];
    final client = LrcShareClient(HttpGate(
      client: MockClient((req) async {
        queries.add(req.url.queryParameters);
        if (req.url.queryParameters.containsKey('artist')) {
          return http.Response(jsonEncode({'code': 200, 'data': {'items': []}}), 200);
        }
        return http.Response(jsonEncode({
          'code': 200,
          'data': {
            'items': [
              {'id': 'x1', 'title': 'Fake Tune', 'artists': [{'name': 'Guest Singer'}]}
            ]
          }
        }), 200);
      }),
      sleep: (_) async {},
    ));
    final s = await client.find('Fake Tune (Live)', 'Main Person & Guest Singer');
    expect(s?.id, 'x1');
    expect(queries.first['artist'], 'Main Person');
    expect(queries[1], {'title': 'Fake Tune', 'type': 'song'});
  });

  testWidgets('toggles work end-to-end: auto romanization shows, missing translation hints', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final ctl = CantoController(
        source: _Src(),
        fetchLyrics: (_) async => (SyncedLyrics(parseLrc('[00:00.00]你好\n[00:30.00]世界')), 'LRCLIB'));
    await tester.runAsync(() async {
      await ctl.update(NowPlaying(title: 'Fake', artist: 'Nobody', positionAt: DateTime.now(), position: const Duration(seconds: 1)));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    expect(ctl.romanizationAuto, isTrue);
    await tester.pumpWidget(CantoApp(controller: ctl, locale: const Locale('en'), themeMode: ThemeMode.light));
    await tester.pump();
    expect(find.text('nǐ hǎo'), findsNothing);
    await tester.tap(find.text('Romanization · auto'));
    await tester.pump();
    expect(ctl.showRomanization, isTrue);
    expect(find.text('nǐ hǎo'), findsOneWidget);
    await tester.tap(find.text('Translation'));
    await tester.pump();
    expect(ctl.showTranslation, isTrue);
    expect(find.text('No translation for this song yet'), findsOneWidget);
    ctl.dispose();
  });

  testWidgets('queue tap calls goToQueueItem with id and offset; favorite calls through', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final src = _Src();
    final ctl = CantoController(source: src, fetchLyrics: (_) async => (const NoLyrics(), null));
    await tester.runAsync(() => ctl.update(NowPlaying(
          title: 'Fake',
          artist: 'Nobody',
          positionAt: DateTime.now(),
          canGoToQueueItem: true,
          queue: const [QueueItem('A', null, id: '10'), QueueItem('B', null, current: true, id: '11'), QueueItem('C', null, id: '12'), QueueItem('D', null, id: '13')],
        )));
    await tester.pumpWidget(CantoApp(controller: ctl, locale: const Locale('en'), themeMode: ThemeMode.light));
    await tester.pump();
    await tester.tap(find.byTooltip('Up next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('D'));
    await tester.pump();
    expect(src.calls, ['goTo 13 2']);
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(src.calls.last, 'goTo 10 -1');
    Navigator.of(tester.element(find.text('A'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorite'));
    await tester.pump();
    expect(find.text("This player doesn't let other apps favorite tracks"), findsOneWidget);
    ctl.dispose();
  });
}
