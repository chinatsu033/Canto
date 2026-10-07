import 'package:lpinyin/lpinyin.dart';
import 'lrc.dart';

/// Local, deterministic romanization (fallback when LrcShare has none).
/// Timestamps are never changed: the result maps displayed line index -> text.
/// Lines that can't be transliterated (e.g. Japanese kanji without a reading)
/// are skipped.

final _han = RegExp(r'[\u3400-\u9fff\uf900-\ufaff]');
final _kana = RegExp(r'[\u3040-\u30ff]');
final _hangul = RegExp(r'[\uac00-\ud7a3]');

String detectScriptLang(Iterable<String> lines) {
  final s = lines.join();
  if (_kana.hasMatch(s)) return 'ja';
  if (_hangul.hasMatch(s)) return 'ko';
  if (_han.hasMatch(s)) return 'zh';
  return 'other';
}

Map<int, String>? autoRomanize(List<LrcLine> lines) {
  final lang = detectScriptLang(lines.map((l) => l.text));
  String? Function(String) f = switch (lang) {
    'zh' => pinyinLine,
    'ja' => romajiLine,
    'ko' => hangulLine,
    _ => (_) => null,
  };
  final out = <int, String>{};
  for (var i = 0; i < lines.length; i++) {
    final t = lines[i].text;
    if (t.trim().isEmpty) continue;
    final r = f(t);
    if (r != null && r.trim().isNotEmpty && r.trim() != t.trim()) out[i] = r.trim();
  }
  return out.isEmpty ? null : out;
}

/// Chinese -> pinyin with tone marks (bundled dictionary, lpinyin).
String? pinyinLine(String s) {
  if (!_han.hasMatch(s)) return null;
  final b = StringBuffer();
  var prevHan = false;
  for (final ch in s.runes.map(String.fromCharCode)) {
    if (_han.hasMatch(ch)) {
      if (b.isNotEmpty && !b.toString().endsWith(' ')) b.write(' ');
      b.write(PinyinHelper.getPinyinE(ch, separator: ' ', defPinyin: ch, format: PinyinFormat.WITH_TONE_MARK));
      prevHan = true;
    } else {
      if (prevHan && ch.trim().isNotEmpty) b.write(' ');
      b.write(ch);
      prevHan = false;
    }
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}

const _kanaMap = {
  'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
  'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
  'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
  'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
  'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
  'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
  'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
  'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
  'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
  'わ': 'wa', 'ゐ': 'i', 'ゑ': 'e', 'を': 'o', 'ん': 'n',
  'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
  'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
  'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
  'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
  'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
  'ゔ': 'vu', 'ぁ': 'a', 'ぃ': 'i', 'ぅ': 'u', 'ぇ': 'e', 'ぉ': 'o', 'ゎ': 'wa',
};
const _yoon = {'ゃ': 'ya', 'ゅ': 'yu', 'ょ': 'yo'};

String _toHira(String ch) {
  final c = ch.codeUnitAt(0);
  if (c >= 0x30a1 && c <= 0x30f6) return String.fromCharCode(c - 0x60);
  return ch;
}

/// Japanese kana -> Hepburn romaji. Returns null if the line contains kanji
/// (no reading available offline) or no kana.
String? romajiLine(String s) {
  if (_han.hasMatch(s) || !_kana.hasMatch(s)) return null;
  final chars = s.runes.map((r) => _toHira(String.fromCharCode(r))).toList();
  final b = StringBuffer();
  var geminate = false;
  var lastKana = false;
  for (var i = 0; i < chars.length; i++) {
    final ch = chars[i];
    if (ch == 'っ') {
      geminate = true;
      continue;
    }
    if (ch == 'ー') {
      final t = b.toString();
      if (t.isNotEmpty) b.write(t[t.length - 1]);
      continue;
    }
    var r = _kanaMap[ch];
    if (r == null) {
      if (lastKana && ch.trim().isNotEmpty && !RegExp(r'[、。！？!?,.\s]').hasMatch(ch)) b.write(' ');
      b.write(switch (ch) { '、' => ', ', '。' => '. ', '・' => ' ', '　' => ' ', _ => ch });
      lastKana = false;
      geminate = false;
      continue;
    }
    if (i + 1 < chars.length && _yoon.containsKey(chars[i + 1]) && r.length >= 2) {
      final y = _yoon[chars[i + 1]]!;
      final base = r.substring(0, r.length - 1);
      r = switch (base) { 'sh' => 'sh${y.substring(1)}', 'ch' => 'ch${y.substring(1)}', 'j' => 'j${y.substring(1)}', _ => '$base$y' };
      i++;
    }
    if (geminate) {
      b.write(r.startsWith('ch') ? 't' : r[0]);
      geminate = false;
    }
    if (lastKana == false && b.isNotEmpty && !b.toString().endsWith(' ')) b.write(' ');
    b.write(r);
    lastKana = true;
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

const _initials = ['g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp', 's', 'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h'];
const _medials = ['a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i'];
const _finals = ['', 'k', 'k', 'k', 'n', 'n', 'n', 't', 'l', 'k', 'm', 'l', 'l', 'l', 'p', 'l', 'm', 'p', 'p', 't', 't', 'ng', 't', 't', 'k', 't', 'p', 't'];

/// Korean Hangul -> Revised Romanization (syllable-by-syllable; basic
/// liaison of a final consonant before a vowel-initial syllable).
String? hangulLine(String s) {
  if (!_hangul.hasMatch(s)) return null;
  final b = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c < 0xac00 || c > 0xd7a3) {
      b.write(String.fromCharCode(c));
      continue;
    }
    final idx = c - 0xac00;
    final ini = idx ~/ 588, med = (idx % 588) ~/ 28, fin = idx % 28;
    var init = _initials[ini];
    if (ini == 5 && (i == 0 || runes[i - 1] < 0xac00 || runes[i - 1] > 0xd7a3)) init = 'r';
    b.write(init);
    b.write(_medials[med]);
    var f = _finals[fin];
    final next = i + 1 < runes.length ? runes[i + 1] : 0;
    final nextVowelInitial = next >= 0xac00 && next <= 0xd7a3 && (next - 0xac00) ~/ 588 == 11;
    if (nextVowelInitial && fin != 0 && fin != 21) {
      // liaison: carry the consonant over as an initial sound
      f = switch (fin) { 1 => 'g', 4 => 'n', 7 => 'd', 8 => 'r', 16 => 'm', 17 => 'b', 19 => 's', 22 => 'j', 23 => 'ch', 24 => 'k', 25 => 't', 26 => 'p', 27 => 'h', _ => f };
    }
    b.write(f);
  }
  return b.toString();
}
