import 'lrclib.dart';
import 'models.dart';

/// A lyrics source. Only licensed / openly-licensed sources may implement this
/// (currently LRCLIB). A licensed provider such as the official Musixmatch API
/// with the user's own key could be added later by implementing this.
abstract class LyricsProvider {
  /// Display name shown in the UI (e.g. "Lyrics from LRCLIB").
  String get name;
  Future<LyricsResult> fetch(NowPlaying np);
}

/// Queries providers strictly in order (never in parallel) and stops at the
/// first synced result. Plain lyrics are remembered as a fallback; an
/// explicit "instrumental" answer ends the search (纯音乐).
class ProviderChain {
  final List<LyricsProvider> providers;
  const ProviderChain(this.providers);

  Future<(LyricsResult, String?)> fetch(NowPlaying np) async {
    var sawError = false;
    (LyricsResult, String)? plain;
    for (final p in providers) {
      LyricsResult r;
      try {
        r = await p.fetch(np);
      } catch (_) {
        r = const LyricsError();
      }
      if (r is SyncedLyrics) return (r, p.name);
      if (r is Instrumental && plain == null) return (r, p.name);
      if (r is PlainLyrics) plain ??= (r, p.name);
      if (r is LyricsError) sawError = true;
    }
    if (plain != null) return plain;
    return (sawError ? const LyricsError() : const NoLyrics(), null);
  }
}
