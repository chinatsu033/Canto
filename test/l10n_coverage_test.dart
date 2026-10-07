import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Every key in the English template must exist (non-empty) in every locale
/// file, with the same placeholders, and no locale may have extra keys.
void main() {
  Map<String, dynamic> load(File f) => jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();
  final en = load(File('lib/l10n/app_en.arb'));
  final files = Directory('lib/l10n').listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList();
  const required = ['zh', 'zh_Hant', 'zh_Hant_HK', 'en', 'ja', 'ko', 'fr', 'de', 'es', 'pt', 'it', 'ru', 'ar', 'th', 'vi', 'id', 'ms', 'tr', 'hi'];
  test('all required locales exist', () {
    final have = files.map((f) => RegExp(r'app_(.+)\.arb$').firstMatch(f.path)!.group(1)).toSet();
    expect(have.containsAll(required), isTrue, reason: 'missing: ${required.toSet().difference(have)}');
  });
  for (final f in files) {
    test('${f.path} has full key coverage', () {
      final m = load(f);
      expect(keys(m).difference(keys(en)), isEmpty, reason: 'extra keys');
      expect(keys(en).difference(keys(m)), isEmpty, reason: 'missing keys');
      for (final k in keys(en)) {
        expect((m[k] as String).trim(), isNotEmpty, reason: k);
        final ph = RegExp(r'\{(\w+)\}');
        expect(ph.allMatches(m[k] as String).map((e) => e[1]).toSet(),
            ph.allMatches(en[k] as String).map((e) => e[1]).toSet(), reason: 'placeholders in $k');
      }
    });
  }
}
