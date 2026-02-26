<div align="center">

<img src="https://github.com/OYlili/Syncro/blob/main/syncro_C_512x512.svg" width="120" alt="Syncro Logo"/>

# 🎬 Syncro

**Your Local Cinema · Every Frame in Sync, Every Moment Shared**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-brightgreen)](https://github.com)
[![media_kit](https://img.shields.io/badge/Player-media__kit%20%2F%20mpv-purple)](https://github.com/media-kit/media-kit)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![AI Powered](https://img.shields.io/badge/Powered%20by-AI%20%F0%9F%A4%96-orange)](https://github.com)

[Features](#-features) · [Tech Stack](#-tech-stack) · [How It Works](#-how-it-works) · [Build Guide](#-build-guide) · [Sponsor](#-sponsor) · [Credits](#-credits)

**🌐 Language: English | [中文](https://github.com/OYlili/Syncro/blob/main/README_zh.md)**

</div>

---

> [!IMPORTANT]
> **🤖 AI-Driven Declaration**
>
> Every line of core code, architecture design, and bug fix in this project — from Flutter UI, Provider state management, and native C++ plugin linking, to the HTTP streaming server and FFmpeg subtitle pipeline — was written entirely by AI models, including:
>
> **Doubao-2.0-Code · GLM-5 · Kimi · Gemini · Claude**
>
> The human developer's role: **Architecture coordination · Prompt engineering · Product vision.**
>
> This is a genuine experiment in whether AI can independently complete an industrial-grade, multi-layer project.

---

## 📖 Overview

**Syncro** is an open-source LAN video sync player for **Windows and Android**.

Have you ever wanted to watch a movie with a friend but found yourself stuck with subscription paywalls, compressed quality, and endless ads? Syncro's answer: **host your own server, run your own cinema.**

The host creates a "screening room" on their local network. Members join via a room code and stream video directly from the host device. Every playback action — play, pause, seek — is broadcast in real time via WebSocket. Everyone stays perfectly in sync, as if sitting in the same theater.

**No cloud. No subscriptions. No telemetry. Everything stays on your local network.**

```
Host                                  Members
┌─────────────────────┐              ┌──────────────┐
│  Local Video Files   │  HTTP 206   │  Stream Video │
│  ┌──────────────┐   │ ──────────► │  & Play       │
│  │ Dart HTTP    │   │             └──────────────┘
│  │ 206 Server   │   │  WebSocket  ┌──────────────┐
│  └──────────────┘   │ ──────────► │  Sync State   │
│  WebSocket Hub       │             │  Danmaku      │
└─────────────────────┘             └──────────────┘
```

---

## ✨ Features

### 🔄 Perfect Playback Sync
Low-latency synchronization via **WebSocket**. Every play, pause, and seek from the host is broadcast to all members instantly. When a new member joins, the server pushes a full state snapshot — playlist, current position, subtitle state — so they seamlessly join an ongoing session.

### 📡 Built-in Streaming Server
The host runs a **pure Dart HTTP Server** with full **HTTP 206 Partial Content** support:
- Range request handling for files of any size
- Random seek support for all members
- Concurrent multi-member streaming without buffering

### 🎯 MKV Subtitle Extraction
MKV subtitles over HTTP are notoriously broken. Syncro silently spawns FFmpeg in the background, converts embedded subtitles to WebVTT, serves them via a dedicated HTTP endpoint, and loads them as external subs on all clients. See [How It Works](#-how-it-works).

### 📋 Playlist Broadcast
- Host selects multiple files at once when creating a room
- Full playlist (name, size, duration) pushed to all members via WebSocket
- Host file switching is followed by everyone in real time

### 💬 Colored Danmaku System
Real-time bullet comment layer with cross-device sync, custom colors serialized as `AARRGGBB` hex (no color drift across platforms), and smart position allocation to prevent overlapping 🍿

### 🎵 Hot Track Switching
Dynamically reads audio and subtitle tracks, supports runtime switching synced to all members, with one-tap disable and restore.

### 🌐 Remote Support
Works over LAN or any virtual network:
- [ZeroTier](https://www.zerotier.com/) — Free, P2P, low latency
- [Tailscale](https://tailscale.com/) — WireGuard-based, dead simple setup

---

## 🛠 Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | **Flutter 3.x** | Windows + Android |
| Player | **media_kit / mpv** | Industrial-grade, near-universal format support |
| Media Processing | **ffmpeg_kit_flutter** | Subtitle extraction, track analysis |
| State Management | **Provider** | Cross-route injection via `showModalBottomSheet` handled correctly |
| Networking | **Dart HttpServer + WebSocket** | Pure Dart, zero external dependencies |
| Streaming | **HTTP 206 Partial Content** | Large file chunking, random seek |
| Subtitles | **WebVTT** | FFmpeg-transcoded, served via dedicated HTTP endpoint |

---

## 🔬 How It Works

### MKV Subtitle Extraction: Why the Detour?

MKV containers often write the full track index (SeekHead) at the **end of the file**. When mpv reads an MKV over HTTP, it cannot build a subtitle track index without scanning the entire file first — causing embedded subtitles to reliably disappear in streaming mode. This is a structural problem, independent of the player.

**Syncro's solution: subtitle externalization**

```
┌─────────────────────────────────────────────────────┐
│ Host receives subtitle extraction request            │
│         │                                           │
│         ▼                                           │
│  Silently spawn FFmpeg process                       │
│  ffmpeg -i input.mkv -map 0:s:0 output.vtt         │
│         │                                           │
│         ▼                                           │
│  WebVTT written to local temp directory             │
│         │                                           │
│         ▼                                           │
│  Dart HTTP Server adds route /sub.vtt               │
│  Content-Type: text/vtt                             │
│         │                                           │
│         ▼                                           │
│  mpv loads external subtitle:                       │
│  player.setProperty('sub-file',                     │
│    'http://127.0.0.1:PORT/sub.vtt')                │
│         │                                           │
│         ▼                                           │
│  URL broadcast → all members load same sub ✅       │
└─────────────────────────────────────────────────────┘
```

### Provider Cross-Route Injection

Flutter's `showModalBottomSheet` creates a new route via `Navigator.push`, breaking out of the ancestor widget tree. `context.read<T>()` returns null inside the sheet — the notorious "gray screen" problem.

Syncro's fix: hoist critical Providers to the `MaterialApp` root and use `Provider<T>.value()` to explicitly pass instances into modal contexts.

---

## 🚀 Build Guide

### Requirements

- Flutter SDK `>= 3.0.0`
- **Windows:** Visual Studio 2022 with "Desktop development with C++" workload
- **Android:** Android Studio + NDK

### ⚠️ Important Build Warning

> [!WARNING]
> This project uses native C++ plugins (`media_kit`, `ffmpeg_kit_flutter`).
> **Running `flutter run` directly will almost certainly trigger `MissingPluginException`.**
> Follow the steps below in order without skipping.

### Windows

```bash
# Step 1: Clean all caches
flutter clean
flutter pub cache clean

# Step 2: Regenerate Windows project (if native project is broken)
# ⚠️ This deletes the windows/ folder — back up custom changes first
Remove-Item -Recurse -Force windows
flutter create .

# Step 3: Fetch dependencies
flutter pub get

# Step 4: Full release build
flutter build windows --release

# Step 5: Run
flutter run -d windows
```

### Android

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `MissingPluginException(ffmpegSession)` | Native plugin not linked on Windows | Run the full clean → pub get → build release sequence |
| `MissingPluginException(getLogLevel)` | Same as above | Same as above |
| Subtitles not showing | FFmpeg not found / extraction failed | Check `GET /tracks` response, confirm FFmpeg is available |
| Member playlist empty | WebSocket state snapshot not received | Confirm host and member are on the same LAN or ZeroTier network |

---

## 💰 Sponsor

If Syncro improved your movie night, consider buying the author a coffee ☕

> The real cost of maintaining an AI-driven open source project is **prompt engineering time** and **model API tokens**.

<div align="center">

| WeChat |
|:---:|
| <img src="https://github.com/OYlili/Syncro/blob/main/mm_reward_qrcode_1771563989352.png" alt="WeChat Sponsor" width="180"/> |

**Every contribution turns into better prompts and more features 🚀**

</div>

---

## 📄 License

This project is open source under the [MIT License](LICENSE).

---

## 🙏 Credits

### 🤖 AI Partners (the actual engineers)

| Model | Contribution |
|-------|-------------|
| **Doubao-2.0-Code** | Core architecture, WebSocket sync protocol, HTTP streaming server |
| **GLM-5** | Flutter UI layer, Provider state management fixes |
| **Kimi** | Debugging, bug analysis, documentation |
| **Gemini** | Cross-platform compatibility, Android adaptation |
| **Claude** | Architecture review, FFmpeg subtitle design, README |

> *"Prompt engineering is the new coding. Orchestrating AI is the new programming."*

### 📦 Open Source Dependencies

- [media_kit](https://github.com/media-kit/media-kit) — Flutter cross-platform player
- [mpv](https://mpv.io/) — Industrial-grade multimedia engine
- [ffmpeg_kit_flutter](https://github.com/arthenica/ffmpeg-kit) — Flutter FFmpeg bindings
- [Flutter](https://flutter.dev) — Google's cross-platform UI framework
- [ZeroTier](https://www.zerotier.com/) — Virtual LAN networking

---

<div align="center">

**Made with 🤖 AI · 🎬 Passion · ☕ Coffee**

*Syncro — Every frame in sync, every moment shared*

</div>
