import 'dart:async';
import 'package:flutter/material.dart';
import 'lrc.dart';
import 'lrclib.dart';
import 'lyrics_provider.dart';
import 'lrcapi.dart';
import 'lrcshare.dart';
import 'net.dart';
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
  Color? _fallbackAccent; // from LrcShare cover, this playback only

  Future<void> loadPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      showTranslation = p.getBool('showTranslation') ?? false;
      showRomanization = p.getBool('showRomanization') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setShowTranslation(bool v) async {
    showTranslation = v;
    notifyListeners();
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
    final ex = extras;
    if (ex == null) return;
    final key = np.trackKey;
    final data = await ex.forTrack(np);
    if (_trackKey != key || data == null) return;
    if (res is SyncedLyrics) {
      final lang = originalLangOf(data, res.lines);
      final tr = pickTranslation(data.versions, lang);
      final ro = pickRomanization(data.versions, lang);
      translation = tr == null ? null : alignByTimestamp(res.lines, tr.rows);
      romanization = ro == null ? null : alignByTimestamp(res.lines, ro.rows);
    }
    if (np.artwork == null && data.song.cover != null) {
      try {
        final r = await gate.get(Uri.parse(data.song.cover!));
        if (r.statusCode == 200 && _trackKey == key) {
          _fallbackAccent = await dominantColor(r.bodyBytes);
        }
      } catch (_) {}
    }
    if (_trackKey == key) notifyListeners();
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
      romanization = null;
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
