import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../providers/player_provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/custom_video_controls.dart';

class FullScreenVideoPage extends StatefulWidget {
  final PlayerProvider playerProvider;
  final SyncProvider syncProvider;

  const FullScreenVideoPage({
    super.key,
    required this.playerProvider,
    required this.syncProvider,
  });

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  @override
  void initState() {
    super.initState();
    _enterFullscreen();
  }

  void _enterFullscreen() {
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 隐藏系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // 显示系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.playerProvider;
    final sync = widget.syncProvider;
    final canControl = !sync.isConnected || sync.isHost;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 视频层
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: _buildVideoPlayer(player),
            ),
          ),
          // 手势层 - 点击显示/隐藏控制栏
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (player.controlsVisible) {
                player.hideControls();
              } else {
                player.showControls();
              }
            },
            child: Container(color: Colors.transparent),
          ),
          // 控制层
          AnimatedOpacity(
            opacity: player.controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !player.controlsVisible,
              child: Stack(
                children: [
                  // 顶部栏
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(context, player),
                  ),
                  // 中心控制按钮
                  Center(
                    child: _buildCenterControls(player, sync, canControl),
                  ),
                  // 底部控制栏
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoControlsOverlay(
                      position: player.position,
                      duration: player.duration,
                      isPlaying: player.isPlaying,
                      controlsVisible: player.controlsVisible,
                      canControl: canControl,
                      onPlayPause: () {
                        if (canControl) {
                          player.togglePlayPause();
                          if (player.isPlaying) {
                            sync.broadcastPlay(positionMs: player.position.inMilliseconds);
                          } else {
                            sync.broadcastPause(positionMs: player.position.inMilliseconds);
                          }
                        }
                      },
                      onSeekBackward: () {
                        final newPosition = player.position - const Duration(seconds: 10);
                        final seekPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
                        player.seek(seekPosition);
                        sync.broadcastSeek(seekPosition.inMilliseconds);
                      },
                      onSeekForward: () {
                        final newPosition = player.position + const Duration(seconds: 10);
                        final seekPosition = newPosition > player.duration ? player.duration : newPosition;
                        player.seek(seekPosition);
                        sync.broadcastSeek(seekPosition.inMilliseconds);
                      },
                      onSeek: (position) {
                        player.seek(position);
                        sync.broadcastSeek(position.inMilliseconds);
                      },
                      onToggleFullscreen: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerProvider player) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                player.videoPath?.split(RegExp(r'[\\/]')).last ?? '视频播放',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls(PlayerProvider player, SyncProvider sync, bool canControl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (canControl)
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 36),
            onPressed: () {
              final newPosition = player.position - const Duration(seconds: 10);
              final seekPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
              player.seek(seekPosition);
              sync.broadcastSeek(seekPosition.inMilliseconds);
            },
          ),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: canControl ? () {
            player.togglePlayPause();
            if (player.isPlaying) {
              sync.broadcastPlay(positionMs: player.position.inMilliseconds);
            } else {
              sync.broadcastPause(positionMs: player.position.inMilliseconds);
            }
          } : null,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: canControl ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 48,
            ),
          ),
        ),
        const SizedBox(width: 32),
        if (canControl)
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 36),
            onPressed: () {
              final newPosition = player.position + const Duration(seconds: 10);
              final seekPosition = newPosition > player.duration ? player.duration : newPosition;
              player.seek(seekPosition);
              sync.broadcastSeek(seekPosition.inMilliseconds);
            },
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(PlayerProvider player) {
    final videoController = player.videoController;
    
    if (videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Video(
      controller: videoController,
      fit: BoxFit.contain,
      controls: NoVideoControls,
    );
  }
}
