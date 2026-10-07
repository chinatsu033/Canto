// ignore_for_file: avoid_print
// Dev helper: exposes a fake MPRIS player with placeholder metadata so the
// Linux build can be smoke-tested without a real player. No audio involved.
// Run: dart run tool/fake_mpris.dart
import 'dart:io';
import 'package:dbus/dbus.dart';

final _env = Platform.environment;

class FakePlayer extends DBusObject {
  FakePlayer() : super(DBusObjectPath('/org/mpris/MediaPlayer2'));
  bool playing = true;
  int current = 1; // index into tracks 1..3
  final ignoreGoTo = _env['FAKE_IGNORE_GOTO'] == '1';
  final started = DateTime.now();

  Map<String, DBusValue> get _player => {
        'PlaybackStatus': DBusString(playing ? 'Playing' : 'Paused'),
        'Rate': const DBusDouble(1),
        'Position': DBusInt64(DateTime.now().difference(started).inMicroseconds),
        'CanPlay': const DBusBoolean(true),
        'CanPause': const DBusBoolean(true),
        'CanSeek': const DBusBoolean(true),
        'CanGoNext': const DBusBoolean(true),
        'CanGoPrevious': const DBusBoolean(true),
        'Metadata': DBusDict.stringVariant({
          'mpris:trackid': DBusObjectPath('/canto/track/$current'),
          'xesam:title': DBusString(current == 1 ? (_env['FAKE_TITLE'] ?? 'Canto Placeholder Track') : 'Placeholder $current'),
          'xesam:artist': DBusArray.string([_env['FAKE_ARTIST'] ?? 'Nobody In Particular']),
          'xesam:album': DBusString(_env['FAKE_ALBUM'] ?? 'Test Album'),
          'mpris:length': DBusInt64(int.parse(_env['FAKE_LEN_S'] ?? '180') * 1000000),
        }),
      };
  Map<String, DBusValue> get _root => {
        'Identity': const DBusString('Fake Player'),
        'HasTrackList': const DBusBoolean(true),
      };

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    if (interface == 'org.mpris.MediaPlayer2.Player') return DBusGetAllPropertiesResponse(_player);
    if (interface == 'org.mpris.MediaPlayer2') return DBusGetAllPropertiesResponse(_root);
    if (interface == 'org.mpris.MediaPlayer2.TrackList') {
      return DBusGetAllPropertiesResponse({'Tracks': DBusArray.objectPath([for (var i = 1; i <= 3; i++) DBusObjectPath('/canto/track/$i')])});
    }
    return DBusMethodErrorResponse.unknownInterface();
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    final all = await getAllProperties(interface);
    if (all is DBusGetAllPropertiesResponse) {
      final m = (all.returnValues.first as DBusDict).children.map((k, v) => MapEntry((k as DBusString).value, (v as DBusVariant).value));
      if (m.containsKey(name)) return DBusGetPropertyResponse(m[name]!);
    }
    return DBusMethodErrorResponse.unknownProperty();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall call) async {
    if (call.name == 'PlayPause') {
      playing = !playing;
      print('PlayPause -> playing=$playing');
      return DBusMethodSuccessResponse();
    }
    if (call.name == 'SetPosition') {
      print('${call.name} ${call.values.map((v) => v.toNative()).join(' ')}');
      return DBusMethodSuccessResponse();
    }
    if (call.name == 'GoTo') {
      print('GoTo ${(call.values.first as DBusObjectPath).value}${ignoreGoTo ? ' (ignored)' : ''}');
      if (!ignoreGoTo) current = int.parse((call.values.first as DBusObjectPath).value.split('/').last);
      return DBusMethodSuccessResponse();
    }
    if (call.name == 'Next' || call.name == 'Previous') {
      current = (current + (call.name == 'Next' ? 1 : -1)).clamp(1, 3);
      print('${call.name} -> track $current');
      return DBusMethodSuccessResponse();
    }
    if (call.name == 'GetTracksMetadata') {
      return DBusMethodSuccessResponse([
        DBusArray(DBusSignature('a{sv}'), [
          for (var i = 1; i <= 3; i++)
            DBusDict.stringVariant({'mpris:trackid': DBusObjectPath('/canto/track/$i'), 'xesam:title': DBusString('Placeholder $i')}),
        ])
      ]);
    }
    return DBusMethodErrorResponse.unknownMethod();
  }
}

Future<void> main() async {
  final client = DBusClient.session();
  await client.requestName('org.mpris.MediaPlayer2.cantofake');
  await client.registerObject(FakePlayer());
  print('fake MPRIS player running');
}
