import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

enum PlayerStatus {
  idle,
  loading,
  ready,
  playing,
  paused,
  ended,
  error,
}

class PlayerProvider extends ChangeNotifier {
  static const String _keyHardwareDecoding = 'hardware_decoding';
  static const String _keyDefaultVolume = 'default_volume';

  Player? _player;
  VideoController? _videoController;
  
  PlayerStatus _status = PlayerStatus.idle;
  String? _videoPath;
  String? _error;
  bool _isFullscreen = false;
  bool _controlsVisible = true;
  bool _hardwareDecoding = true;
  double _volume = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isSeeking = false;
  
  Timer? _controlsHideTimer;
  Timer? _positionUpdateTimer;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _streamSubscription;

  Player? get player => _player;
  VideoController? get videoController => _videoController;
  PlayerStatus get status => _status;
  String? get videoPath => _videoPath;
  String? get error => _error;
  bool get isFullscreen => _isFullscreen;
  bool get controlsVisible => _controlsVisible;
  bool get hardwareDecoding => _hardwareDecoding;
  double get volume => _volume;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isSeeking => _isSeeking;
  bool get isPlaying => _status == PlayerStatus.playing;
  bool get isPaused => _status == PlayerStatus.paused;
  bool get isReady => _status == PlayerStatus.ready || 
                      _status == PlayerStatus.playing || 
                      _status == PlayerStatus.paused;
  bool get hasVideo => _videoPath != null && _player != null;
  
  List<AudioTrack> get audioTracks => _player?.state.tracks.audio ?? [];
  List<SubtitleTrack> get subtitleTracks => _player?.state.tracks.subtitle ?? [];
  AudioTrack? get currentAudioTrack => _player?.state.track.audio;
  SubtitleTrack? get currentSubtitleTrack => _player?.state.track.subtitle;
  bool get hasMultipleAudioTracks => audioTracks.length > 1;
  bool get hasSubtitleTracks => subtitleTracks.isNotEmpty;

  PlayerProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hardwareDecoding = prefs.getBool(_keyHardwareDecoding) ?? true;
      _volume = prefs.getDouble(_keyDefaultVolume) ?? 1.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading player settings: $e');
    }
  }

  Future<void> initialize() async {
    if (_player != null) return;

    try {
      _player = Player(
        configuration: PlayerConfiguration(
          title: 'Syncro Player',
          ready: () {
            _onPlayerReady();
          },
        ),
      );

      _videoController = VideoController(_player!);
      
      _setupStreams();
      
      await _player!.setVolume(_volume * 100);
      
      await _optimizePlayerForStreaming();
      
      _status = PlayerStatus.idle;
      notifyListeners();
    } catch (e) {
      _error = '初始化播放器失败: $e';
      _status = PlayerStatus.error;
      notifyListeners();
    }
  }

  Future<void> _optimizePlayerForStreaming() async {
    if (_player == null || _player!.platform == null) return;
    
    final platform = _player!.platform;
    if (platform is! NativePlayer) return;
    
    try {
      String? cacheDir;
      try {
        final tempDir = await getTemporaryDirectory();
        cacheDir = tempDir.path;
      } catch (e) {
        debugPrint('⚠️ Failed to get cache directory: $e');
      }
      
      if (Platform.isAndroid) {
        await _configureAndroidPlayer(platform, cacheDir);
      } else if (Platform.isWindows) {
        await _configureWindowsPlayer(platform, cacheDir);
      } else {
        await _configureDefaultPlayer(platform, cacheDir);
      }
      
      await _configureStreamingBuffer(platform);
      await _configureDemuxerForLargeFiles(platform);
      
      debugPrint('✅ Player optimized for ${Platform.operatingSystem}: streaming ready');
    } catch (e) {
      debugPrint('⚠️ Failed to set player properties: $e');
    }
  }

  Future<void> _configureAndroidPlayer(NativePlayer platform, String? cacheDir) async {
    await platform.setProperty('hwdec', 'mediacodec-all');
    await platform.setProperty('hwdec-codecs', 'all');
    await platform.setProperty('hwdec-image-format', 'nv12');
    
    await platform.setProperty('vd-lavc-dr', 'yes');
    await platform.setProperty('vd-lavc-software-fallback', 'yes');
    
    await platform.setProperty('video-rotate', 'auto');
    
    await platform.setProperty('cache', 'yes');
    await platform.setProperty('cache-on-disk', 'yes');
    if (cacheDir != null) {
      await platform.setProperty('cache-dir', cacheDir);
    }
    
    await platform.setProperty('demuxer-max-bytes', '200M');
    await platform.setProperty('demuxer-max-back-bytes', '100M');
    await platform.setProperty('demuxer-readahead-secs', '600');
    
    debugPrint('📱 Android: mediacodec-all, disk cache enabled, 200M memory, 600s readahead');
  }

  Future<void> _configureWindowsPlayer(NativePlayer platform, String? cacheDir) async {
    await platform.setProperty('hwdec', 'd3d11va');
    await platform.setProperty('hwdec-codecs', 'all');
    await platform.setProperty('d3d11-adapter', 'auto');
    await platform.setProperty('d3d11-sync-surfaces', 'yes');
    
    await platform.setProperty('gpu-context', 'auto');
    
    await platform.setProperty('cache', 'yes');
    await platform.setProperty('cache-on-disk', 'yes');
    if (cacheDir != null) {
      await platform.setProperty('cache-dir', cacheDir);
    }
    
    await platform.setProperty('demuxer-max-bytes', '500M');
    await platform.setProperty('demuxer-max-back-bytes', '250M');
    await platform.setProperty('demuxer-readahead-secs', '600');
    
    debugPrint('🖥️ Windows: d3d11va, disk cache enabled, 500M memory, 600s readahead');
  }

  Future<void> _configureDefaultPlayer(NativePlayer platform, String? cacheDir) async {
    await platform.setProperty('hwdec', 'auto-safe');
    await platform.setProperty('hwdec-codecs', 'all');
    
    await platform.setProperty('cache', 'yes');
    await platform.setProperty('cache-on-disk', 'yes');
    if (cacheDir != null) {
      await platform.setProperty('cache-dir', cacheDir);
    }
    
    await platform.setProperty('demuxer-max-bytes', '300M');
    await platform.setProperty('demuxer-max-back-bytes', '150M');
    await platform.setProperty('demuxer-readahead-secs', '600');
    
    debugPrint('💻 Default: auto-safe, disk cache enabled, 300M memory, 600s readahead');
  }

  Future<void> _configureStreamingBuffer(NativePlayer platform) async {
    await platform.setProperty('cache-secs', '10');
    await platform.setProperty('cache-pause', 'yes');
    await platform.setProperty('cache-pause-initial', 'yes');
    
    await platform.setProperty('framedrop', 'decoder+vo');
    await platform.setProperty('video-sync', 'display-resample');
    await platform.setProperty('interpolation', 'no');
    
    await platform.setProperty('stream-buffer-size', '4k');
  }

  Future<void> _configureDemuxerForLargeFiles(NativePlayer platform) async {
    await platform.setProperty('demuxer-max-bytes', '500M');
    await platform.setProperty('demuxer-max-back-bytes', '250M');
    await platform.setProperty('demuxer-readahead-secs', '600');
    
    await platform.setProperty('demuxer-seekable-cache', 'yes');
    await platform.setProperty('demuxer-cache-wait', 'yes');
    
    await platform.setProperty('index', 'default');
    
    await platform.setProperty('mf-cache', 'auto');
    
    await platform.setProperty('demuxer-lavf-o', 'fastseek=1');
    
    await platform.setProperty('rebase-start-time', 'no');
    
    debugPrint('📦 Demuxer configured for large files and MKV tracks');
  }

  void _setupStreams() {
    _positionSubscription?.cancel();
    _streamSubscription?.cancel();

    _positionSubscription = _player!.stream.position.listen((position) {
      if (!_isSeeking) {
        _position = position;
        notifyListeners();
      }
    });

    _streamSubscription = _player!.stream.completed.listen((completed) {
      if (completed) {
        _status = PlayerStatus.ended;
        notifyListeners();
      }
    });

    _player!.stream.playing.listen((playing) {
      if (playing && _status != PlayerStatus.playing) {
        _status = PlayerStatus.playing;
        notifyListeners();
      } else if (!playing && _status == PlayerStatus.playing) {
        _status = PlayerStatus.paused;
        notifyListeners();
      }
    });

    _player!.stream.tracks.listen((tracks) {
      debugPrint('🎵 Audio tracks: ${tracks.audio.length}');
      debugPrint('📝 Subtitle tracks: ${tracks.subtitle.length}');
      notifyListeners();
    });
  }

  void _onPlayerReady() {
    _status = PlayerStatus.ready;
    notifyListeners();
  }

  Future<bool> loadVideo(String path) async {
    if (_player == null) {
      await initialize();
    }

    _status = PlayerStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final isNetworkUrl = path.startsWith('http://') || path.startsWith('https://');
      debugPrint('🎬 Loading video: $path (network: $isNetworkUrl)');
      
      if (!isNetworkUrl) {
        final file = File(path);
        if (!await file.exists()) {
          _error = '视频文件不存在';
          _status = PlayerStatus.error;
          notifyListeners();
          return false;
        }
      }

      await _player!.setAudioTrack(AudioTrack.auto());
      await _player!.setSubtitleTrack(SubtitleTrack.auto());
      await _player!.open(Media(path));
      
      _videoPath = path;
      _status = PlayerStatus.ready;
      
      final duration = await _player!.stream.duration.first;
      _duration = duration;
      
      debugPrint('🎬 Video loaded, duration: ${duration.inSeconds}s');
      debugPrint('🎵 Tracks after load: audio=${_player!.state.tracks.audio.length}, subtitle=${_player!.state.tracks.subtitle.length}');
      
      if (isNetworkUrl) {
        Future.delayed(const Duration(seconds: 2), () {
          debugPrint('📝 Subtitle tracks after delay: ${_player!.state.tracks.subtitle}');
          notifyListeners();
        });
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '加载视频失败: $e';
      _status = PlayerStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> play() async {
    if (_player == null) return;
    
    try {
      await _player!.play();
      _status = PlayerStatus.playing;
      _startControlsHideTimer();
      notifyListeners();
    } catch (e) {
      _error = '播放失败: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_player == null) return;
    
    try {
      await _player!.pause();
      _status = PlayerStatus.paused;
      _cancelControlsHideTimer();
      _controlsVisible = true;
      notifyListeners();
    } catch (e) {
      _error = '暂停失败: $e';
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    if (_player == null) return;
    
    try {
      await _player!.seek(position);
      _position = position;
      notifyListeners();
    } catch (e) {
      _error = '跳转失败: $e';
      notifyListeners();
    }
  }

  void startSeeking() {
    _isSeeking = true;
    _cancelControlsHideTimer();
  }

  void endSeeking(Duration position) {
    _isSeeking = false;
    seek(position);
    _startControlsHideTimer();
  }

  Future<void> setVolume(double volume) async {
    if (_player == null) return;
    
    _volume = volume.clamp(0.0, 1.0);
    await _player!.setVolume(_volume * 100);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyDefaultVolume, _volume);
    } catch (e) {
      debugPrint('Error saving volume: $e');
    }
    
    notifyListeners();
  }

  Future<void> setHardwareDecoding(bool enabled) async {
    _hardwareDecoding = enabled;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHardwareDecoding, enabled);
    } catch (e) {
      debugPrint('Error saving hardware decoding setting: $e');
    }
    
    notifyListeners();
  }

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  void showControls() {
    _controlsVisible = true;
    _cancelControlsHideTimer();
    notifyListeners();
    
    if (isPlaying) {
      _startControlsHideTimer();
    }
  }

  void hideControls() {
    _controlsVisible = false;
    notifyListeners();
  }

  void _startControlsHideTimer() {
    _cancelControlsHideTimer();
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (isPlaying) {
        hideControls();
      }
    });
  }

  void _cancelControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
  }

  Future<void> stop() async {
    if (_player == null) return;
    
    try {
      await _player!.stop();
      _videoPath = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      _status = PlayerStatus.idle;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping player: $e');
    }
  }

  Future<void> unloadVideo() async {
    await stop();
    _error = null;
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPosition => formatDuration(_position);
  String get formattedDuration => formatDuration(_duration);
  String get formattedProgress => '$formattedPosition / $formattedDuration';

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> setAudioTrack(AudioTrack track) async {
    if (_player == null) return;
    
    try {
      await _player!.setAudioTrack(track);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting audio track: $e');
    }
  }

  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    if (_player == null) return;
    
    try {
      await _player!.setSubtitleTrack(track);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting subtitle track: $e');
    }
  }

  Future<void> disableSubtitle() async {
    if (_player == null) return;
    
    try {
      await _player!.setSubtitleTrack(SubtitleTrack.no());
      notifyListeners();
    } catch (e) {
      debugPrint('Error disabling subtitle: $e');
    }
  }

  @override
  void dispose() {
    _cancelControlsHideTimer();
    _positionUpdateTimer?.cancel();
    _positionSubscription?.cancel();
    _streamSubscription?.cancel();
    
    _player?.dispose();
    _player = null;
    _videoController = null;
    
    super.dispose();
  }
}
