#include "now_playing_win.h"

#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Media.Control.h>
#include <winrt/Windows.Storage.Streams.h>

#include <chrono>

using namespace winrt;
using namespace winrt::Windows::Media::Control;
using namespace winrt::Windows::Storage::Streams;

namespace {
std::string Utf8(const winrt::hstring& s) { return winrt::to_string(s); }

int64_t ToEpochMs(winrt::Windows::Foundation::DateTime dt) {
  auto sys = winrt::clock::to_sys(dt);
  return std::chrono::duration_cast<std::chrono::milliseconds>(sys.time_since_epoch()).count();
}

int64_t NowMs() {
  return std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
      .count();
}

GlobalSystemMediaTransportControlsSession PickSession(
    const GlobalSystemMediaTransportControlsSessionManager& mgr) {
  for (auto const& s : mgr.GetSessions()) {
    auto info = s.GetPlaybackInfo();
    if (info && info.PlaybackStatus() == GlobalSystemMediaTransportControlsSessionPlaybackStatus::Playing) {
      return s;
    }
  }
  return mgr.GetCurrentSession();
}
}  // namespace

NowPlayingWin::NowPlayingWin(flutter::BinaryMessenger* messenger) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "canto/now_playing", &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    const auto& m = call.method_name();
    if (m == "get") {
      std::lock_guard<std::mutex> lock(mu_);
      if (!snap_) {
        result->Success();
        return;
      }
      const auto& s = *snap_;
      flutter::EncodableMap map{
          {flutter::EncodableValue("title"), flutter::EncodableValue(s.title)},
          {flutter::EncodableValue("artist"), flutter::EncodableValue(s.artist)},
          {flutter::EncodableValue("album"), flutter::EncodableValue(s.album)},
          {flutter::EncodableValue("durationMs"), flutter::EncodableValue(s.duration_ms)},
          {flutter::EncodableValue("positionMs"), flutter::EncodableValue(s.position_ms)},
          {flutter::EncodableValue("positionAtMs"), flutter::EncodableValue(s.position_at_ms)},
          {flutter::EncodableValue("playing"), flutter::EncodableValue(s.playing)},
          {flutter::EncodableValue("rate"), flutter::EncodableValue(s.rate)},
          {flutter::EncodableValue("sourceApp"), flutter::EncodableValue(s.source_app)},
          {flutter::EncodableValue("sourceName"), flutter::EncodableValue(s.source_app)},
          {flutter::EncodableValue("canPlayPause"), flutter::EncodableValue(s.can_play_pause)},
          // GSMTC exposes no favorite/rating command.
          {flutter::EncodableValue("canFavorite"), flutter::EncodableValue(false)},
          {flutter::EncodableValue("canSeek"), flutter::EncodableValue(s.can_seek)},
      };
      if (!s.artwork.empty()) map[flutter::EncodableValue("artwork")] = flutter::EncodableValue(s.artwork);
      result->Success(flutter::EncodableValue(map));
    } else if (m == "playPause") {
      std::string r = "failed";
      std::thread t([&] { r = TogglePlayPause(); });
      t.join();
      result->Success(flutter::EncodableValue(r));
    } else if (m == "seek") {
      int64_t ms = 0;
      if (const auto* args = std::get_if<flutter::EncodableMap>(call.arguments())) {
        auto it = args->find(flutter::EncodableValue("positionMs"));
        if (it != args->end()) ms = it->second.LongValue();
      }
      std::string r = "failed";
      std::thread t([&] { r = Seek(ms); });
      t.join();
      result->Success(flutter::EncodableValue(r));
    } else if (m == "goToQueueItem") {
      result->Success(flutter::EncodableValue(std::string("unsupported")));
    } else if (m == "favorite") {
      result->Success(flutter::EncodableValue(std::string("unsupported")));
    } else if (m == "hasPermission") {
      result->Success(flutter::EncodableValue(true));
    } else if (m == "requestPermission") {
      result->Success();
    } else {
      result->NotImplemented();
    }
  });
  worker_ = std::thread([this] { PollLoop(); });
}

NowPlayingWin::~NowPlayingWin() {
  running_ = false;
  if (worker_.joinable()) worker_.join();
}

void NowPlayingWin::PollLoop() {
  winrt::init_apartment(winrt::apartment_type::multi_threaded);
  GlobalSystemMediaTransportControlsSessionManager mgr{nullptr};
  std::string art_key;
  std::vector<uint8_t> art;
  while (running_) {
    try {
      if (!mgr) mgr = GlobalSystemMediaTransportControlsSessionManager::RequestAsync().get();
      auto session = PickSession(mgr);
      std::optional<Snapshot> next;
      if (session) {
        auto props = session.TryGetMediaPropertiesAsync().get();
        auto info = session.GetPlaybackInfo();
        auto tl = session.GetTimelineProperties();
        Snapshot s;
        s.title = Utf8(props.Title());
        s.artist = Utf8(props.Artist());
        if (s.artist.empty()) s.artist = Utf8(props.AlbumArtist());
        s.album = Utf8(props.AlbumTitle());
        s.source_app = Utf8(session.SourceAppUserModelId());
        auto dur = tl.EndTime() - tl.StartTime();
        s.duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(dur).count();
        s.position_ms = std::chrono::duration_cast<std::chrono::milliseconds>(tl.Position()).count();
        s.position_at_ms = ToEpochMs(tl.LastUpdatedTime());
        if (s.position_at_ms <= 0) s.position_at_ms = NowMs();
        s.playing = info.PlaybackStatus() == GlobalSystemMediaTransportControlsSessionPlaybackStatus::Playing;
        auto rate = info.PlaybackRate();
        if (rate) s.rate = rate.Value();
        s.can_play_pause = info.Controls().IsPlayPauseToggleEnabled() ||
                           info.Controls().IsPlayEnabled() || info.Controls().IsPauseEnabled();
        s.can_seek = info.Controls().IsPlaybackPositionEnabled();
        auto key = s.source_app + "|" + s.title + "|" + s.artist + "|" + s.album;
        if (key != art_key) {
          art_key = key;
          art.clear();
          if (auto thumb = props.Thumbnail()) {
            try {
              auto stream = thumb.OpenReadAsync().get();
              auto size = static_cast<uint32_t>(stream.Size());
              if (size > 0 && size < 8 * 1024 * 1024) {
                DataReader reader(stream);
                reader.LoadAsync(size).get();
                art.resize(size);
                reader.ReadBytes(winrt::array_view<uint8_t>(art));
              }
            } catch (...) {
              art.clear();
            }
          }
        }
        s.artwork = art;
        if (!s.title.empty()) next = std::move(s);
      }
      std::lock_guard<std::mutex> lock(mu_);
      snap_ = std::move(next);
    } catch (...) {
      std::lock_guard<std::mutex> lock(mu_);
      snap_.reset();
      mgr = nullptr;
    }
    for (int i = 0; i < 5 && running_; i++) std::this_thread::sleep_for(std::chrono::milliseconds(100));
  }
  winrt::uninit_apartment();
}

std::string NowPlayingWin::TogglePlayPause() {
  try {
    winrt::init_apartment(winrt::apartment_type::multi_threaded);
    auto mgr = GlobalSystemMediaTransportControlsSessionManager::RequestAsync().get();
    auto session = PickSession(mgr);
    if (!session) return "unsupported";
    if (!session.GetPlaybackInfo().Controls().IsPlayPauseToggleEnabled()) return "unsupported";
    return session.TryTogglePlayPauseAsync().get() ? "ok" : "failed";
  } catch (...) {
    return "failed";
  }
}

std::string NowPlayingWin::Seek(int64_t ms) {
  try {
    winrt::init_apartment(winrt::apartment_type::multi_threaded);
    auto mgr = GlobalSystemMediaTransportControlsSessionManager::RequestAsync().get();
    auto session = PickSession(mgr);
    if (!session) return "unsupported";
    if (!session.GetPlaybackInfo().Controls().IsPlaybackPositionEnabled()) return "unsupported";
    // Position is in 100-ns ticks relative to the timeline start.
    auto start = session.GetTimelineProperties().StartTime().count();
    return session.TryChangePlaybackPositionAsync(start + ms * 10000).get() ? "ok" : "failed";
  } catch (...) {
    return "failed";
  }
}
