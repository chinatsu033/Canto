import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/controller.dart';
import '../src/favorite_style.dart';
import '../src/lrc.dart';
import '../src/lrclib.dart';
import '../src/models.dart';
import '../src/source.dart';
import '../src/theme.dart';

class PlayerPage extends StatefulWidget {
  final CantoController controller;
  final bool showLyricsView; // initial state (used for screenshots)
  const PlayerPage({super.key, required this.controller, this.showLyricsView = false});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with SingleTickerProviderStateMixin {
  late bool _lyricsOpen = widget.showLyricsView;
  Timer? _clock;

  CantoController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    // Repaint lyrics a few times a second; position is extrapolated locally.
    _clock = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && (c.nowPlaying?.playing ?? false)) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _favorite(NowPlaying np) async {
    final l = AppLocalizations.of(context);
    if (!np.canFavorite) return _toast(l.favoriteUnsupported);
    final r = await c.source.favorite();
    if (!mounted) return;
    _toast(switch (r) {
      CommandResult.ok => l.favoriteSent(np.sourceName.isEmpty ? np.sourceApp : np.sourceName),
      CommandResult.unsupported => l.favoriteUnsupported,
      CommandResult.failed => l.favoriteFailed,
    });
  }

  Future<void> _playPause() async {
    final r = await c.source.playPause();
    if (!mounted) return;
    if (r == CommandResult.unsupported) _toast(AppLocalizations.of(context).controlUnsupported);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final np = c.nowPlaying;
    if (!c.permissionGranted) return _PermissionCard(onGrant: c.source.requestPermission);
    if (np == null) {
      return _Empty(title: l.nothingPlaying, body: l.nothingPlayingHint);
    }
    final pos = c.positionNow();
    return Column(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _lyricsOpen
                ? _LyricsView(
                    key: const ValueKey('lyrics'),
                    lyrics: c.lyrics,
                    position: pos,
                    onClose: () => setState(() => _lyricsOpen = false),
                    onRetry: c.retry,
                  )
                : _ArtworkAndSegment(
                    key: const ValueKey('art'),
                    np: np,
                    lyrics: c.lyrics,
                    position: pos,
                    onTapLyrics: () => setState(() => _lyricsOpen = true),
                    onRetry: c.retry,
                  ),
          ),
        ),
      ),
      _Progress(position: pos, duration: np.duration),
      _ControlBar(
        np: np,
        onPlayPause: _playPause,
        onFavorite: () => _favorite(np),
        onQueue: (np.queue?.isNotEmpty ?? false) ? () => _showQueue(np.queue!) : null,
      ),
    ]);
  }

  void _showQueue(List<QueueItem> q) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(l.upNext, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: q.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(q[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: q[i].current ? cs.primary : null, fontWeight: q[i].current ? FontWeight.w600 : null)),
                  subtitle: q[i].artist == null ? null : Text(q[i].artist!, maxLines: 1),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  final String title, body;
  const _Empty({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lyrics_outlined, size: 40, color: cs.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final Future<void> Function() onGrant;
  const _PermissionCard({required this.onGrant});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_active_outlined, size: 40, color: cs.primary),
              const SizedBox(height: 12),
              Text(l.permissionTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(l.permissionBody, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              FilledButton(onPressed: onGrant, child: Text(l.grantPermission)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ArtworkAndSegment extends StatelessWidget {
  final NowPlaying np;
  final LyricsResult? lyrics;
  final Duration position;
  final VoidCallback onTapLyrics, onRetry;
  const _ArtworkAndSegment(
      {super.key, required this.np, required this.lyrics, required this.position, required this.onTapLyrics, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, box) {
      final side = (box.maxWidth).clamp(0.0, box.maxHeight * 0.52);
      return Column(children: [
        const SizedBox(height: 8),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: SizedBox.square(
              dimension: side,
              child: np.artwork != null
                  ? Image.memory(np.artwork!, fit: BoxFit.cover, gaplessPlayback: true)
                  : Container(color: cs.surfaceContainer, child: Icon(Icons.music_note, size: side / 3, color: cs.primary)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(np.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text([np.artist, np.album].where((s) => s.isNotEmpty).join(' · '),
            maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 14),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapLyrics,
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(padding: const EdgeInsets.all(16), child: _segment(context)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ]);
    });
  }

  Widget _segment(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final r = lyrics;
    Widget center(Widget w) => Center(child: w);
    return switch (r) {
      null => center(Text(l.loadingLyrics, style: TextStyle(color: cs.onSurfaceVariant))),
      NoLyrics() => center(Text(l.noLyrics, style: TextStyle(color: cs.onSurfaceVariant))),
      LyricsError() => center(TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text('${l.lyricsError} · ${l.retry}'))),
      PlainLyrics(:final lines) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.plainLyricsNote, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Expanded(
            child: Text(lines.where((s) => s.trim().isNotEmpty).take(4).join('\n'),
                overflow: TextOverflow.fade, style: tt.bodyLarge),
          ),
        ]),
      SyncedLyrics(:final lines) => () {
          final i = activeLineIndex(lines, position);
          final cur = i >= 0 ? lines[i].text : '♪';
          final next = i + 1 < lines.length ? lines[i + 1].text : '';
          return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cur.isEmpty ? '♪' : cur,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
            const SizedBox(height: 8),
            Text(next, maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
          ]);
        }(),
    };
  }
}

class _LyricsView extends StatefulWidget {
  final LyricsResult? lyrics;
  final Duration position;
  final VoidCallback onClose, onRetry;
  const _LyricsView({super.key, required this.lyrics, required this.position, required this.onClose, required this.onRetry});
  @override
  State<_LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<_LyricsView> {
  final _scroll = ScrollController();
  final _keys = <int, GlobalKey>{};
  bool _follow = true;
  Timer? _resume;
  int _lastIndex = -2;

  @override
  void dispose() {
    _resume?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n is UserScrollNotification || (n is ScrollUpdateNotification && n.dragDetails != null)) {
      _follow = false;
      _resume?.cancel();
      _resume = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() { _follow = true; _lastIndex = -2; });
      });
      setState(() {});
    }
    return false;
  }

  void _ensure(int i) {
    if (!_follow || i == _lastIndex) return;
    _lastIndex = i;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[i < 0 ? 0 : i]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.35, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final r = widget.lyrics;
    Widget body;
    if (r is SyncedLyrics) {
      final idx = activeLineIndex(r.lines, widget.position);
      _ensure(idx);
      body = NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 4),
          itemCount: r.lines.length,
          itemBuilder: (_, i) {
            final active = i == idx;
            final text = r.lines[i].text;
            return Padding(
              key: _keys.putIfAbsent(i, () => GlobalKey()),
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: tt.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: active ? cs.primary : cs.onSurfaceVariant.withValues(alpha: .55),
                ),
                child: Text(text.isEmpty ? '♪' : text),
              ),
            );
          },
        ),
      );
    } else if (r is PlainLyrics) {
      body = ListView(padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4), children: [
        Text(l.plainLyricsNote, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        for (final s in r.lines)
          Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text(s, style: tt.titleLarge)),
      ]);
    } else {
      body = Center(
        child: r is LyricsError
            ? TextButton.icon(onPressed: widget.onRetry, icon: const Icon(Icons.refresh), label: Text('${l.lyricsError} · ${l.retry}'))
            : Text(r == null ? l.loadingLyrics : l.noLyrics, style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }
    return Column(children: [
      Row(children: [
        IconButton.filledTonal(
          tooltip: l.back,
          onPressed: widget.onClose,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        const Spacer(),
        if (!_follow && r is SyncedLyrics)
          TextButton.icon(
            onPressed: () => setState(() { _follow = true; _lastIndex = -2; }),
            icon: const Icon(Icons.my_location, size: 18),
            label: Text(l.resumeFollow),
          ),
      ]),
      Expanded(child: body),
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(l.lyricsBy, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ),
    ]);
  }
}

class _Progress extends StatelessWidget {
  final Duration position;
  final Duration? duration;
  const _Progress({required this.position, required this.duration});
  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = duration;
    final v = d == null || d.inMilliseconds == 0 ? 0.0 : (position.inMilliseconds / d.inMilliseconds).clamp(0.0, 1.0);
    final st = Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: v, minHeight: 4, backgroundColor: cs.surfaceContainerHighest, color: cs.primary),
        ),
        const SizedBox(height: 4),
        Row(children: [Text(_fmt(position), style: st), const Spacer(), if (d != null) Text(_fmt(d), style: st)]),
      ]),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final NowPlaying np;
  final VoidCallback onPlayPause, onFavorite;
  final VoidCallback? onQueue;
  const _ControlBar({required this.np, required this.onPlayPause, required this.onFavorite, this.onQueue});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final favIcon = switch (favoriteIconFor(np.sourceApp)) {
      FavoriteIcon.plus => Icons.add,
      FavoriteIcon.star => Icons.star_border,
      FavoriteIcon.heart => Icons.favorite_border,
    };
    Widget square(IconData icon, String tip, VoidCallback? onTap, {bool primary = false, bool dim = false}) => Tooltip(
          message: tip,
          child: Material(
            color: primary ? cs.primary : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(controlRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(controlRadius),
              onTap: onTap,
              child: SizedBox(
                width: primary ? 72 : 52,
                height: 52,
                child: Icon(icon,
                    size: primary ? 30 : 24,
                    color: primary ? cs.onPrimary : (dim ? cs.onSurfaceVariant.withValues(alpha: .45) : cs.onSurface)),
              ),
            ),
          ),
        );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(children: [
          if (onQueue != null) square(Icons.queue_music, l.upNext, onQueue) else const SizedBox(width: 52),
          const Spacer(),
          square(np.playing ? Icons.pause : Icons.play_arrow, np.playing ? l.pause : l.play,
              np.canPlayPause ? onPlayPause : null, primary: true),
          const Spacer(),
          // Always tappable so unsupported players explain themselves via toast.
          square(favIcon, l.favorite, onFavorite, dim: !np.canFavorite),
        ]),
      ),
    );
  }
}
