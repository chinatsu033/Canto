// ignore_for_file: avoid_print
// Dev helper: exposes a fake MPRIS player with placeholder metadata so the
// Linux build can be smoke-tested without a real player. No audio involved.
// Run: dart run tool/fake_mpris.dart
import 'package:dbus/dbus.dart';

class FakePlayer extends DBusObject {
  FakePlayer() : super(DBusObjectPath('/org/mpris/MediaPlayer2'));
  bool playing = true;
  final started = DateTime.now();

  Map<String, DBusValue> get _player => {
        'PlaybackStatus': DBusString(playing ? 'Playing' : 'Paused'),
        'Rate': const DBusDouble(1),
        'Position': DBusInt64(DateTime.now().difference(started).inMicroseconds),
        'CanPlay': const DBusBoolean(true),
        'CanPause': const DBusBoolean(true),
        'Metadata': DBusDict.stringVariant({
          'mpris:trackid': DBusObjectPath('/canto/track/1'),
          'xesam:title': const DBusString('Canto Placeholder Track'),
          'xesam:artist': DBusArray.string(['Nobody In Particular']),
          'xesam:album': const DBusString('Test Album'),
          'mpris:length': const DBusInt64(180000000),
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
      return DBusGetAllPropertiesResponse({'Tracks': DBusArray.objectPath([DBusObjectPath('/canto/track/1'), DBusObjectPath('/canto/track/2')])});
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
    if (call.name == 'GetTracksMetadata') {
      return DBusMethodSuccessResponse([
        DBusArray(DBusSignature('a{sv}'), [
          DBusDict.stringVariant({'mpris:trackid': DBusObjectPath('/canto/track/1'), 'xesam:title': const DBusString('Canto Placeholder Track')}),
          DBusDict.stringVariant({'mpris:trackid': DBusObjectPath('/canto/track/2'), 'xesam:title': const DBusString('Second Placeholder')}),
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
