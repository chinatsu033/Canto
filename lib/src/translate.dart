// Automatic lyric translation, used only when LrcShare has no translation.
// Android: Google ML Kit on-device (via platform channel `canto/translate`).
// Desktop: MyMemory free HTTP API (lines are sent to api.mymemory.translated.net).
// Results live only in memory (CantoController.translation) and are dropped on
// track change. Nothing here logs lyric text.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'net.dart';

enum TranslateFailure { quota, unavailable, failed }

class TranslateException implements Exception {
  final TranslateFailure kind;
  TranslateException(this.kind);
  @override
  String toString() => 'TranslateException($kind)';
}

abstract class Translator {
  /// Translates [lines] (same order/length returned; null entries = untranslated).
  /// [onDownloading] is called if a model must be downloaded first.
  Future<List<String?>> translate(List<String> lines, String src, String tgt, {void Function()? onDownloading, void Function(List<String?> partial)? onPartial});
}

/// App language tag (e.g. 'zh', 'zh_Hant_HK', 'pt') -> base translator code.
String targetLangFor(String? appTag, String original) {
  final tag = (appTag == null || appTag.isEmpty) ? 'zh' : appTag;
  var tgt = tag.split('_').first.toLowerCase();
  final hant = tag.contains('Hant');
  if (tgt == original) tgt = original == 'en' ? 'zh' : 'en';
  return tgt == 'zh' && hant ? 'zh-TW' : tgt;
}

/// MyMemory language codes.
String myMemoryCode(String l) => switch (l) {
      'zh' => 'zh-CN',
      'zh-TW' => 'zh-TW',
      'pt' => 'pt-BR',
      _ => l,
    };

/// Groups line indices into batches whose newline-joined text stays under [maxChars].
List<List<int>> batchLines(List<String> lines, {int maxChars = 450}) {
  final out = <List<int>>[];
  var cur = <int>[];
  var len = 0;
  for (var i = 0; i < lines.length; i++) {
    final t = lines[i].trim();
    if (t.isEmpty) continue;
    final l = t.length + 1;
    if (cur.isNotEmpty && len + l > maxChars) {
      out.add(cur);
      cur = [];
      len = 0;
    }
    cur.add(i);
    len += l;
  }
  if (cur.isNotEmpty) out.add(cur);
  return out;
}

bool _isQuota(Map j) {
  final st = j['responseStatus'];
  final txt = '${(j['responseData'] as Map?)?['translatedText'] ?? ''}'.toUpperCase();
  if (j['quotaFinished'] == true) return true;
  return st == 429 || '$st' == '429' || txt.contains('MYMEMORY WARNING') || txt.contains('QUOTA');
}

class MyMemoryTranslator implements Translator {
  final HttpGate gate;
  final String? contactEmail;
  final Duration spacing;
  final Future<void> Function(Duration) sleep;
  DateTime? _quotaUntil;

  MyMemoryTranslator(this.gate,
      {this.contactEmail, this.spacing = const Duration(milliseconds: 1200), Future<void> Function(Duration)? sleep})
      : sleep = sleep ?? ((d) => Future<void>.delayed(d));

  @override
  Future<List<String?>> translate(List<String> lines, String src, String tgt, {void Function()? onDownloading, void Function(List<String?> partial)? onPartial}) async {
    final q = _quotaUntil;
    if (q != null && DateTime.now().isBefore(q)) throw TranslateException(TranslateFailure.quota);
    final out = List<String?>.filled(lines.length, null);
    final batches = batchLines(lines);
    for (var b = 0; b < batches.length; b++) {
      if (b > 0) await sleep(spacing);
      final idx = batches[b];
      final text = idx.map((i) => lines[i].trim()).join('\n');
      final uri = Uri.https('api.mymemory.translated.net', '/get', {
        'q': text,
        'langpair': '${myMemoryCode(src)}|${myMemoryCode(tgt)}',
        'de': ?contactEmail,
      });
      final r = await gate.get(uri);
      if (r.statusCode == 429) {
        _quotaUntil = DateTime.now().add(const Duration(hours: 1));
        throw TranslateException(TranslateFailure.quota);
      }
      if (r.statusCode != 200) throw TranslateException(TranslateFailure.failed);
      final j = jsonDecode(utf8.decode(r.bodyBytes));
      if (j is! Map) throw TranslateException(TranslateFailure.failed);
      if (_isQuota(j)) {
        _quotaUntil = DateTime.now().add(const Duration(hours: 1));
        throw TranslateException(TranslateFailure.quota);
      }
      final t = (j['responseData'] as Map?)?['translatedText'];
      if (t is! String) continue;
      final parts = t.split(RegExp(r'\r?\n'));
      if (parts.length == idx.length) {
        for (var k = 0; k < idx.length; k++) {
          final v = parts[k].trim();
          if (v.isNotEmpty) out[idx[k]] = v;
        }
      } else if (idx.length == 1) {
        out[idx.first] = t.trim();
      }
      // Mismatched split: leave that batch untranslated rather than misalign.
      onPartial?.call(List.of(out));
    }
    return out;
  }
}

class MlKitTranslator implements Translator {
  static const _ch = MethodChannel('canto/translate');
  void Function()? _onDl;

  MlKitTranslator() {
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'downloading') _onDl?.call();
    });
  }

  @override
  Future<List<String?>> translate(List<String> lines, String src, String tgt, {void Function()? onDownloading, void Function(List<String?> partial)? onPartial}) async {
    _onDl = onDownloading;
    try {
      final r = await _ch.invokeMethod<List>('translate', {'lines': lines, 'src': src, 'tgt': tgt.split('-').first});
      if (r == null) throw TranslateException(TranslateFailure.failed);
      return [for (final v in r) v is String && v.trim().isNotEmpty ? v : null];
    } on PlatformException catch (e) {
      throw TranslateException(e.code == 'unsupported' ? TranslateFailure.unavailable : TranslateFailure.failed);
    } on MissingPluginException {
      throw TranslateException(TranslateFailure.unavailable);
    } finally {
      _onDl = null;
    }
  }
}

/// Maps translated lines back to display-line indices (timestamps untouched).
Map<int, String>? toLineMap(List<String?> tr) {
  final m = <int, String>{};
  for (var i = 0; i < tr.length; i++) {
    final v = tr[i];
    if (v != null) m[i] = v;
  }
  return m.isEmpty ? null : m;
}
