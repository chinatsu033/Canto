import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Every key in the English template must exist (non-empty) in every locale,
/// with the same placeholders, and no locale may have extra keys.
void main() {
  Map<String, dynamic> load(String l) => jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync()) as Map<String, dynamic>;
  Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();
  final en = load('en');
  for (final l in ['zh', 'zh_Hant', 'ja']) {
    test('$l has full key coverage', () {
      final m = load(l);
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
