import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'models.dart';
import 'mpris.dart';

enum CommandResult { ok, unsupported, failed }

abstract class NowPlayingSource {
  Future<NowPlaying?> current();
  Future<CommandResult> playPause();
  Future<CommandResult> favorite();
  Future<bool> hasPermission() async => true;
  Future<void> requestPermission() async {}
  void dispose() {}

  static NowPlayingSource create() {
    if (Platform.isLinux) return MprisSource();
    return ChannelSource();
  }
}

/// Native implementations (Android Kotlin, macOS Swift, Windows C++/WinRT).
class ChannelSource extends NowPlayingSource {
  static const _ch = MethodChannel('canto/now_playing');

  @override
  Future<NowPlaying?> current() async {
    try {
      final m = await _ch.invokeMethod<Map<dynamic, dynamic>>('get');
      return NowPlaying.fromMap(m);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<CommandResult> _cmd(String name) async {
    try {
      final r = await _ch.invokeMethod<String>(name);
      return switch (r) {
        'ok' => CommandResult.ok,
        'unsupported' => CommandResult.unsupported,
        _ => CommandResult.failed,
      };
    } catch (_) {
      return CommandResult.failed;
    }
  }

  @override
  Future<CommandResult> playPause() => _cmd('playPause');
  @override
  Future<CommandResult> favorite() => _cmd('favorite');

  @override
  Future<bool> hasPermission() async {
    try {
      return await _ch.invokeMethod<bool>('hasPermission') ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      await _ch.invokeMethod('requestPermission');
    } catch (_) {}
  }
}
