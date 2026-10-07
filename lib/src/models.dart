import 'dart:typed_data';

enum FavoriteSupport { none, supported }

class QueueItem {
  final String title;
  final String? artist;
  final bool current;
  const QueueItem(this.title, this.artist, {this.current = false});
}

/// Snapshot of the system now-playing session. Never contains audio.
class NowPlaying {
  final String title;
  final String artist;
  final String album;
  final Duration? duration;
  final Duration position;
  final DateTime positionAt;
  final bool playing;
  final double rate;
  final Uint8List? artwork;
  final String sourceApp; // package / bundle id / AUMID / MPRIS bus name
  final String sourceName;
  final bool canPlayPause;
  final bool canFavorite;
  final List<QueueItem>? queue; // null => player doesn't expose a queue

  const NowPlaying({
    required this.title,
    required this.artist,
    this.album = '',
    this.duration,
    this.position = Duration.zero,
    required this.positionAt,
    this.playing = false,
    this.rate = 1.0,
    this.artwork,
    this.sourceApp = '',
    this.sourceName = '',
    this.canPlayPause = true,
    this.canFavorite = false,
    this.queue,
  });

  String get trackKey => '$sourceApp|$title|$artist|$album';

  static NowPlaying? fromMap(Map<dynamic, dynamic>? m) {
    if (m == null) return null;
    final title = (m['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) return null;
    final durMs = (m['durationMs'] as num?)?.toInt();
    final posMs = (m['positionMs'] as num?)?.toInt() ?? 0;
    final q = m['queue'] as List<dynamic>?;
    return NowPlaying(
      title: title,
      artist: (m['artist'] as String?) ?? '',
      album: (m['album'] as String?) ?? '',
      duration: durMs != null && durMs > 0 ? Duration(milliseconds: durMs) : null,
      position: Duration(milliseconds: posMs),
      positionAt: m['positionAtMs'] is num
          ? DateTime.fromMillisecondsSinceEpoch((m['positionAtMs'] as num).toInt())
          : DateTime.now(),
      playing: m['playing'] == true,
      rate: (m['rate'] as num?)?.toDouble() ?? 1.0,
      artwork: m['artwork'] is Uint8List ? m['artwork'] as Uint8List : null,
      sourceApp: (m['sourceApp'] as String?) ?? '',
      sourceName: (m['sourceName'] as String?) ?? '',
      canPlayPause: m['canPlayPause'] != false,
      canFavorite: m['canFavorite'] == true,
      queue: q == null
          ? null
          : [
              for (final e in q.cast<Map<dynamic, dynamic>>())
                QueueItem((e['title'] as String?) ?? '', e['artist'] as String?,
                    current: e['current'] == true)
            ],
    );
  }
}
