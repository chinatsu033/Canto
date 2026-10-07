import 'dart:io';
import 'dart:typed_data';
import 'package:dbus/dbus.dart';
import 'package:http/http.dart' as http;
import 'lrclib.dart' show userAgent;
import 'models.dart';
import 'source.dart';

const _root = 'org.mpris.MediaPlayer2';
const _player = 'org.mpris.MediaPlayer2.Player';
const _tracklist = 'org.mpris.MediaPlayer2.TrackList';
final _path = DBusObjectPath('/org/mpris/MediaPlayer2');

/// Linux: MPRIS over the D-Bus session bus (incl. TrackList when exposed).
class MprisSource extends NowPlayingSource {
  DBusClient? _client;
  String? _active;
  DBusObjectPath? _trackId;
  String? _artUrl;
  List<int>? _artBytes;

  DBusClient get client => _client ??= DBusClient.session();

  Future<String?> _pickPlayer() async {
    final names = (await client.listNames()).where((n) => n.startsWith('$_root.')).toList();
    if (names.isEmpty) return null;
    String? paused;
    for (final n in names) {
      try {
        final st = await DBusRemoteObject(client, name: n, path: _path)
            .getProperty(_player, 'PlaybackStatus');
        final s = st.asString();
        if (s == 'Playing') return n;
        if (s == 'Paused' && (paused == null || n == _active)) paused = n;
      } catch (_) {}
    }
    return paused ?? names.first;
  }

  @override
  Future<NowPlaying?> current() async {
    try {
      final name = await _pickPlayer();
      _active = name;
      if (name == null) return null;
      final obj = DBusRemoteObject(client, name: name, path: _path);
      final props = await obj.getAllProperties(_player);
      final meta = (props['Metadata']?.toNative() as Map?) ?? {};
      String str(String k) {
        final v = meta[k];
        if (v is Iterable) return v.join(', ');
        return v?.toString() ?? '';
      }
      final lenUs = meta['mpris:length'];
      final posUs = props['Position']?.toNative();
      final rootProps = await obj.getAllProperties(_root).catchError((_) => <String, DBusValue>{});
      final hasTrackList = rootProps['HasTrackList']?.toNative() == true;
      _trackId = meta['mpris:trackid'] is DBusObjectPath ? meta['mpris:trackid'] as DBusObjectPath : null;
      final title = str('xesam:title');
      if (title.isEmpty) return null;
      final art = await _artwork(str('mpris:artUrl'));
      return NowPlaying(
        title: title,
        artist: str('xesam:artist'),
        album: str('xesam:album'),
        duration: lenUs is num && lenUs > 0 ? Duration(microseconds: lenUs.toInt()) : null,
        position: posUs is num ? Duration(microseconds: posUs.toInt()) : Duration.zero,
        positionAt: DateTime.now(),
        playing: props['PlaybackStatus']?.toNative() == 'Playing',
        rate: (props['Rate']?.toNative() as num?)?.toDouble() ?? 1.0,
        artwork: art == null ? null : Uint8List.fromList(art),
        sourceApp: name,
        sourceName: rootProps['Identity']?.toNative()?.toString() ?? name.substring(_root.length + 1),
        canPlayPause: props['CanPause']?.toNative() != false || props['CanPlay']?.toNative() != false,
        canFavorite: false, // MPRIS has no standard favorite/rating command
        canSeek: props['CanSeek']?.toNative() == true && meta['mpris:trackid'] != null,
        canGoToQueueItem: hasTrackList,
        queue: hasTrackList ? await _queue(obj, meta['mpris:trackid']?.toString()) : null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<QueueItem>?> _queue(DBusRemoteObject obj, String? currentId) async {
    try {
      final tracks = (await obj.getProperty(_tracklist, 'Tracks')).asObjectPathArray().toList();
      if (tracks.isEmpty) return null;
      final res = await obj.callMethod(_tracklist, 'GetTracksMetadata',
          [DBusArray.objectPath(tracks)], replySignature: DBusSignature('aa{sv}'));
      final list = res.values.first.toNative() as Iterable;
      return [
        for (final m in list.cast<Map>())
          QueueItem(
            m['xesam:title']?.toString() ?? '',
            m["xesam:artist"] is Iterable ? (m["xesam:artist"] as Iterable).join(', ') : m['xesam:artist']?.toString(),
            current: m['mpris:trackid']?.toString() == currentId,
            id: (m['mpris:trackid'] as DBusObjectPath?)?.value,
          )
      ];
    } catch (_) {
      return null;
    }
  }

  Future<List<int>?> _artwork(String url) async {
    if (url.isEmpty) return null;
    if (url == _artUrl) return _artBytes;
    _artUrl = url;
    _artBytes = null;
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'file') {
        _artBytes = await File(uri.toFilePath()).readAsBytes();
      } else if (uri.scheme == 'http' || uri.scheme == 'https') {
        final r = await http.get(uri, headers: {'User-Agent': userAgent});
        if (r.statusCode == 200) _artBytes = r.bodyBytes;
      }
    } catch (_) {}
    return _artBytes;
  }

  @override
  Future<CommandResult> playPause() async {
    final n = _active;
    if (n == null) return CommandResult.unsupported;
    try {
      await DBusRemoteObject(client, name: n, path: _path).callMethod(_player, 'PlayPause', []);
      return CommandResult.ok;
    } catch (_) {
      return CommandResult.failed;
    }
  }

  @override
  Future<CommandResult> favorite() async => CommandResult.unsupported;

  @override
  Future<CommandResult> seek(Duration position) async {
    final n = _active, id = _trackId;
    if (n == null || id == null) return CommandResult.unsupported;
    try {
      await DBusRemoteObject(client, name: n, path: _path)
          .callMethod(_player, 'SetPosition', [id, DBusInt64(position.inMicroseconds)]);
      return CommandResult.ok;
    } catch (_) {
      return CommandResult.failed;
    }
  }

  @override
  Future<CommandResult> goToQueueItem(String id) async {
    final n = _active;
    if (n == null) return CommandResult.unsupported;
    try {
      await DBusRemoteObject(client, name: n, path: _path).callMethod(_tracklist, 'GoTo', [DBusObjectPath(id)]);
      return CommandResult.ok;
    } catch (_) {
      return CommandResult.failed;
    }
  }

  @override
  void dispose() {
    _client?.close();
  }
}
