// Synthetic placeholder lines only.
import 'dart:convert';
import 'package:canto/main.dart';
import 'package:canto/src/controller.dart';
import 'package:canto/src/lrc.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/net.dart';
import 'package:canto/src/source.dart';
import 'package:canto/src/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Src extends NowPlayingSource {
  @override
  Future<NowPlaying?> current() async => null;
  @override
  Future<CommandResult> favorite() async => CommandResult.unsupported;
  @override
  Future<CommandResult> playPause() async => CommandResult.ok;
}

class _FakeTr implements Translator {
  final calls = <String>[];
  Object? fail;
  @override
  Future<List<String?>> translate(List<String> lines, String src, String tgt, {void Function()? onDownloading, void Function(List<String?> partial)? onPartial}) async {
    calls.add('$src>$tgt');
    onDownloading?.call();
    if (fail != null) throw fail!;
    return [for (final l in lines) 'T:$l'];
  }
}

http.Response _json(Object o, [int code = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(o)), code, headers: {'content-type': 'application/json'});

void main() {
  test('target language: app language, English if original matches, zh default', () {
    expect(targetLangFor(null, 'ja'), 'zh');
    expect(targetLangFor('zh', 'zh'), 'en');
    expect(targetLangFor('en', 'en'), 'zh');
    expect(targetLangFor('zh_Hant_HK', 'ja'), 'zh-TW');
    expect(targetLangFor('fr', 'ja'), 'fr');
    expect(myMemoryCode('pt'), 'pt-BR');
  });

  test('batching keeps under limit and skips blank lines', () {
    final lines = ['aaaa', '', 'bbbb', 'cccc'];
    expect(batchLines(lines, maxChars: 10), [[0, 2], [3]]);
  });

  test('MyMemory: batched requests, split back per line, spacing, langpair', () async {
    final reqs = <Uri>[];
    final sleeps = <Duration>[];
    final gate = HttpGate(client: MockClient((r) async {
      reqs.add(r.url);
      final q = r.url.queryParameters['q']!;
      return _json({'responseStatus': 200, 'responseData': {'translatedText': q.split('\n').map((s) => 'X$s').join('\n')}});
    }));
    final t = MyMemoryTranslator(gate, spacing: const Duration(seconds: 1), sleep: (d) async => sleeps.add(d));
    final lines = [for (var i = 0; i < 60; i++) 'placeholder line $i'];
    final out = await t.translate(lines, 'en', 'zh');
    expect(out.first, 'Xplaceholder line 0');
    expect(out.last, 'Xplaceholder line 59');
    expect(reqs.length, lessThan(6)); // ~60 lines in a few requests, not 60
    expect(reqs.first.queryParameters['langpair'], 'en|zh-CN');
    expect(sleeps.length, reqs.length - 1);
  });

  test('MyMemory: quota warning and 429 become quota failure; mismatched split left empty', () async {
    var mode = 0;
    final gate = HttpGate(
        client: MockClient((r) async => switch (mode) {
              0 => _json({'responseStatus': 403, 'responseData': {'translatedText': 'MYMEMORY WARNING: YOU USED ALL AVAILABLE FREE TRANSLATIONS FOR TODAY'}}),
              _ => _json({'responseStatus': 200, 'responseData': {'translatedText': 'one line only'}}),
            }),
        sleep: (_) async {});
    var t = MyMemoryTranslator(gate, sleep: (_) async {});
    await expectLater(t.translate(['a', 'b'], 'en', 'zh'),
        throwsA(isA<TranslateException>().having((e) => e.kind, 'kind', TranslateFailure.quota)));
    // quota remembered: no new request
    await expectLater(t.translate(['a'], 'en', 'zh'), throwsA(isA<TranslateException>()));
    mode = 1;
    t = MyMemoryTranslator(gate, sleep: (_) async {});
    expect(await t.translate(['a', 'b'], 'en', 'zh'), [null, null]);
  });

  Future<CantoController> setup(WidgetTester tester, _FakeTr tr) async {
    SharedPreferences.setMockInitialValues({'showTranslation': true});
    final ctl = CantoController(
        source: _Src(),
        translator: tr,
        fetchLyrics: (np) async => (SyncedLyrics(parseLrc(np.title == 'Fake' ? '[00:00.00]你好\n[00:30.00]世界' : '[00:00.00]再见')), 'LRCLIB'));
    await tester.runAsync(() async {
      await ctl.loadPrefs();
      await ctl.update(NowPlaying(title: 'Fake', artist: 'Nobody', positionAt: DateTime.now(), position: const Duration(seconds: 1)));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    return ctl;
  }

  testWidgets('auto translation fills lines (timestamps kept), labelled, cleared on track change', (tester) async {
    final tr = _FakeTr();
    final ctl = await setup(tester, tr);
    expect(tr.calls, ['zh>en']);
    expect(ctl.translationAuto, isTrue);
    expect(ctl.translation, {0: 'T:你好', 1: 'T:世界'});
    final lines = (ctl.lyrics as SyncedLyrics).lines;
    expect(lines[1].time, const Duration(seconds: 30));
    await tester.pumpWidget(CantoApp(controller: ctl, locale: const Locale('en'), themeMode: ThemeMode.light));
    await tester.pump();
    expect(find.text('Auto-translated'), findsOneWidget);
    expect(find.text('T:你好'), findsOneWidget);
    await tester.runAsync(() async {
      await ctl.update(NowPlaying(title: 'Other', artist: 'Nobody', positionAt: DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    expect(ctl.translation, {0: 'T:再见'});
    expect(tr.calls.length, 2);
    ctl.dispose();
  });

  testWidgets('no translator call while toggle off; quota shows localized hint', (tester) async {
    final tr = _FakeTr()..fail = TranslateException(TranslateFailure.quota);
    SharedPreferences.setMockInitialValues({});
    final ctl = CantoController(
        source: _Src(), translator: tr, fetchLyrics: (_) async => (SyncedLyrics(parseLrc('[00:00.00]hello')), 'LRCLIB'));
    await tester.runAsync(() async {
      await ctl.update(NowPlaying(title: 'Fake', artist: 'Nobody', positionAt: DateTime.now()));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    expect(tr.calls, isEmpty);
    await tester.runAsync(() async {
      await ctl.setShowTranslation(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    expect(tr.calls, ['en>zh']);
    expect(ctl.translateStatus, 'quota');
    await tester.pumpWidget(CantoApp(controller: ctl, locale: const Locale('zh'), themeMode: ThemeMode.light));
    await tester.pump();
    await tester.tap(find.text('翻译'));
    await tester.pump();
    await tester.tap(find.text('翻译'));
    await tester.pump();
    expect(find.text('今日免费翻译额度已用完，请明天再试'), findsWidgets);
    ctl.dispose();
  });
}
