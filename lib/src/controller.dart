import 'dart:async';
import 'package:flutter/material.dart';
import 'lrc.dart';
import 'lrclib.dart';
import 'models.dart';
import 'palette.dart';
import 'source.dart';

typedef LyricsFetcher = Future<LyricsResult> Function(NowPlaying np);

class CantoController extends ChangeNotifier {
  final NowPlayingSource source;
  final LyricsFetcher fetchLyrics;
  final LyricsCache _cache = LyricsCache();
  final Duration pollInterval;
  Timer? _poll;
  bool _busy = false;

  NowPlaying? nowPlaying;
  LyricsResult? lyrics; // null => loading
  Color? accent;
  bool permissionGranted = true;
  String? _trackKey;
  String? _accentFor;

  CantoController({
    required this.source,
    LyricsFetcher? fetchLyrics,
    this.pollInterval = const Duration(seconds: 1),
  }) : fetchLyrics = fetchLyrics ?? _defaultFetcher;

  static final _client = LrclibClient();
  static Future<LyricsResult> _defaultFetcher(NowPlaying np) => _client.fetch(
      title: np.title, artist: np.artist, album: np.album, duration: np.duration);

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
      if (np != null) _load(np);
    }
    if (np?.artwork == null) {
      accent = null;
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
    final res = await fetchLyrics(np);
    if (_trackKey != key) return; // track changed meanwhile; drop result
    if (res is! LyricsError) _cache.put(key, res);
    lyrics = res;
    notifyListeners();
  }

  void retry() {
    final np = nowPlaying;
    if (np == null) return;
    lyrics = null;
    notifyListeners();
    _load(np);
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
    source.dispose();
    super.dispose();
  }
}
