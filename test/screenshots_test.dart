// Renders README screenshots with MADE-UP placeholder data (no real lyrics).
// Run: CANTO_SHOTS=1 flutter test test/screenshots_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:canto/main.dart';
import 'package:canto/src/controller.dart';
import 'package:canto/src/lrc.dart';
import 'package:canto/src/lrclib.dart';
import 'package:canto/src/models.dart';
import 'package:canto/src/source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const placeholderLrc = '''
[00:00.00]Placeholder line one for the demo
[00:04.00]This text is made up for screenshots
[00:08.00]Canto shows the current line here
[00:12.00]And the next line just below it
[00:16.00]示例占位歌词（非真实歌词）
[00:20.00]サンプルの仮テキスト
[00:24.00]Another invented line to scroll
[00:28.00]The end of the placeholder text
''';

class _FakeSource extends NowPlayingSource {
  @override
  Future<NowPlaying?> current() async => null;
  @override
  Future<CommandResult> favorite() async => CommandResult.unsupported;
  @override
  Future<CommandResult> playPause() async => CommandResult.ok;
}

Future<Uint8List> _art() async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  c.drawRect(const Rect.fromLTWH(0, 0, 400, 400), Paint()..color = const Color(0xFF2E7D6B));
  c.drawRect(const Rect.fromLTWH(60, 60, 280, 280), Paint()..color = const Color(0xFF3FA68C));
  c.drawRect(const Rect.fromLTWH(140, 140, 120, 120), Paint()..color = const Color(0xFFF2E3B3));
  final img = await rec.endRecording().toImage(400, 400);
  return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

Future<void> _font(String family, String path) async {
  final f = File(path);
  if (!f.existsSync()) return;
  final l = FontLoader(family)..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  await l.load();
}

void main() {
  final enabled = Platform.environment['CANTO_SHOTS'] == '1';
  testWidgets('render screenshots', (tester) async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/workspace/tools/flutter';
    await tester.runAsync(() async {
      await _font('Roboto', '/usr/share/fonts/truetype/sand-box/google/Roboto/Roboto-VariableFont_wdth,wght.ttf');
      await _font('Noto Sans CJK SC', '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc');
      await _font('MaterialIcons', '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    });
    final art = (await tester.runAsync(_art))!;
    tester.view.physicalSize = const Size(760, 1440);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    for (final dark in [false, true]) {
      for (final lyricsView in [false, true]) {
        final ctl = CantoController(source: _FakeSource(), fetchLyrics: (_) async => (SyncedLyrics(parseLrc(placeholderLrc)), 'LRCLIB'));
        final np = NowPlaying(
          title: 'Placeholder Song',
          artist: 'Demo Artist',
          album: 'Sample Album',
          duration: const Duration(minutes: 3, seconds: 30),
          position: const Duration(seconds: 9),
          positionAt: DateTime.now(),
          playing: false,
          artwork: art,
          sourceApp: 'com.spotify.music',
          sourceName: 'Demo Player',
          canSeek: true,
          canFavorite: true,
        );
        await tester.runAsync(() => ctl.update(np));
        if (dark) {
          // Placeholder translation/romanization to show the toggles on.
          ctl.translation = {for (var i = 0; i < 8; i++) i: '（占位译文 $i）'};
          ctl.romanization = {for (var i = 0; i < 8; i++) i: 'placeholder romaji $i'};
          ctl.showTranslation = true;
          ctl.showRomanization = lyricsView;
        }
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        final key = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: Theme(
            data: ThemeData(fontFamily: 'Roboto'),
            child: CantoApp(
              controller: ctl,
              desktop: true,
              locale: dark ? const Locale('zh') : const Locale('en'),
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              initialLyricsView: lyricsView,
            ),
          ),
        ));
        await tester.runAsync(() => precacheImage(MemoryImage(art), key.currentContext!));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final bytes = await tester.runAsync(() async {
          final img = await boundary.toImage(pixelRatio: 2);
          return (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        });
        final name = '${dark ? 'dark' : 'light'}_${lyricsView ? 'lyrics' : 'player'}.png';
        File('docs/screenshots/$name').writeAsBytesSync(bytes!);
        ctl.dispose();
        await tester.pumpWidget(const SizedBox());
      }
    }
  }, skip: !enabled);
}
