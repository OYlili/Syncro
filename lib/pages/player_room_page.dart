import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../themes/app_theme.dart';
import '../providers/player_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/user_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/room_provider.dart';
import '../providers/danmaku_settings_provider.dart';
import '../providers/subtitle_style_provider.dart';
import '../providers/subtitle_provider.dart';
import '../providers/audio_track_provider.dart';
import '../widgets/chat_room_widget.dart';
import '../widgets/danmaku_view.dart';
import '../widgets/danmaku_settings_panel.dart';
import '../widgets/playlist_widget.dart';
import '../widgets/track_settings_bottom_sheet.dart';
import '../widgets/danmaku_style_picker.dart';

enum _GestureType { none, brightness, volume }

class PlayerRoomPage extends StatefulWidget {
  final String? videoPath;
  final List<String> initialVideoPaths;
  final bool isHost;
  final int? port;
  final String? hostIp;
  
  const PlayerRoomPage({
    super.key, 
    this.videoPath,
    this.initialVideoPaths = const [],
    this.isHost = false,
    this.port,
    this.hostIp,
  });

  @override
  State<PlayerRoomPage> createState() => _PlayerRoomPageState();
}

class _PlayerRoomPageState extends State<PlayerRoomPage> with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _showChat = true;
  bool _isFullscreen = false;
  bool _showDanmakuInput = false;
  final TextEditingController _danmakuController = TextEditingController();
  final FocusNode _danmakuFocusNode = FocusNode();
  Timer? _controlsHideTimer;
  bool _isControlsFrozen = false;
  
  _GestureType _gestureType = _GestureType.none;
  double _gestureStartY = 0;
  double _gestureCurrentValue = 0;
  double _currentBrightness = 0.5;
  bool _showGestureIndicator = false;
  Timer? _gestureIndicatorTimer;
  
  DateTime? _watchStartTime;
  Duration _sessionWatchDuration = Duration.zero;
  String? _currentVideoName;
  String? _lastLoadedVideoUrl;
  Duration? _dragValue;
  bool _isFullscreenTransitioning = false;
  final GlobalKey _videoKey = GlobalKey();
  final GlobalKey<DanmakuViewState> _danmakuKey = GlobalKey<DanmakuViewState>();
  int _lastChatMessageCount = 0;
  PlayerProvider? _storedPlayerProvider;
  SyncProvider? _storedSyncProvider;

  PlayerProvider get _playerProvider {
    return _storedPlayerProvider ?? context.read<PlayerProvider>();
  }
  
  SyncProvider get _syncProvider {
    return _storedSyncProvider ?? context.read<SyncProvider>();
  }

  void _sendDanmaku() {
    final text = _danmakuController.text.trim();
    if (text.isEmpty) return;
    
    final danmakuSettings = context.read<DanmakuSettingsProvider>();
    final color = DanmakuStylePicker.getColorValue(danmakuSettings.sendColor);
    final position = danmakuSettings.sendPosition.index;
    
    debugPrint('🎨 发送弹幕: text="$text", color=0x${color.toRadixString(16)}, position=$position');
    
    _syncProvider.sendChat(
      text,
      danmakuColor: color,
      danmakuPosition: position,
    );
    _danmakuController.clear();
    _danmakuFocusNode.unfocus();
    setState(() {
      _showDanmakuInput = false;
    });
  }

  void _toggleDanmakuInput() {
    if (_showDanmakuInput) {
      _danmakuFocusNode.unfocus();
      setState(() {
        _showDanmakuInput = false;
      });
    } else {
      if (!_playerProvider.controlsVisible) {
        _playerProvider.showControls();
      }
      setState(() {
        _showDanmakuInput = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _danmakuFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _storedPlayerProvider = context.read<PlayerProvider>();
        _storedSyncProvider = context.read<SyncProvider>();
        _storedSyncProvider!.addListener(_onSyncUpdate);
        _storedPlayerProvider!.addListener(_onPlayerUpdate);
        _danmakuFocusNode.addListener(_onDanmakuFocusChange);
        _initializeControllers();
        _initializeAll();
      }
    });
  }

  void _onDanmakuFocusChange() {
    if (_danmakuFocusNode.hasFocus) {
      _freezeControls();
    } else {
      _unfreezeControls();
    }
  }

  void _freezeControls() {
    _isControlsFrozen = true;
    _cancelControlsHideTimer();
  }

  void _unfreezeControls() {
    _isControlsFrozen = false;
    if (_playerProvider.isPlaying && _playerProvider.controlsVisible) {
      _startControlsHideTimer();
    }
  }

  void _startControlsHideTimer() {
    if (_isControlsFrozen) return;
    
    _cancelControlsHideTimer();
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (!_isControlsFrozen && _playerProvider.isPlaying && mounted) {
        _playerProvider.hideControls();
      }
    });
  }

  void _cancelControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
  }

  void _showControlsWithTimer() {
    _playerProvider.showControls();
    if (_playerProvider.isPlaying && !_isControlsFrozen) {
      _startControlsHideTimer();
    }
  }

  void _hideControlsWithTimer() {
    if (_isControlsFrozen) return;
    _playerProvider.hideControls();
    _cancelControlsHideTimer();
  }

  void _onSyncUpdate() {
    if (_isDisposed || !mounted) return;
    if (_syncProvider.isClient && _syncProvider.currentVideoUrl != null) {
      final url = _syncProvider.currentVideoUrl;
      if (url != null && url != _lastLoadedVideoUrl) {
        _lastLoadedVideoUrl = url;
        _loadRemoteVideo(url);
      }
    }
    
    final currentMessageCount = _syncProvider.chatMessages.length;
    if (currentMessageCount > _lastChatMessageCount) {
      final newMessages = _syncProvider.chatMessages.sublist(_lastChatMessageCount);
      for (final message in newMessages) {
        if (!message.isSystem) {
          _danmakuKey.currentState?.addDanmaku(
            message.content,
            senderName: message.senderName,
            isHost: message.isHost,
            color: message.danmakuColor,
            position: message.danmakuPosition,
          );
        }
      }
      _lastChatMessageCount = currentMessageCount;
    }
    
    if (mounted) setState(() {});
  }
  
  void _onPlayerUpdate() {
    if (_isDisposed || !mounted) return;
    
    if (_playerProvider.isPlaying && _playerProvider.controlsVisible && !_isControlsFrozen) {
      _startControlsHideTimer();
    } else if (!_playerProvider.isPlaying) {
      _cancelControlsHideTimer();
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _loadRemoteVideo(String url) async {
    try {
      await _playerProvider.loadVideo(url);
      _startWatchTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在加载房主分享的视频...')),
        );
      }
    } catch (e) {
      debugPrint('Error loading remote video: $e');
    }
  }

  void _initializeControllers() {
    try {
      VolumeController().listener((volume) {});
    } catch (e) {
      debugPrint('Volume controller init error: $e');
    }
    _initBrightness();
  }

  Future<void> _initBrightness() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _currentBrightness = await ScreenBrightness().application;
      } catch (e) {
        _currentBrightness = 0.5;
      }
    }
  }

  void _onGesturePanStart(DragStartDetails details, Size screenSize) {
    _gestureStartY = details.globalPosition.dy;
    
    if (details.globalPosition.dx < screenSize.width / 2) {
      _gestureType = _GestureType.brightness;
      _gestureCurrentValue = _currentBrightness;
    } else {
      _gestureType = _GestureType.volume;
      _gestureCurrentValue = _playerProvider.volume;
    }
  }

  void _onGesturePanUpdate(DragUpdateDetails details, Size screenSize) {
    if (_gestureType == _GestureType.none) return;
    
    final deltaY = _gestureStartY - details.globalPosition.dy;
    final deltaPercent = deltaY / screenSize.height;
    
    if (_gestureType == _GestureType.brightness) {
      _gestureCurrentValue = (_currentBrightness + deltaPercent).clamp(0.0, 1.0);
      _setBrightness(_gestureCurrentValue);
    } else if (_gestureType == _GestureType.volume) {
      _gestureCurrentValue = (_playerProvider.volume + deltaPercent).clamp(0.0, 1.0);
      _playerProvider.player?.setVolume(_gestureCurrentValue * 100);
    }
    
    setState(() {
      _showGestureIndicator = true;
    });
    
    _gestureIndicatorTimer?.cancel();
  }

  void _onGesturePanEnd(DragEndDetails details) {
    if (_gestureType == _GestureType.brightness) {
      _currentBrightness = _gestureCurrentValue;
    } else if (_gestureType == _GestureType.volume) {
      _playerProvider.setVolume(_gestureCurrentValue);
    }
    
    _gestureIndicatorTimer?.cancel();
    _gestureIndicatorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showGestureIndicator = false;
          _gestureType = _GestureType.none;
        });
      }
    });
  }

  Future<void> _setBrightness(double value) async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await ScreenBrightness().setApplicationScreenBrightness(value);
      } catch (e) {
        debugPrint('Error setting brightness: $e');
      }
    }
  }

  Widget _buildGestureIndicator() {
    return AnimatedOpacity(
      opacity: (_showGestureIndicator && _gestureType != _GestureType.none) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !(_showGestureIndicator && _gestureType != _GestureType.none),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildGestureIndicatorContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGestureIndicatorContent() {
    if (_gestureType == _GestureType.none) {
      return const SizedBox.shrink();
    }
    
    IconData icon;
    String label;
    
    if (_gestureType == _GestureType.brightness) {
      if (_gestureCurrentValue <= 0) {
        icon = Icons.brightness_low;
      } else if (_gestureCurrentValue < 0.35) {
        icon = Icons.brightness_low;
      } else if (_gestureCurrentValue < 0.7) {
        icon = Icons.brightness_medium;
      } else {
        icon = Icons.brightness_high;
      }
      label = '亮度 ${(_gestureCurrentValue * 100).round()}%';
    } else {
      if (_gestureCurrentValue <= 0) {
        icon = Icons.volume_off;
      } else if (_gestureCurrentValue < 0.5) {
        icon = Icons.volume_down;
      } else {
        icon = Icons.volume_up;
      }
      label = '音量 ${(_gestureCurrentValue * 100).round()}%';
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: _gestureCurrentValue,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _initializeAll() async {
    if (_isDisposed) return;
    
    await _playerProvider.initialize();
    
    if (_isDisposed) return;
    
    final subtitleProvider = context.read<SubtitleProvider>();
    final audioTrackProvider = context.read<AudioTrackProvider>();
    
    _syncProvider.setPlayer(_playerProvider.player!);
    _syncProvider.setProviders(
      playerProvider: _playerProvider,
      subtitleProvider: subtitleProvider,
      audioTrackProvider: audioTrackProvider,
    );
    
    subtitleProvider.setPlayer(_playerProvider.player!);
    audioTrackProvider.setPlayer(_playerProvider.player!);
    
    if (mounted && !_isDisposed) {
      setState(() {
        _isInitialized = true;
      });
      
      await _initializeSync();
      
      if (widget.initialVideoPaths.isNotEmpty && _syncProvider.isHost) {
        await _syncProvider.setPlaylist(widget.initialVideoPaths);
        _startWatchTimer();
      } else if (widget.videoPath != null) {
        await _playerProvider.loadVideo(widget.videoPath!);
        _startWatchTimer();
        
        if (_syncProvider.isHost) {
          final videoName = widget.videoPath!.split(Platform.pathSeparator).last;
          await _syncProvider.startVideoStream(widget.videoPath!, videoName: videoName);
        }
      }
    }
  }

  Future<void> _initializeSync() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    
    // 使用昵称作为用户名，生成唯一ID
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final userName = user.nickname;
    
    if (widget.isHost) {
      await _syncProvider.startHosting(
        port: widget.port ?? 37670,
        userId: userId,
        userName: userName,
        userAvatar: user.avatarPath,
      );
    } else if (widget.hostIp != null && widget.port != null) {
      await _syncProvider.joinRoom(
        host: widget.hostIp!,
        port: widget.port!,
        userId: userId,
        userName: userName,
        userAvatar: user.avatarPath,
      );
    }
  }

  void _startWatchTimer() {
    _watchStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    
    _gestureIndicatorTimer?.cancel();
    _controlsHideTimer?.cancel();
    _danmakuFocusNode.removeListener(_onDanmakuFocusChange);
    _danmakuFocusNode.dispose();
    _danmakuController.dispose();
    
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    
    if (_storedSyncProvider != null) {
      _storedSyncProvider!.removeListener(_onSyncUpdate);
    }
    if (_storedPlayerProvider != null) {
      _storedPlayerProvider!.removeListener(_onPlayerUpdate);
    }
    
    _saveWatchStatistics();
    _cleanupRoom();
    
    try {
      VolumeController().removeListener();
    } catch (e) {
      // Ignore
    }
    
    super.dispose();
  }

  void _cleanupRoom() {
    _syncProvider.leaveRoom();
  }

  void _saveWatchStatistics() {
    if (_watchStartTime != null) {
      _sessionWatchDuration = DateTime.now().difference(_watchStartTime!);
      final statsProvider = context.read<StatisticsProvider>();
      statsProvider.addWatchDuration(_sessionWatchDuration);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveWatchStatistics();
    } else if (state == AppLifecycleState.resumed) {
      _watchStartTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _playerProvider;
    final sync = _syncProvider;
    final canControl = !sync.isConnected || sync.isHost;
    final videoController = player.videoController;
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (player.status == PlayerStatus.error) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildErrorView(context),
      );
    }

    if (!player.hasVideo) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildEmptyView(context),
      );
    }

    if (videoController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _exitFullscreen();
            }
          },
          child: Stack(
            children: [
              Center(
                child: _buildVideoPlayer(context, player, sync, canControl, videoController),
              ),
              _buildDanmakuLayer(true),
              _buildVideoControlsLayer(context, player, sync, canControl, isFullscreen: true),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: PopScope(
        canPop: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 800;
            return _buildResponsiveLayout(
              context, 
              player, 
              sync, 
              canControl, 
              videoController,
              isWideScreen,
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
    VideoController videoController,
    bool isWideScreen,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (isWideScreen) {
      return _buildWideScreenLayout(
        context, 
        player, 
        sync, 
        canControl, 
        videoController, 
        colorScheme,
      );
    } else {
      return _buildNarrowScreenLayout(
        context, 
        player, 
        sync, 
        canControl, 
        videoController, 
        colorScheme,
      );
    }
  }

  Widget _buildDanmakuLayer(bool isFullscreen) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, danmakuSettings, child) {
        if (!danmakuSettings.isEnabled) {
          return const SizedBox.shrink();
        }
        
        return Positioned.fill(
          child: DanmakuView(
            key: _danmakuKey,
            isFullscreen: isFullscreen,
            isEnabled: danmakuSettings.isEnabled,
            speedMultiplier: danmakuSettings.speedMultiplier,
            opacity: danmakuSettings.opacity,
            area: danmakuSettings.area,
            fontSizeMultiplier: danmakuSettings.fontSize,
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
    VideoController videoController,
  ) {
    return Consumer<SubtitleStyleProvider>(
      builder: (context, subtitleStyle, child) {
        return Video(
          key: _videoKey,
          controller: videoController,
          fit: BoxFit.contain,
          controls: NoVideoControls,
          subtitleViewConfiguration: SubtitleViewConfiguration(
            style: TextStyle(
              color: subtitleStyle.textColor.withValues(alpha: subtitleStyle.opacity),
              fontSize: subtitleStyle.fontSize,
              fontWeight: FontWeight.w500,
              backgroundColor: subtitleStyle.showBackground 
                  ? Colors.black.withValues(alpha: 0.6 * subtitleStyle.opacity)
                  : null,
              shadows: subtitleStyle.showBackground 
                  ? null 
                  : const [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  Widget _buildWideScreenLayout(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
    VideoController videoController,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _buildVideoPlayer(context, player, sync, canControl, videoController),
                  ),
                  _buildDanmakuLayer(false),
                  _buildVideoControlsLayer(context, player, sync, canControl, isFullscreen: false),
                ],
              ),
            ),
          ),
          if (_showChat)
            SizedBox(
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildChatPanel(context),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
    VideoController videoController,
    ColorScheme colorScheme,
  ) {
    return SafeArea(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _buildVideoPlayer(context, player, sync, canControl, videoController),
                  ),
                  _buildDanmakuLayer(false),
                  _buildVideoControlsLayer(context, player, sync, canControl, isFullscreen: false),
                ],
              ),
            ),
          ),
          if (_showChat)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: _buildChatPanel(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControlsLayer(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl, {
    required bool isFullscreen,
  }) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_danmakuFocusNode.hasFocus) {
              _danmakuFocusNode.unfocus();
              return;
            }
            
            if (player.controlsVisible) {
              _hideControlsWithTimer();
            } else {
              _showControlsWithTimer();
            }
          },
          onDoubleTap: canControl ? () async {
            if (player.isPlaying) {
              await player.pause();
              sync.broadcastPause(positionMs: player.position.inMilliseconds);
            } else {
              await player.play();
              sync.broadcastPlay(positionMs: player.position.inMilliseconds);
            }
          } : null,
          onPanStart: (details) => _onGesturePanStart(details, screenSize),
          onPanUpdate: (details) => _onGesturePanUpdate(details, screenSize),
          onPanEnd: _onGesturePanEnd,
          child: AnimatedOpacity(
            opacity: player.controlsVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !player.controlsVisible,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isFullscreen
                        ? [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ]
                        : [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    if (isFullscreen) _buildTopBar(context, player),
                    Center(
                      child: _buildCenterPlayButton(player, sync, canControl),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildBottomControlBar(context, player, sync, canControl, isFullscreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildGestureIndicator(),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerProvider player) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _exitFullscreen,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPlayButton(
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
  ) {
    return GestureDetector(
      onTap: canControl ? () async {
        if (player.isPlaying) {
          await player.pause();
          sync.broadcastPause(positionMs: player.position.inMilliseconds);
        } else {
          await player.play();
          sync.broadcastPlay(positionMs: player.position.inMilliseconds);
        }
      } : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          player.isPlaying ? Icons.pause : Icons.play_arrow,
          color: canControl ? Colors.white : Colors.white.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildBottomControlBar(
    BuildContext context,
    PlayerProvider player,
    SyncProvider sync,
    bool canControl,
    bool isFullscreen,
  ) {
    final duration = player.duration;
    final displayPosition = _dragValue ?? player.position;
    final progress = duration.inMilliseconds > 0 
        ? displayPosition.inMilliseconds / duration.inMilliseconds 
        : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFullscreen && _showDanmakuInput)
              _buildDanmakuInputBar(context),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: Theme.of(context).colorScheme.primary,
                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: canControl ? (value) {
                  setState(() {
                    _dragValue = Duration(
                      milliseconds: (value * duration.inMilliseconds).round(),
                    );
                  });
                } : null,
                onChangeEnd: canControl ? (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  player.seek(newPosition);
                  sync.broadcastSeek(newPosition.inMilliseconds);
                  setState(() {
                    _dragValue = null;
                  });
                } : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 24,
                    onPressed: canControl ? () async {
                      if (player.isPlaying) {
                        await player.pause();
                        sync.broadcastPause(positionMs: player.position.inMilliseconds);
                      } else {
                        await player.play();
                        sync.broadcastPlay(positionMs: player.position.inMilliseconds);
                      }
                    } : null,
                  ),
                  Text(
                    _formatDuration(displayPosition),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ ${_formatDuration(duration)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                  const Spacer(),
                  if (canControl) ...[
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      iconSize: 22,
                      onPressed: () {
                        final newPosition = player.position - const Duration(seconds: 10);
                        final seekPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
                        player.seek(seekPosition);
                        sync.broadcastSeek(seekPosition.inMilliseconds);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      iconSize: 22,
                      onPressed: () {
                        final newPosition = player.position + const Duration(seconds: 10);
                        final seekPosition = newPosition > player.duration ? player.duration : newPosition;
                        player.seek(seekPosition);
                        sync.broadcastSeek(seekPosition.inMilliseconds);
                      },
                    ),
                  ],
                  if (isFullscreen) ...[
                    if (player.hasMultipleAudioTracks || player.hasSubtitleTracks)
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        iconSize: 22,
                        onPressed: () => TrackSettingsBottomSheet.show(context),
                      ),
                    Consumer<DanmakuSettingsProvider>(
                      builder: (context, danmakuSettings, child) {
                        return IconButton(
                          icon: Icon(
                            danmakuSettings.isEnabled ? Icons.comment : Icons.comment_outlined,
                            color: danmakuSettings.isEnabled 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.white,
                          ),
                          iconSize: 22,
                          onPressed: () => danmakuSettings.setEnabled(!danmakuSettings.isEnabled),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      iconSize: 22,
                      onPressed: _toggleDanmakuInput,
                    ),
                  ] else ...[
                    if (player.hasMultipleAudioTracks || player.hasSubtitleTracks)
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        iconSize: 22,
                        onPressed: () => TrackSettingsBottomSheet.show(context),
                      ),
                    Consumer<DanmakuSettingsProvider>(
                      builder: (context, danmakuSettings, child) {
                        return IconButton(
                          icon: Icon(
                            danmakuSettings.isEnabled ? Icons.comment : Icons.comment_outlined,
                            color: danmakuSettings.isEnabled 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.white,
                          ),
                          iconSize: 22,
                          onPressed: () => DanmakuSettingsPanel.show(context),
                        );
                      },
                    ),
                  ],
                  IconButton(
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    iconSize: 24,
                    onPressed: isFullscreen ? _exitFullscreen : _enterFullscreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDanmakuInputBar(BuildContext context) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, danmakuSettings, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const DanmakuStylePicker(),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _danmakuController,
                  focusNode: _danmakuFocusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '发送弹幕...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendDanmaku(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendDanmaku,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final player = _playerProvider;
    final sync = _syncProvider;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _showExitDialog(context),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              player.hasVideo 
                  ? (player.videoPath?.split(Platform.pathSeparator).last ?? '视频播放')
                  : '播放室',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sync.isConnected) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 14, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 4),
                  Text(
                    '${sync.userCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (sync.isConnected)
          IconButton(
            icon: Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline),
            onPressed: () => setState(() => _showChat = !_showChat),
            tooltip: _showChat ? '隐藏聊天' : '显示聊天',
          ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: _pickVideo,
          tooltip: '打开视频',
        ),
        if (player.hasVideo)
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _enterFullscreen,
            tooltip: '全屏',
          ),
        _buildPopupMenu(context, sync),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildChatPanel(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: '聊天室'),
              Tab(icon: Icon(Icons.playlist_play), text: '播放列表'),
            ],
            labelStyle: Theme.of(context).textTheme.labelLarge,
            indicatorSize: TabBarIndicatorSize.label,
          ),
          Expanded(
            child: TabBarView(
              children: [
                ChatRoomWidget(
                  messages: _syncProvider.chatMessages,
                  onSendMessage: (message) {
                    _syncProvider.sendChat(message);
                  },
                  currentUserId: _syncProvider.userId,
                  isEnabled: _syncProvider.isConnected,
                ),
                const PlaylistWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final player = _playerProvider;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: AppTheme.spacingL),
            Text('播放错误', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              player.error ?? '未知错误',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    player.clearError();
                    _pickVideo();
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('选择其他视频'),
                ),
                const SizedBox(width: AppTheme.spacingM),
                FilledButton.icon(
                  onPressed: () {
                    player.clearError();
                    if (player.videoPath != null) {
                      player.loadVideo(player.videoPath!);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '暂无视频',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '点击上方文件夹图标选择视频文件',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            FilledButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.folder_open),
              label: const Text('选择视频'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final paths = result.paths.whereType<String>().toList();
        debugPrint('Selected ${paths.length} videos');
        
        if (paths.isEmpty) return;
        
        if (paths.length == 1) {
          final path = paths.first;
          _currentVideoName = result.files.first.name;
          
          await _playerProvider.loadVideo(path);
          _startWatchTimer();
          
          if (_syncProvider.isHost) {
            final success = await _syncProvider.startVideoStream(
              path,
              videoName: _currentVideoName,
            );
            
            await _syncProvider.setPlaylist(paths);
            
            if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('启动视频流服务失败')),
              );
            }
          }
        } else {
          _currentVideoName = result.files.first.name;
          
          if (_syncProvider.isHost) {
            final success = await _syncProvider.setPlaylist(paths);
            if (success) {
              _startWatchTimer();
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('创建播放列表失败')),
              );
            }
          } else {
            await _playerProvider.loadVideo(paths.first);
            _startWatchTimer();
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e')),
        );
      }
    }
  }

  Future<void> _enterFullscreen() async {
    if (_isFullscreenTransitioning) return;
    _isFullscreenTransitioning = true;
    
    _gestureIndicatorTimer?.cancel();
    _gestureIndicatorTimer = null;
    
    setState(() {
      _showGestureIndicator = false;
      _gestureType = _GestureType.none;
      _isFullscreen = true;
    });
    
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      setState(() {});
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    _isFullscreenTransitioning = false;
  }

  Future<void> _exitFullscreen() async {
    if (_isFullscreenTransitioning) return;
    _isFullscreenTransitioning = true;
    
    _gestureIndicatorTimer?.cancel();
    _gestureIndicatorTimer = null;
    
    setState(() {
      _showGestureIndicator = false;
      _gestureType = _GestureType.none;
      _isFullscreen = false;
    });
    
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      setState(() {});
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    _isFullscreenTransitioning = false;
  }

  Widget _buildPopupMenu(BuildContext context, SyncProvider sync) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleMenuSelection(context, sync, value),
      itemBuilder: (context) {
        if (sync.isHost) {
          return [
            const PopupMenuItem(
              value: 'share_ip',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('分享房间IP'),
              ),
            ),
            const PopupMenuItem(
              value: 'dissolve',
              child: ListTile(
                leading: Icon(Icons.close),
                title: Text('解散房间'),
              ),
            ),
          ];
        } else {
          return [
            const PopupMenuItem(
              value: 'leave',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('离开房间'),
              ),
            ),
          ];
        }
      },
    );
  }

  void _handleMenuSelection(BuildContext context, SyncProvider sync, String value) {
    switch (value) {
      case 'share_ip':
        _showShareIpDialog(context, sync);
        break;
      case 'dissolve':
        _showEndRoomDialog(context, sync);
        break;
      case 'leave':
        _showLeaveRoomDialog(context, sync);
        break;
    }
  }

  Future<void> _showShareIpDialog(BuildContext context, SyncProvider sync) async {
    // 获取本机 IP
    String hostIp = '未知';
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            hostIp = addr.address;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('分享房间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('其他用户可以通过以下信息加入房间：'),
            const SizedBox(height: 16),
            SelectableText(
              'IP: $hostIp\n端口: ${widget.port ?? 37670}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出房间'),
        content: const Text('确定要退出当前房间吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showLeaveRoomDialog(BuildContext context, SyncProvider sync) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('离开房间'),
        content: const Text('确定要离开当前房间吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _leaveRoom(context, sync);
            },
            child: const Text('离开'),
          ),
        ],
      ),
    );
  }

  void _showEndRoomDialog(BuildContext context, SyncProvider sync) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束房间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('确定要结束房间吗？'),
            if (sync.userCount > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '房间内还有 ${sync.userCount - 1} 位其他用户将被断开连接。',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _endRoom(context, sync);
            },
            child: const Text('结束房间'),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveRoom(BuildContext context, SyncProvider sync) async {
    await sync.leaveRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _endRoom(BuildContext context, SyncProvider sync) async {
    final roomProvider = context.read<RoomProvider>();
    
    await sync.leaveRoom();
    await roomProvider.leaveRoom();
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
