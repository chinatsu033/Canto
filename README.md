# Canto

[中文](#中文) · [English](#english)

<p>
<img src="docs/screenshots/light_player.png" width="200" alt="Player (light)">
<img src="docs/screenshots/light_lyrics.png" width="200" alt="Lyrics view (light)">
<img src="docs/screenshots/dark_player.png" width="200" alt="Player (dark)">
<img src="docs/screenshots/dark_lyrics.png" width="200" alt="Lyrics view (dark)">
</p>

*截图中的歌词均为虚构的占位文本。Screenshots use made-up placeholder text, not real lyrics.*

---

## 中文

Canto 是一个**个人学习项目，非营利**。它读取系统的“正在播放”信息，并从 [LRCLIB](https://lrclib.net) 获取歌词显示出来。

- **Canto 不提供任何音乐**：不播放、不缓存、不转发音频，不集成任何音乐服务 SDK 或私有接口（Spotify / Apple Music / QQ音乐 / 网易云音乐 等）。
- **歌词版权归原权利人所有。** 歌词仅从 LRCLIB 实时获取，只在内存中临时保存当前曲目的歌词，切歌或退出即丢弃；不会上传、记录日志、写入仓库或打包进应用。
- 请求 LRCLIB 时使用标识性 User-Agent：`Canto/0.1.0 (https://github.com/chinatsu033/Canto)`。优先使用 `/api/get`（曲名、歌手、专辑、时长），找不到时回退到 `/api/search`。有时间轴（LRC）的歌词会随播放进度滚动；只有纯文本歌词时不滚动；都没有时显示“未找到歌词”。

### 功能
- 播放页：封面居中，下方只显示当前一句（和下一句）；点击歌词进入大字歌词视图，可滚动查看其他行，自动跟随当前行，手动滚动 4 秒后恢复跟随。
- 底部控制栏：播放/暂停、收藏。收藏图标随来源 App 变化：Spotify 为 ➕，QQ音乐/网易云/酷狗/酷我等国内 App 为 ♥，Apple Music 为 ☆。**只有当系统会话真的支持收藏时才会执行**，否则提示“不支持”，不会假装成功。
- 播放队列：仅当播放器公开了队列时显示（Android `MediaController.getQueue`、Linux MPRIS TrackList），否则完全不显示列表。
- 强调色取自当前封面的主色，每首歌更新；无封面时使用固定的中性蓝色。浅色模式白底，深色模式灰黑（#1F1F1F / #2A2A2A），跟随系统。所有按钮均为圆角方形。
- 桌面端：约 380×720 的竖屏小窗，默认置顶（可切换），无边框，自带拖动区、最小化与关闭按钮，实色背景。
- 语言：简体中文（默认）、繁體中文、日本語、English。

### 各平台“正在播放”来源与限制
| 平台 | 来源 | 说明 |
|---|---|---|
| Android | `NotificationListenerService` + `MediaSessionManager.getActiveSessions` | 需要在系统设置中授予“通知使用权”（只用于读取媒体会话，不读取通知内容）。支持标题/歌手/专辑/时长/进度/封面/播放控制/队列。收藏仅在播放器提供相应 custom action 或 rating 时可用。 |
| macOS | MediaRemote（私有框架，运行时加载）→ 回退 AppleScript（Music、Spotify） | **macOS 15.4 起 Apple 限制了第三方进程访问 MediaRemote**，通常读不到数据，此时自动回退到 AppleScript，只支持 Apple Music 和 Spotify（首次使用需在“系统设置 › 隐私与安全性 › 自动化”中允许）。其他播放器在 15.4+ 上读不到。可行的后续方案是 [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter)（借助系统自带 `/usr/bin/perl` 加载框架），尚未集成。收藏仅支持 Apple Music（AppleScript `favorited`）。应用未签名/未公证：首次打开请右键 › 打开。 |
| Windows | `GlobalSystemMediaTransportControlsSessionManager`（WinRT） | 支持标题/歌手/专辑/时长/进度/封面/播放暂停。该 API 不提供收藏和队列，所以收藏显示为不支持、不显示队列。 |
| Linux | MPRIS（D-Bus） | 支持 MPRIS 的播放器均可（Spotify、VLC、浏览器等）。若播放器实现了 TrackList 则显示队列。MPRIS 没有标准的收藏命令，收藏显示为不支持。 |
| iOS / iPadOS | — | **不支持。** iOS 不允许第三方 App 读取其他 App 的正在播放信息。 |

### 构建
Flutter 3.47。`flutter test` 运行 LRC 解析、同步逻辑和多语言 key 覆盖检查。打包脚本见 `packaging/`，CI 见 `.github/workflows/build.yaml`。

---

## English

Canto is a **personal learning project, non-profit**. It reads your system's now-playing info and shows lyrics fetched from [LRCLIB](https://lrclib.net).

- **Canto does not provide any music.** It never plays, caches or forwards audio, and uses no music-service SDKs or private APIs (Spotify / Apple Music / QQ Music / NetEase Cloud Music, etc.).
- **Lyrics copyright belongs to the respective rights holders.** Lyrics are fetched live from LRCLIB and kept only in memory for the current track; they are dropped on track change or exit and are never uploaded, logged, committed, or bundled.
- LRCLIB requests carry the User-Agent `Canto/0.1.0 (https://github.com/chinatsu033/Canto)`. Canto calls `/api/get` (track, artist, album, duration) and falls back to `/api/search`. Synced (LRC) lyrics scroll with playback; plain lyrics are shown without scrolling; otherwise a "no lyrics" state.

### Features
- Player page: centered artwork with only the current (and next) line below; tap to open the enlarged lyrics view, which auto-follows the current line and resumes 4 s after manual scrolling.
- Bottom bar: play/pause and favorite. Favorite icon depends on the source app: Spotify = plus, mainland-China apps (QQ Music, NetEase, Kugou, Kuwo…) = heart, Apple Music = star. **Favorite is only sent when the system session supports it**; otherwise a toast says it's unsupported — it never pretends to succeed.
- Queue: shown only when the player exposes one (Android `getQueue`, MPRIS TrackList); otherwise no list at all.
- Accent color is extracted from the album artwork per track, with a fixed neutral fallback. Light mode is white; dark mode is grey (#1F1F1F / #2A2A2A); follows the system. All controls are rounded squares.
- Desktop: ~380×720 portrait window, always-on-top by default (toggle), frameless with drag area, minimize and close, solid background.
- Languages: Simplified Chinese (default), Traditional Chinese, Japanese, English.

### Now-playing sources & limitations
| Platform | Source | Notes |
|---|---|---|
| Android | `NotificationListenerService` + `MediaSessionManager.getActiveSessions` | Requires granting Notification access (used only to reach media sessions; notification content is never read). Title/artist/album/duration/position/artwork/controls/queue. Favorite only if the player exposes a matching custom action or rating. |
| macOS | MediaRemote (private framework, loaded at runtime) → AppleScript fallback (Music, Spotify) | **Since macOS 15.4 Apple blocks MediaRemote for non-Apple processes**, so it usually returns nothing and Canto falls back to AppleScript for Apple Music and Spotify only (allow it under System Settings › Privacy & Security › Automation). Other players are not readable on 15.4+. A possible future route is [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter) (loads the framework via the system `/usr/bin/perl`); not integrated yet. Favorite works for Apple Music only (AppleScript `favorited`). Unsigned/unnotarized: right-click › Open the first time. |
| Windows | `GlobalSystemMediaTransportControlsSessionManager` (WinRT) | Title/artist/album/duration/position/artwork/play-pause. The API has no favorite or queue, so favorite shows unsupported and no queue is shown. |
| Linux | MPRIS over D-Bus | Any MPRIS player (Spotify, VLC, browsers…). Queue shown if the player implements TrackList. MPRIS has no standard favorite command → unsupported. |
| iOS / iPadOS | — | **Not supported.** iOS doesn't let third-party apps read other apps' now-playing info. |

### Build
Flutter 3.47. `flutter test` covers LRC parsing, sync logic and i18n key coverage. Packaging scripts are in `packaging/`, CI in `.github/workflows/build.yaml`.

## License
MIT for the code. Lyrics are not part of this repository.
