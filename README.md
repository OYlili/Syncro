<div align="center">
<img src="https://github.com/OYlili/Syncro/blob/main/syncro_C_512x512.svg" width="120" alt="Syncro Logo"/>

# 🎬 Syncro

**局域网同步影院 · 让每一帧都同步，让每一刻都共享**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-brightgreen)](https://github.com)
[![media_kit](https://img.shields.io/badge/Player-media__kit%20%2F%20mpv-purple)](https://github.com/media-kit/media-kit)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)
[![AI Powered](https://img.shields.io/badge/Powered%20by-AI%20%F0%9F%A4%96-orange)](https://github.com)

[功能特性](#-功能特性) · [技术栈](#-技术栈) · [核心原理](#-核心原理解析) · [安装编译](#-安装与编译) · [赞助](#-赞助支持) · [致谢](#-致谢)

</div>

---

> [!IMPORTANT]
> **🤖 AI 驱动声明**
>
> 本项目的**全部核心代码、架构设计与 Bug 修复**——从 Flutter UI 层、Provider 状态管理、底层 C++ 插件链接，到 HTTP 流媒体分发服务器、FFmpeg 字幕提取管线——均由 AI 大模型全权编写驱动，包括：
>
> **Doubao-2.0-Code · GLM-5 · Kimi · Gemini · Claude**
>
> 人类开发者在本项目中承担的角色为：**架构调度 · 提示词工程 · 产品创意**。
>
> 这是一次对"AI 能否独立完成工业级复杂项目"的真实探索与验证。

---

## 📖 项目简介

**Syncro** 是一款运行于 **Windows 桌面端与 Android** 的局域网同步视频播放器。

你是否曾经想和异地的朋友一起看电影，却苦于商业平台的版权限制、画质压缩、广告打扰？Syncro 的答案是：**自己架服务器，自己做影院。**

房主在本地建立一个"放映间"，通过局域网（或借助 [ZeroTier](https://www.zerotier.com/) / [Tailscale](https://tailscale.com/) 等虚拟组网工具实现跨网段直连），将本地视频文件以 HTTP 流的形式分发给所有成员。所有人的播放状态由 Socket 实时同步，毫秒级跟随，如同坐在同一间影厅。

```
房主 (Host)                          成员 (Members)
┌─────────────────────┐              ┌──────────────┐
│  本地视频文件         │  HTTP 206   │  视频流拉取   │
│  ┌──────────────┐   │ ──────────► │  实时播放     │
│  │ Dart HTTP    │   │             └──────────────┘
│  │ 206 Server   │   │  WebSocket  ┌──────────────┐
│  └──────────────┘   │ ──────────► │  播放状态同步 │
│  Socket 广播中心     │             │  弹幕接收     │
└─────────────────────┘             └──────────────┘
```

---

## ✨ 功能特性

### 🔄 完美的播放同步
基于 **WebSocket** 的低延迟状态同步机制。房主的每一次播放、暂停、进度跳转，均实时广播至所有成员端，实现毫秒级跟随。新成员加入时，服务端自动推送「全量状态快照」（含播放列表、当前进度、字幕轨道状态），无缝融入正在进行的观影。

### 📡 全能流媒体服务端
房主端内置由 **纯 Dart 编写的 HTTP Server**，实现完整的 **HTTP 206 Partial Content** 协议，支持：
- 任意大小视频文件的分片拉取（`Range` 请求响应）
- 成员端播放器的随机 seek 跳转
- 多成员并发拉流，无卡顿

### 🎯 降维打击的 MKV 字幕提取
针对"网络流模式下 mpv 无法扫描 MKV 文件尾部字幕索引"这一本质痛点，Syncro 采用独创的「字幕外挂化」方案，彻底绕开玄学扫描。（详见[核心原理](#-核心原理解析)）

### 📋 多房间文件广播（播放列表）
- 房主支持**一次性多选视频文件**，创建房间时即初始化完整播放列表
- 列表信息（文件名、大小、时长）自动广播至所有成员
- 成员端可实时查看完整播放列表，房主切换视频后全员跟随

### 💬 自定义彩色弹幕系统
内置高保真弹幕层，支持：
- 全成员实时弹幕同步
- 自定义弹幕颜色（统一采用 `AARRGGBB` 十六进制协议序列化，跨端无色差）
- 智能位置分配，弹幕不重叠
- 观影与吐槽两不误 🍿

### 🎵 轨道热切换
- 动态读取视频文件中的**多音轨**与**多字幕轨**列表
- 支持运行时热切换，切换状态广播至全体成员
- 支持「关闭字幕」并可一键还原至上次选中的轨道

### 🌐 跨网段支持
局域网直连之外，推荐使用以下虚拟组网工具实现跨网段远程同步观影：
- [ZeroTier](https://www.zerotier.com/) — 免费，P2P 组网，延迟低
- [Tailscale](https://tailscale.com/) — 基于 WireGuard，配置极简

---

## 🛠 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 框架 | **Flutter 3.x** | Windows + Android 双端 |
| 播放器内核 | **media_kit / mpv** | 工业级多媒体引擎，支持几乎所有格式 |
| 多媒体处理 | **ffmpeg_kit_flutter_video** | 字幕提取、轨道分析（移动端） |
| 状态管理 | **Provider** | 严格处理了 `showModalBottomSheet` 跨路由状态注入，杜绝灰屏 |
| 网络通信 | **Dart HttpServer + WebSocket** | 纯 Dart 实现，零外部依赖 |
| 流媒体协议 | **HTTP 206 Partial Content** | 支持大文件分片、随机 seek |
| 字幕格式 | **WebVTT** | FFmpeg 转码后通过独立 HTTP API 分发 |

---

## 🔬 核心原理解析

### FFmpeg 字幕提取：为什么要「绕道」？

MKV 容器格式出于设计考虑，往往将完整的轨道索引（SeekHead）写在**文件末尾**。当 mpv 通过 HTTP 流媒体协议读取远端 MKV 时，它无法在未完整扫描文件的前提下建立字幕轨索引——这导致内嵌字幕在网络播放模式下**几乎必然丢失**，是一个与播放器实现无关的底层结构性矛盾。

**Syncro 的解法：字幕外挂化**

```
┌─────────────────────────────────────────────────────┐
│ 房主端收到字幕提取请求                                │
│         │                                           │
│         ▼                                           │
│  后台静默启动 FFmpeg 进程                            │
│  ffmpeg -i input.mkv -map 0:s:0 output.vtt         │
│         │                                           │
│         ▼                                           │
│  提取完成 → WebVTT 文件写入本地临时目录              │
│         │                                           │
│         ▼                                           │
│  Dart HTTP Server 新增路由 /sub.vtt                 │
│  Content-Type: text/vtt                             │
│         │                                           │
│         ▼                                           │
│  mpv 加载外挂字幕：                                  │
│  player.setProperty('sub-file',                     │
│    'http://127.0.0.1:PORT/sub.vtt')                │
│         │                                           │
│         ▼                                           │
│  字幕 URL 广播 → 成员端同样外挂加载 ✅               │
└─────────────────────────────────────────────────────┘
```

通过将"内嵌字幕"转换为"HTTP 可访问的外部 WebVTT 文件"，完全绕开了 MKV 索引扫描问题，同时使成员端也能通过相同 URL 加载字幕，一举两得。

### Provider 跨路由注入

Flutter 的 `showModalBottomSheet` 内部通过 `Navigator.push` 创建全新路由上下文，脱离原页面 Widget 树的祖先链，导致子路由中 `context.read<T>()` 返回 Null（即著名的"灰屏"问题）。

Syncro 的解法：**关键 Provider 上移至 `MaterialApp` 根节点**，同时在每次弹出 BottomSheet 时使用 `Provider<T>.value()` 显式透传当前实例，从根本上消除跨路由状态丢失。

---

## 🚀 安装与编译

### 环境要求

- Flutter SDK `>= 3.0.0`
- **Windows：Visual Studio 2022**（必须勾选「使用 C++ 的桌面开发」工作负载）
- Android：Android Studio + NDK

### ⚠️ 重要构建警告

> [!WARNING]
> 本项目使用了大量底层 C++ 原生插件（`media_kit`、`ffmpeg_kit_flutter`）。
> **直接 `flutter run` 极大概率触发 `MissingPluginException`。**
> 请严格按照以下顺序执行完整构建流程，不可跳过任何步骤。

### Windows 完整构建流程

```bash
# Step 1：彻底清理构建缓存与 pub 缓存
flutter clean
flutter pub cache clean

# Step 2：（如遇原生工程异常）重新生成 Windows 工程目录
# ⚠️ 此操作会删除 windows/ 文件夹，自定义改动请提前备份
Remove-Item -Recurse -Force windows
flutter create .

# Step 3：获取所有依赖
flutter pub get

# Step 4：Release 完整构建（Debug 模式下部分原生插件行为不稳定）
flutter build windows --release

# Step 5：运行
flutter run -d windows
```

### Android 构建流程

```bash
flutter clean
flutter pub get
flutter build apk --release
# 或直接安装到设备
flutter run
```

### 常见问题

| 错误信息 | 原因 | 解决方案 |
|----------|------|----------|
| `MissingPluginException(No implementation found for method ffmpegSession)` | Windows 端原生插件未正确链接 | 执行完整的 `flutter clean` → `flutter pub get` → `flutter build windows --release` 流程 |
| `MissingPluginException(getLogLevel)` | 同上 | 同上 |
| 字幕不显示 | FFmpeg 未找到 / 提取失败 | 检查 `GET /tracks` 接口返回，确认 FFmpeg 可用 |
| 成员端播放列表为空 | Socket 状态快照未收到 | 确认房主端与成员端在同一局域网 / ZeroTier 网络内 |

---

## 💰 赞助支持

如果 Syncro 让你的观影体验更好，欢迎请作者喝杯咖啡 ☕

> 维护一个由 AI 驱动的开源项目，最大的成本其实是**提示词工程的时间**和**大模型的 Token 费用**。

<div align="center">

| 微信赞赏 |
|:---:|
| *https://github.com/OYlili/Syncro/blob/main/mm_reward_qrcode_1771563989352.png* |

**每一份支持都会转化为更好的提示词和更多的功能迭代 🚀**

</div>

---

## 📄 License

本项目基于 [MIT License](LICENSE) 开源。

```
MIT License

Copyright (c) 2025 Syncro Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

---

## 🙏 致谢

### 🤖 AI 伙伴（真正的核心开发者）

没有以下 AI 大模型，这个项目的每一行代码都不会存在：

| 模型 | 贡献领域 |
|------|----------|
| **Doubao-2.0-Code** | 核心架构设计、Socket 同步协议、HTTP 流媒体服务器 |
| **GLM-5** | Flutter UI 层、Provider 状态管理修复 |
| **Kimi** | 调试与 Bug 分析、文档生成 |
| **Gemini** | 跨平台兼容性、Android 端适配 |
| **Claude** | 架构审查、FFmpeg 字幕方案设计、README 编写 |

> *"提示词是新时代的代码，调度 AI 是新时代的编程。"*

### 📦 开源项目

- [media_kit](https://github.com/media-kit/media-kit) — 强大的 Flutter 跨平台播放器
- [mpv](https://mpv.io/) — 工业级多媒体播放引擎
- [ffmpeg_kit_flutter](https://github.com/arthenica/ffmpeg-kit) — Flutter FFmpeg 绑定
- [Flutter](https://flutter.dev) — Google 跨平台 UI 框架
- [ZeroTier](https://www.zerotier.com/) — 虚拟局域网组网工具

---

<div align="center">

**Made with 🤖 AI · 🎬 热爱 · ☕ 咖啡**

*Syncro — 让每一帧都同步，让每一刻都共享*

</div>
