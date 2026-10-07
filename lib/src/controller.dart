import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'translate.dart';
import 'package:flutter/material.dart';
import 'lrc.dart';
import 'lrclib.dart';
import 'lyrics_provider.dart';
import 'lrcapi.dart';
import 'lrcshare.dart';
import 'net.dart';
import 'romanize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'palette.dart';
import 'source.dart';

typedef LyricsFetcher = Future<(LyricsResult, String?)> Function(NowPlaying np);

class CantoController extends ChangeNotifier {
  final NowPlayingSource source;
  final LyricsFetcher fetchLyrics;
  final LyricsCache _cache = LyricsCache();
  final Duration pollInterval;
  Timer? _poll;
  bool _busy = false;

  NowPlaying? nowPlaying;
  LyricsResult? lyrics; // null => loading
  String? lyricsSource; // provider name, e.g. LRCLIB
  Color? accent;
  bool permissionGranted = true;
  String? _trackKey;
  String? _accentFor;

  CantoController({
    required this.source,
    LyricsFetcher? fetchLyrics,
    this.pollInterval = const Duration(seconds: 1),
    LrcShareSession? extras,
    this.translator,
  })  : fetchLyrics = fetchLyrics ?? _defaultFetcher,
        extras = extras ?? (fetchLyrics == null ? lrcShare : null);

  // Sources, queried sequentially: LRCLIB -> LrcAPI -> LrcShare.
  static final gate = HttpGate();
  static final lrcShare = LrcShareSession(LrcShareClient(gate));
  static final _chain = ProviderChain([LrclibProvider(gate), LrcApiProvider(gate), LrcShareProvider(lrcShare)]);
  static Future<(LyricsResult, String?)> _defaultFetcher(NowPlaying np) => _chain.fetch(np);

  /// LrcShare data source for translation/romanization/cover (null in tests).
  final LrcShareSession? extras;

  bool showTranslation = false;
  bool showRomanization = false;
  Map<int, String>? translation; // displayed line index -> text
  Map<int, String>? romanization;
  bool romanizationAuto = false; // generated locally, not from LrcShare
  bool translationAuto = false; // machine-translated (ML Kit / MyMemory)
  /// null, 'working', 'downloading', 'quota', 'failed', 'unavailable'
  String? translateStatus;
  final Translator? translator;
  String? _translatedFor;
  LyricsResult? _extrasFor;

  static Translator? defaultTranslator() {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return MlKitTranslator();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) return MyMemoryTranslator(gate);
    return null;
  }

  String _appTag() {
    final t = localeTag;
    if (t != null) return t;
    final l = PlatformDispatcher.instance.locale;
    final hant = l.scriptCode == 'Hant' || const ['TW', 'HK', 'MO'].contains(l.countryCode);
    if (l.languageCode == 'zh') return hant ? 'zh_Hant' : 'zh';
    const supported = ['en', 'ja', 'ko', 'fr', 'de', 'es', 'pt', 'it', 'ru', 'ar', 'th', 'vi', 'id', 'ms', 'tr', 'hi'];
    return supported.contains(l.languageCode) ? l.languageCode : 'zh'; // same default as the UI
  }

  Future<void> _autoTranslate() async {
    final np = nowPlaying;
    final res = lyrics;
    final tr = translator;
    if (np == null || res is! SyncedLyrics || tr == null || translation != null) return;
    final key = np.trackKey;
    if (_translatedFor == key) return;
    _translatedFor = key;
    final texts = [for (final l in res.lines) l.text];
    final src = guessLang(texts.join());
    final tgt = targetLangFor(_appTag(), src);
    translateStatus = 'working';
    notifyListeners();
    try {
      final out = await tr.translate(texts, src, tgt, onDownloading: () {
        if (_trackKey == key) {
          translateStatus = 'downloading';
          notifyListeners();
        }
      }, onPartial: (part) {
        final m = toLineMap(part);
        if (_trackKey == key && m != null) {
          translation = m;
          translationAuto = true;
          notifyListeners();
        }
      });
      if (_trackKey != key) return;
      translation = toLineMap(out);
      translationAuto = translation != null;
      translateStatus = translation == null ? 'failed' : null;
    } on TranslateException catch (e) {
      debugPrint('DBG tex ${e.kind}');
      if (_trackKey != key) return;
      translateStatus = e.kind.name;
      if (e.kind == TranslateFailure.failed) _translatedFor = null; // allow retry via toggle
    } catch (e) {
      debugPrint('DBG err ${e.runtimeType}');
      if (_trackKey != key) return;
      translateStatus = 'failed';
      _translatedFor = null;
    }
    notifyListeners();
  }
  Color? _fallbackAccent; // from LrcShare cover, this playback only

  /// UI language tag (e.g. 'ja', 'zh_Hant_HK'); null = follow system.
  String? localeTag;

  Future<void> setLocaleTag(String? tag) async {
    localeTag = tag;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      if (tag == null) {
        await p.remove('localeTag');
      } else {
        await p.setString('localeTag', tag);
      }
    } catch (_) {}
  }

  Future<void> loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      localeTag = p.getString('localeTag');
      showTranslation = p.getBool('showTranslation') ?? false;
      showRomanization = p.getBool('showRomanization') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setShowTranslation(bool v) async {
    showTranslation = v;
    notifyListeners();
    if (v && _extrasFor != null && translation == null) unawaited(_autoTranslate());
    try {
      (await SharedPreferences.getInstance()).setBool('showTranslation', v);
    } catch (_) {}
  }

  Future<void> setShowRomanization(bool v) async {
    showRomanization = v;
    notifyListeners();
    try {
      (await SharedPreferences.getInstance()).setBool('showRomanization', v);
    } catch (_) {}
  }

  Future<void> _loadExtras(NowPlaying np, LyricsResult res) async {
    final key = np.trackKey;
    if (res is SyncedLyrics) {
      // Local fallback first (instant, offline); LrcShare overrides below.
      romanization = autoRomanize(res.lines);
      romanizationAuto = romanization != null;
      notifyListeners();
    }
    final ex = extras;
    final data = ex == null ? null : await ex.forTrack(np);
    if (_trackKey != key) return;
    if (data == null) {
      _extrasFor = res;
      if (showTranslation && translation == null) await _autoTranslate();
      return;
    }
    if (res is SyncedLyrics) {
      final lang = originalLangOf(data, res.lines);
      final tr = pickTranslation(data.versions, lang);
      final ro = pickRomanization(data.versions, lang);
      translation = tr == null ? null : alignByTimestamp(res.lines, tr.rows);
      final aligned = ro == null ? null : alignByTimestamp(res.lines, ro.rows);
      if (aligned != null) {
        romanization = aligned;
        romanizationAuto = false;
      }
    }
    if (np.artwork == null && data.song.cover != null) {
      try {
        final r = await gate.get(Uri.parse(data.song.cover!));
        if (r.statusCode == 200 && _trackKey == key) {
          _fallbackAccent = await dominantColor(r.bodyBytes);
        }
      } catch (_) {}
    }
    if (_trackKey == key) {
      _extrasFor = res;
      notifyListeners();
      // Only spend translator quota/model download when the user wants translations.
      if (showTranslation && translation == null) await _autoTranslate();
    }
  }

  void start() {
    _tick();
    _poll = Timer.periodic(pollInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      permissionGranted = await source.hasPermission();
      final np = permissionGranted ? await source.current() : null;
      await update(np);
    } finally {
      _busy = false;
    }
  }

  /// Applies a new snapshot; public for tests.
  Future<void> update(NowPlaying? np) async {
    nowPlaying = np;
    final key = np?.trackKey;
    if (key != _trackKey) {
      _trackKey = key;
      _cache.clear(); // previous track's lyrics are no longer needed
      lyrics = null;
      lyricsSource = null;
      translation = null;
      translationAuto = false;
      translateStatus = null;
      _translatedFor = null;
      _extrasFor = null;
      romanization = null;
      romanizationAuto = false;
      _fallbackAccent = null;
      extras?.clear();
      if (np != null) _load(np);
    }
    if (np?.artwork == null) {
      accent = _fallbackAccent;
      _accentFor = null;
    } else if (_accentFor != key) {
      _accentFor = key;
      final c = await dominantColor(np!.artwork!);
      if (_trackKey == key) accent = c;
    }
    notifyListeners();
  }

  Future<void> _load(NowPlaying np) async {
    final key = np.trackKey;
    final cached = _cache.get(key);
    if (cached != null) {
      lyrics = cached;
      notifyListeners();
      return;
    }
    final (res, src) = await fetchLyrics(np);
    if (_trackKey != key) return; // track changed meanwhile; drop result
    if (res is! LyricsError) _cache.put(key, res);
    lyrics = res;
    lyricsSource = src;
    notifyListeners();
    await _loadExtras(np, res);
  }

  void retry() {
    final np = nowPlaying;
    if (np == null) return;
    lyrics = null;
    notifyListeners();
    _load(np);
  }

  /// Seeks via the system session; updates the local position on success.
  Future<CommandResult> seek(Duration p) async {
    final np = nowPlaying;
    if (np == null || !np.canSeek) return CommandResult.unsupported;
    final r = await source.seek(p);
    if (r == CommandResult.ok && nowPlaying?.trackKey == np.trackKey) {
      nowPlaying = nowPlaying!.withPosition(p);
      notifyListeners();
    }
    return r;
  }

  Duration positionNow([DateTime? now]) {
    final np = nowPlaying;
    if (np == null) return Duration.zero;
    return extrapolatePosition(
      reported: np.position,
      reportedAt: np.positionAt,
      now: now ?? DateTime.now(),
      playing: np.playing,
      rate: np.rate,
      duration: np.duration,
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    _cache.clear();
    extras?.clear();
    source.dispose();
    super.dispose();
  }
}
