import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private let nowPlaying = NowPlayingBridge()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    // Solid, non-transparent window; corners stay rounded by the system.
    self.isOpaque = true

    RegisterGeneratedPlugins(registry: flutterViewController)
    let channel = FlutterMethodChannel(name: "canto/now_playing",
                                       binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.nowPlaying.handle(call.method, result: result)
    }
    super.awakeFromNib()
  }
}

/// Now-playing reader for macOS.
/// 1. MediaRemote (private framework, loaded at runtime). On macOS 15.4+ Apple
///    restricts it to Apple-entitled processes, so it usually returns nothing.
/// 2. Fallback: AppleScript to Music / Spotify (only if already running;
///    requires the user to allow Automation in System Settings).
final class NowPlayingBridge {
  private typealias GetInfoFn = @convention(c) (DispatchQueue, @escaping @convention(block) (CFDictionary?) -> Void) -> Void
  private typealias GetPidFn = @convention(c) (DispatchQueue, @escaping @convention(block) (Int32) -> Void) -> Void
  private typealias SendCmdFn = @convention(c) (UInt32, CFDictionary?) -> Bool

  private var getInfo: GetInfoFn?
  private var getPid: GetPidFn?
  private var sendCmd: SendCmdFn?
  private let work = DispatchQueue(label: "canto.nowplaying")
  private var lastSource = "" // "mr", "music", "spotify"
  private var artKey = ""
  private var artData: Data?

  init() {
    let path = "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"
    if let h = dlopen(path, RTLD_NOW) {
      if let p = dlsym(h, "MRMediaRemoteGetNowPlayingInfo") { getInfo = unsafeBitCast(p, to: GetInfoFn.self) }
      if let p = dlsym(h, "MRMediaRemoteGetNowPlayingApplicationPID") { getPid = unsafeBitCast(p, to: GetPidFn.self) }
      if let p = dlsym(h, "MRMediaRemoteSendCommand") { sendCmd = unsafeBitCast(p, to: SendCmdFn.self) }
    }
  }

  func handle(_ method: String, result: @escaping FlutterResult) {
    switch method {
    case "get": snapshot { m in DispatchQueue.main.async { result(m) } }
    case "playPause": work.async { let r = self.playPause(); DispatchQueue.main.async { result(r) } }
    case "favorite": work.async { let r = self.favorite(); DispatchQueue.main.async { result(r) } }
    case "hasPermission": result(true)
    case "requestPermission": result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }

  // MARK: snapshot

  private func snapshot(_ done: @escaping ([String: Any]?) -> Void) {
    guard let getInfo = getInfo else { work.async { done(self.scriptSnapshot()) }; return }
    getInfo(work) { dict in
      let info = (dict as NSDictionary?) as? [String: Any] ?? [:]
      guard let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String, !title.isEmpty else {
        done(self.scriptSnapshot())
        return
      }
      let finish: (Int32) -> Void = { pid in
        let app = pid > 0 ? NSRunningApplication(processIdentifier: pid) : nil
        let rate = (info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double) ?? 0
        let elapsed = (info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double) ?? 0
        let ts = (info["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date) ?? Date()
        let bundle = app?.bundleIdentifier ?? ""
        self.lastSource = "mr"
        var m: [String: Any] = [
          "title": title,
          "artist": info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "",
          "album": info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? "",
          "durationMs": Int(((info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double) ?? 0) * 1000),
          "positionMs": Int(elapsed * 1000),
          "positionAtMs": Int(ts.timeIntervalSince1970 * 1000),
          "playing": rate > 0,
          "rate": rate > 0 ? rate : 1.0,
          "sourceApp": bundle,
          "sourceName": app?.localizedName ?? bundle,
          "canPlayPause": true,
          "canFavorite": bundle == "com.apple.Music",
        ]
        if let d = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
          m["artwork"] = FlutterStandardTypedData(bytes: d)
        }
        done(m)
      }
      if let getPid = self.getPid { getPid(self.work, finish) } else { finish(0) }
    }
  }

  private func isRunning(_ id: String) -> Bool {
    !NSRunningApplication.runningApplications(withBundleIdentifier: id).isEmpty
  }

  private func run(_ src: String) -> NSAppleEventDescriptor? {
    var err: NSDictionary?
    let r = NSAppleScript(source: src)?.executeAndReturnError(&err)
    return err == nil ? r : nil
  }

  private func list(_ d: NSAppleEventDescriptor) -> [NSAppleEventDescriptor] {
    guard d.numberOfItems > 0 else { return [] }
    return (1...d.numberOfItems).compactMap { d.atIndex($0) }
  }

  private func scriptSnapshot() -> [String: Any]? {
    let now = Int(Date().timeIntervalSince1970 * 1000)
    if isRunning("com.apple.Music"), let d = run("""
      tell application "Music"
        if player state is stopped then return {}
        set t to current track
        return {name of t, artist of t, album of t, duration of t, player position, (player state is playing)}
      end tell
      """), d.numberOfItems >= 6 {
      let v = list(d)
      lastSource = "music"
      let key = "music|\(v[0].stringValue ?? "")|\(v[1].stringValue ?? "")"
      if key != artKey {
        artKey = key
        artData = run("tell application \"Music\" to get raw data of artwork 1 of current track")?.data
      }
      var m: [String: Any] = [
        "title": v[0].stringValue ?? "", "artist": v[1].stringValue ?? "", "album": v[2].stringValue ?? "",
        "durationMs": Int(v[3].doubleValue * 1000), "positionMs": Int(v[4].doubleValue * 1000),
        "positionAtMs": now, "playing": v[5].booleanValue,
        "sourceApp": "com.apple.Music", "sourceName": "Music", "canPlayPause": true, "canFavorite": true,
      ]
      if let a = artData { m["artwork"] = FlutterStandardTypedData(bytes: a) }
      return m
    }
    if isRunning("com.spotify.client"), let d = run("""
      tell application "Spotify"
        if player state is stopped then return {}
        set t to current track
        return {name of t, artist of t, album of t, duration of t, player position, (player state is playing), artwork url of t}
      end tell
      """), d.numberOfItems >= 7 {
      let v = list(d)
      lastSource = "spotify"
      let key = "spotify|\(v[6].stringValue ?? "")"
      if key != artKey {
        artKey = key
        artData = v[6].stringValue.flatMap { URL(string: $0) }.flatMap { try? Data(contentsOf: $0) }
      }
      var m: [String: Any] = [
        "title": v[0].stringValue ?? "", "artist": v[1].stringValue ?? "", "album": v[2].stringValue ?? "",
        "durationMs": Int(v[3].doubleValue), "positionMs": Int(v[4].doubleValue * 1000),
        "positionAtMs": now, "playing": v[5].booleanValue,
        // Spotify's AppleScript dictionary has no "save to library" command.
        "sourceApp": "com.spotify.client", "sourceName": "Spotify", "canPlayPause": true, "canFavorite": false,
      ]
      if let a = artData { m["artwork"] = FlutterStandardTypedData(bytes: a) }
      return m
    }
    lastSource = ""
    return nil
  }

  // MARK: commands

  private func playPause() -> String {
    switch lastSource {
    case "music": return run("tell application \"Music\" to playpause") != nil ? "ok" : "failed"
    case "spotify": return run("tell application \"Spotify\" to playpause") != nil ? "ok" : "failed"
    case "mr":
      guard let send = sendCmd else { return "unsupported" }
      return send(2 /* kMRTogglePlayPause */, nil) ? "ok" : "failed"
    default: return "unsupported"
    }
  }

  private func favorite() -> String {
    // Only Apple Music exposes a scriptable favorite; everything else is unsupported.
    guard isRunning("com.apple.Music"), lastSource == "music" || lastSource == "mr" else { return "unsupported" }
    if run("tell application \"Music\" to set favorited of current track to true") != nil { return "ok" }
    if run("tell application \"Music\" to set loved of current track to true") != nil { return "ok" }
    return "failed"
  }
}
