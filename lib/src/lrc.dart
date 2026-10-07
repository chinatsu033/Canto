/// Minimal LRC parser and sync helpers. Pure Dart, no I/O.
class LrcLine {
  final Duration time;
  final String text;
  const LrcLine(this.time, this.text);
  @override
  String toString() => 'LrcLine($time, $text)';
}

final _tag = RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');
final _offset = RegExp(r'^\[offset:\s*([+-]?\d+)\]', caseSensitive: false);

/// Parses LRC text into time-sorted lines. Supports multiple timestamps per
/// line, `mm:ss`, `mm:ss.xx`, `mm:ss.xxx`, and an `[offset:±ms]` header
/// (positive offset = lyrics shown earlier, per LRC convention).
List<LrcLine> parseLrc(String source) {
  final out = <LrcLine>[];
  var offsetMs = 0;
  for (final raw in source.split(RegExp(r'\r?\n'))) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final off = _offset.firstMatch(line);
    if (off != null) {
      offsetMs = int.parse(off.group(1)!);
      continue;
    }
    final times = <Duration>[];
    var rest = line;
    while (true) {
      final m = _tag.matchAsPrefix(rest);
      if (m == null) break;
      final min = int.parse(m.group(1)!);
      final sec = int.parse(m.group(2)!);
      final frac = m.group(3);
      var ms = 0;
      if (frac != null) {
        ms = int.parse(frac.padRight(3, '0').substring(0, 3));
      }
      times.add(Duration(minutes: min, seconds: sec, milliseconds: ms));
      rest = rest.substring(m.end);
    }
    if (times.isEmpty) continue; // metadata tags like [ar:] or junk
    final text = rest.trim();
    for (final t in times) {
      out.add(LrcLine(t, text));
    }
  }
  if (offsetMs != 0) {
    for (var i = 0; i < out.length; i++) {
      final t = out[i].time - Duration(milliseconds: offsetMs);
      out[i] = LrcLine(t.isNegative ? Duration.zero : t, out[i].text);
    }
  }
  out.sort((a, b) => a.time.compareTo(b.time)); // stable in Dart (merge sort)
  return out;
}

/// Index of the line active at [position], or -1 before the first line.
/// Binary search; [lines] must be sorted by time.
int activeLineIndex(List<LrcLine> lines, Duration position) {
  var lo = 0, hi = lines.length - 1, ans = -1;
  while (lo <= hi) {
    final mid = (lo + hi) >> 1;
    if (lines[mid].time <= position) {
      ans = mid;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return ans;
}

/// Estimates the current playback position from the last reported sample.
Duration extrapolatePosition({
  required Duration reported,
  required DateTime reportedAt,
  required DateTime now,
  required bool playing,
  double rate = 1.0,
  Duration? duration,
}) {
  var p = reported;
  if (playing) {
    final elapsed = now.difference(reportedAt);
    if (elapsed > Duration.zero) {
      p += Duration(microseconds: (elapsed.inMicroseconds * rate).round());
    }
  }
  if (p.isNegative) p = Duration.zero;
  if (duration != null && duration > Duration.zero && p > duration) p = duration;
  return p;
}
