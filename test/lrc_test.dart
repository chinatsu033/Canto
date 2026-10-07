// All lyric lines below are made-up placeholders, not real song lyrics.
import 'package:canto/src/lrc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLrc', () {
    test('parses mm:ss.xx, mm:ss.xxx, mm:ss and skips metadata', () {
      final l = parseLrc('[ar:Placeholder]\n[ti:Demo]\n[00:01.50]Line one\n[00:03.250]Line two\n[01:05]Line three\nnot a line');
      expect(l.map((e) => e.text), ['Line one', 'Line two', 'Line three']);
      expect(l[0].time, const Duration(seconds: 1, milliseconds: 500));
      expect(l[1].time, const Duration(seconds: 3, milliseconds: 250));
      expect(l[2].time, const Duration(minutes: 1, seconds: 5));
    });
    test('multiple timestamps per line are expanded and sorted', () {
      final l = parseLrc('[00:10.00][00:02.00]Chorus placeholder\n[00:05.00]Verse placeholder');
      expect(l.map((e) => e.time.inSeconds), [2, 5, 10]);
      expect(l.first.text, 'Chorus placeholder');
    });
    test('empty text lines are kept as instrumental gaps', () {
      final l = parseLrc('[00:01.00]A\n[00:02.00]\n[00:03.00]B');
      expect(l[1].text, '');
    });
    test('offset header shifts times earlier and clamps at zero', () {
      final l = parseLrc('[offset:+500]\n[00:00.20]A\n[00:02.00]B');
      expect(l[0].time, Duration.zero);
      expect(l[1].time, const Duration(milliseconds: 1500));
    });
    test('CRLF and blank input', () {
      expect(parseLrc(''), isEmpty);
      expect(parseLrc('[00:01.00]A\r\n[00:02.00]B').length, 2);
    });
  });

  group('activeLineIndex', () {
    final lines = parseLrc('[00:01.00]A\n[00:02.00]B\n[00:04.00]C');
    test('before first line', () => expect(activeLineIndex(lines, Duration.zero), -1));
    test('exact boundary', () => expect(activeLineIndex(lines, const Duration(seconds: 2)), 1));
    test('between lines', () => expect(activeLineIndex(lines, const Duration(milliseconds: 3999)), 1));
    test('after last', () => expect(activeLineIndex(lines, const Duration(minutes: 9)), 2));
    test('empty list', () => expect(activeLineIndex(const [], const Duration(seconds: 1)), -1));
  });

  group('extrapolatePosition', () {
    final t0 = DateTime(2026, 1, 1, 12);
    test('advances while playing', () {
      expect(
          extrapolatePosition(reported: const Duration(seconds: 10), reportedAt: t0, now: t0.add(const Duration(seconds: 3)), playing: true),
          const Duration(seconds: 13));
    });
    test('frozen while paused', () {
      expect(
          extrapolatePosition(reported: const Duration(seconds: 10), reportedAt: t0, now: t0.add(const Duration(seconds: 3)), playing: false),
          const Duration(seconds: 10));
    });
    test('respects rate and clamps to duration', () {
      expect(
          extrapolatePosition(
              reported: const Duration(seconds: 10), reportedAt: t0, now: t0.add(const Duration(seconds: 4)), playing: true, rate: 2),
          const Duration(seconds: 18));
      expect(
          extrapolatePosition(
              reported: const Duration(seconds: 10), reportedAt: t0, now: t0.add(const Duration(minutes: 5)), playing: true,
              duration: const Duration(seconds: 30)),
          const Duration(seconds: 30));
    });
  });
}
