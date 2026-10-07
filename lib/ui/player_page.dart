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

  Future<void> _seek(Duration p) async {
    final r = await c.seek(p);
    if (!mounted) return;
    if (r == CommandResult.unsupported) _toast(AppLocalizations.of(context).seekUnsupported);
    if (r == CommandResult.failed) _toast(AppLocalizations.of(context).commandFailed);
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
                    controller: c,
                    lyrics: c.lyrics,
                    source: c.lyricsSource,
                    position: pos,
                    onSeek: _seek,
                    onClose: () => setState(() => _lyricsOpen = false),
                    onRetry: c.retry,
                  )
                : _ArtworkAndSegment(
                    key: const ValueKey('art'),
                    controller: c,
                    np: np,
                    lyrics: c.lyrics,
                    position: pos,
                    onTapLyrics: () => setState(() => _lyricsOpen = true),
                    onRetry: c.retry,
                  ),
          ),
        ),
      ),
      _Progress(position: pos, duration: np.duration, canSeek: np.canSeek, onSeek: _seek),
      _ControlBar(
        np: np,
        onPlayPause: _playPause,
        onFavorite: () => _favorite(np),
        onQueue: (np.queue?.isNotEmpty ?? false) ? () => _showQueue(np) : null,
      ),
    ]);
  }

  void _showQueue(NowPlaying np) {
    final q = np.queue!;
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(controlRadius)),
                  // Only tappable where the platform can switch to a queue item.
                  onTap: np.canGoToQueueItem && q[i].id != null && !q[i].current
                      ? () async {
                          Navigator.of(ctx).pop();
                          final r = await c.source.goToQueueItem(q[i].id!);
                          if (mounted && r != CommandResult.ok) _toast(l.commandFailed);
                        }
                      : null,
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
  final CantoController controller;
  final LyricsResult? lyrics;
  final Duration position;
  final VoidCallback onTapLyrics, onRetry;
  const _ArtworkAndSegment(
      {super.key, required this.np, required this.controller, required this.lyrics, required this.position, required this.onTapLyrics, required this.onRetry});

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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 10, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Align(alignment: Alignment.centerRight, child: ExtrasToggles(controller: controller)),
                    Expanded(child: Padding(padding: const EdgeInsets.only(right: 6), child: _segment(context))),
                  ]),
                ),
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
      Instrumental() => center(Text(l.instrumental, style: TextStyle(color: cs.onSurfaceVariant))),
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
          final key = ValueKey<int>(i);
          // Apple Music-like: new segment slides up in, old one slides up out.
          return ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (cur, prev) => Stack(alignment: Alignment.centerLeft, children: [...prev, ?cur]),
              transitionBuilder: (child, anim) {
                final incoming = child.key == key;
                final slide = Tween<Offset>(begin: incoming ? const Offset(0, .45) : const Offset(0, -.45), end: Offset.zero)
                    .animate(anim);
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(anim), alignment: Alignment.centerLeft, child: child),
                  ),
                );
              },
              child: Column(
                key: key,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cur.isEmpty ? '♪' : cur,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
                  ...secondaryLines(context, controller, i, compact: true),
                  const SizedBox(height: 8),
                  Text(next, maxLines: 2, overflow: TextOverflow.ellipsis, style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }(),
    };
  }
}

class _LyricsView extends StatefulWidget {
  final CantoController controller;
  final LyricsResult? lyrics;
  final String? source;
  final Duration position;
  final VoidCallback onClose, onRetry;
  final Future<void> Function(Duration) onSeek;
  const _LyricsView(
      {super.key,
      required this.controller,
      required this.lyrics,
      required this.source,
      required this.position,
      required this.onSeek,
      required this.onClose,
      required this.onRetry});
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
        Scrollable.ensureVisible(ctx, alignment: 0.35, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
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
            final dist = (i - idx).abs();
            return GestureDetector(
              key: _keys.putIfAbsent(i, () => GlobalKey()),
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () => widget.onSeek(r.lines[i].time),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                // Cheap emphasis: scale + opacity + colour (no blur).
                child: AnimatedScale(
                  scale: active ? 1.0 : 0.92,
                  alignment: Alignment.centerLeft,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: active ? 1 : (dist == 1 ? .6 : .38),
                    duration: const Duration(milliseconds: 380),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 380),
                      style: tt.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: active ? cs.primary : cs.onSurfaceVariant,
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(text.isEmpty ? '♪' : text),
                        ...secondaryLines(context, widget.controller, i),
                      ]),
                    ),
                  ),
                ),
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
            : Text(r == null ? l.loadingLyrics : (r is Instrumental ? l.instrumental : l.noLyrics),
                style: TextStyle(color: cs.onSurfaceVariant)),
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
        ExtrasToggles(controller: widget.controller),
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
        child: Text(widget.source == null ? '' : l.lyricsFrom(widget.source!),
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ),
    ]);
  }
}

class _Progress extends StatefulWidget {
  final Duration position;
  final Duration? duration;
  final bool canSeek;
  final Future<void> Function(Duration) onSeek;
  const _Progress({required this.position, required this.duration, required this.canSeek, required this.onSeek});
  @override
  State<_Progress> createState() => _ProgressState();
}

class _ProgressState extends State<_Progress> {
  double? _drag; // 0..1 while dragging
  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = widget.duration;
    final total = d?.inMilliseconds ?? 0;
    final live = total == 0 ? 0.0 : (widget.position.inMilliseconds / total).clamp(0.0, 1.0);
    final v = _drag ?? live;
    final shown = total == 0 ? widget.position : Duration(milliseconds: (v * total).round());
    final st = Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant);
    final seekable = widget.canSeek && total > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.surfaceContainerHighest,
            disabledActiveTrackColor: cs.primary,
            disabledInactiveTrackColor: cs.surfaceContainerHighest,
            thumbColor: cs.primary,
            disabledThumbColor: Colors.transparent,
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: _SquareThumb(seekable ? 14 : 0),
            trackShape: const RoundedRectSliderTrackShape(),
            padding: EdgeInsets.zero,
          ),
          child: SizedBox(
            height: 22,
            child: Slider(
              value: v,
              // Display-only when the session can't seek (null handlers).
              onChanged: seekable ? (x) => setState(() => _drag = x) : null,
              onChangeEnd: seekable
                  ? (x) async {
                      await widget.onSeek(Duration(milliseconds: (x * total).round()));
                      if (mounted) setState(() => _drag = null);
                    }
                  : null,
            ),
          ),
        ),
        Row(children: [Text(_fmt(shown), style: st), const Spacer(), if (d != null) Text(_fmt(d), style: st)]),
      ]),
    );
  }
}

/// Rounded-square slider thumb (no circles).
class _SquareThumb extends SliderComponentShape {
  final double size;
  const _SquareThumb(this.size);
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.square(size);
  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    if (size == 0) return;
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size, height: size), const Radius.circular(5));
    context.canvas.drawRRect(r, Paint()..color = sliderTheme.thumbColor ?? Colors.blue);
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


/// Translation / romanization lines for displayed line [i] (LrcShare only).
List<Widget> secondaryLines(BuildContext context, CantoController c, int i, {bool compact = false}) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  final style = (compact ? tt.bodyMedium : tt.titleSmall)
      ?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: .8), fontWeight: FontWeight.w500, height: 1.3);
  final out = <Widget>[];
  final ro = c.showRomanization && c.romanization != null ? c.romanization![i] : null;
  final tr = c.showTranslation && c.translation != null ? c.translation![i] : null;
  if (ro != null) out.add(Padding(padding: const EdgeInsets.only(top: 2), child: Text(ro, maxLines: compact ? 1 : null, overflow: compact ? TextOverflow.ellipsis : null, style: style)));
  if (tr != null) out.add(Padding(padding: const EdgeInsets.only(top: 2), child: Text(tr, maxLines: compact ? 1 : null, overflow: compact ? TextOverflow.ellipsis : null, style: style)));
  return out;
}

/// 翻译 / 罗马音 toggles: rounded-square, default off, persisted; disabled
/// (greyed) when LrcShare has no aligned version for this track.
class ExtrasToggles extends StatelessWidget {
  final CantoController controller;
  const ExtrasToggles({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    Widget chip(String label, bool on, bool enabled, ValueChanged<bool> set) {
      final active = on && enabled;
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: active ? cs.primary.withValues(alpha: .16) : cs.surfaceContainerHighest.withValues(alpha: enabled ? 1 : .5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? () => set(!on) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: !enabled ? cs.onSurfaceVariant.withValues(alpha: .4) : (active ? cs.primary : cs.onSurfaceVariant))),
            ),
          ),
        ),
      );
    }

    final c = controller;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      chip(l.translation, c.showTranslation, c.translation != null, c.setShowTranslation),
      chip(l.romanization, c.showRomanization, c.romanization != null, c.setShowRomanization),
    ]);
  }
}
