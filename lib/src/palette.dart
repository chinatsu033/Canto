import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const fallbackAccent = Color(0xFF1A73E8); // neutral fixed accent

/// Dominant colour from raw RGBA pixels: 4-bit-per-channel histogram,
/// skipping near-white/near-black/greyish pixels, weighted by saturation.
Color? dominantFromRgba(Uint8List px) {
  final counts = <int, double>{};
  final sums = <int, List<int>>{};
  for (var i = 0; i + 3 < px.length; i += 4) {
    final r = px[i], g = px[i + 1], b = px[i + 2], a = px[i + 3];
    if (a < 128) continue;
    final mx = [r, g, b].reduce((x, y) => x > y ? x : y);
    final mn = [r, g, b].reduce((x, y) => x < y ? x : y);
    if (mx < 30 || mn > 230) continue;
    final sat = mx == 0 ? 0.0 : (mx - mn) / mx;
    if (sat < 0.15) continue;
    final key = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
    counts[key] = (counts[key] ?? 0) + 0.3 + sat;
    final s = sums.putIfAbsent(key, () => [0, 0, 0, 0]);
    s[0] += r; s[1] += g; s[2] += b; s[3]++;
  }
  if (counts.isEmpty) return null;
  final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final s = sums[best]!;
  return Color.fromARGB(255, s[0] ~/ s[3], s[1] ~/ s[3], s[2] ~/ s[3]);
}

Future<Color?> dominantColor(Uint8List encoded) async {
  try {
    final codec = await ui.instantiateImageCodec(encoded, targetWidth: 48, targetHeight: 48);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    frame.image.dispose();
    if (data == null) return null;
    return dominantFromRgba(data.buffer.asUint8List());
  } catch (_) {
    return null;
  }
}

/// Adjusts the accent so it stays readable on the given background.
Color readableAccent(Color c, Brightness b) {
  final hsl = HSLColor.fromColor(c);
  if (b == Brightness.light) {
    return hsl.withLightness(hsl.lightness.clamp(0.25, 0.45)).toColor();
  }
  return hsl.withLightness(hsl.lightness.clamp(0.55, 0.75)).toColor();
}
