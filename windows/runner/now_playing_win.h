#pragma once
#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <atomic>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>

// Reads the system now-playing session via
// GlobalSystemMediaTransportControlsSessionManager (WinRT). WinRT calls run on
// a background MTA thread; the platform thread only reads a cached snapshot.
class NowPlayingWin {
 public:
  explicit NowPlayingWin(flutter::BinaryMessenger* messenger);
  ~NowPlayingWin();

 private:
  struct Snapshot {
    std::string title, artist, album, source_app;
    int64_t duration_ms = 0, position_ms = 0, position_at_ms = 0;
    bool playing = false, can_play_pause = false, can_seek = false;
    double rate = 1.0;
    std::vector<uint8_t> artwork;
  };
  void PollLoop();
  std::string TogglePlayPause();
  std::string Seek(int64_t ms);

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  std::thread worker_;
  std::atomic<bool> running_{true};
  std::mutex mu_;
  std::optional<Snapshot> snap_;
};
