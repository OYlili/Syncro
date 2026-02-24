import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

enum GestureType {
  none,
  brightness,
  volume,
  seek,
}

class CustomVideoControls extends StatefulWidget {
  final Widget child;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double volume;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onPlayPause;
  final Function(Duration)? onSeek;
  final Function(double)? onVolumeChanged;
  final Function(double)? onBrightnessChanged;

  const CustomVideoControls({
    super.key,
    required this.child,
    required this.position,
    required this.duration,
    this.isPlaying = false,
    this.volume = 1.0,
    this.enabled = true,
    this.onTap,
    this.onDoubleTap,
    this.onPlayPause,
    this.onSeek,
    this.onVolumeChanged,
    this.onBrightnessChanged,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  GestureType _gestureType = GestureType.none;
  double _startDx = 0;
  double _startDy = 0;
  double _currentValue = 0;
  double? _brightness;
  Duration? _seekPosition;
  Timer? _feedbackTimer;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _initBrightness();
  }

  Future<void> _initBrightness() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _brightness = await ScreenBrightness().current;
      } catch (e) {
        _brightness = 0.5;
      }
    }
  }

  void _showFeedbackOverlay() {
    _feedbackTimer?.cancel();
    setState(() => _showFeedback = true);
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showFeedback = false);
      }
    });
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (!widget.enabled) return;
    
    _startDx = details.localPosition.dx;
    _startDy = details.localPosition.dy;
    _currentValue = 0;
    _seekPosition = null;
    
    if (details.localPosition.dx < size.width / 2) {
      _gestureType = GestureType.brightness;
      _currentValue = _brightness ?? 0.5;
    } else {
      _gestureType = GestureType.volume;
      _currentValue = widget.volume;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!widget.enabled) return;
    
    final dx = details.localPosition.dx - _startDx;
    final dy = details.localPosition.dy - _startDy;
    
    if (_gestureType == GestureType.brightness || _gestureType == GestureType.volume) {
      if (dx.abs() > dy.abs() && dx.abs() > 20) {
        _gestureType = GestureType.seek;
        _seekPosition = widget.position;
      }
    }
    
    if (_gestureType == GestureType.seek) {
      final seekSeconds = (dx / size.width) * 120;
      final newPosition = widget.position + Duration(seconds: seekSeconds.round());
      _seekPosition = Duration(
        milliseconds: newPosition.inMilliseconds.clamp(0, widget.duration.inMilliseconds),
      );
      _showFeedbackOverlay();
    } else if (_gestureType == GestureType.volume) {
      final volumeDelta = -dy / size.height;
      _currentValue = (widget.volume + volumeDelta).clamp(0.0, 1.0);
      widget.onVolumeChanged?.call(_currentValue);
      _showFeedbackOverlay();
    } else if (_gestureType == GestureType.brightness) {
      final brightnessDelta = -dy / size.height;
      _currentValue = ((_brightness ?? 0.5) + brightnessDelta).clamp(0.0, 1.0);
      _setBrightness(_currentValue);
      _showFeedbackOverlay();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    
    if (_gestureType == GestureType.seek && _seekPosition != null) {
      widget.onSeek?.call(_seekPosition!);
    }
    
    setState(() {
      _gestureType = GestureType.none;
      _showFeedback = false;
    });
    _feedbackTimer?.cancel();
  }

  Future<void> _setBrightness(double value) async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await ScreenBrightness().setScreenBrightness(value);
        _brightness = value;
        widget.onBrightnessChanged?.call(value);
      } catch (e) {
        debugPrint('Error setting brightness: $e');
      }
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onPanStart: (details) => _onPanStart(details, size),
            onPanUpdate: (details) => _onPanUpdate(details, size),
            onPanEnd: _onPanEnd,
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          ),
        ),
        if (_showFeedback) _buildFeedbackOverlay(),
      ],
    );
  }

  Widget _buildFeedbackOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFeedbackIcon(),
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _getFeedbackText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFeedbackIcon() {
    switch (_gestureType) {
      case GestureType.volume:
        if (_currentValue <= 0) return Icons.volume_off;
        if (_currentValue < 0.5) return Icons.volume_down;
        return Icons.volume_up;
      case GestureType.brightness:
        if (_currentValue < 0.3) return Icons.brightness_low;
        if (_currentValue < 0.7) return Icons.brightness_medium;
        return Icons.brightness_high;
      case GestureType.seek:
        final diff = (_seekPosition?.inSeconds ?? 0) - widget.position.inSeconds;
        return diff >= 0 ? Icons.fast_forward : Icons.fast_rewind;
      default:
        return Icons.circle;
    }
  }

  String _getFeedbackText() {
    switch (_gestureType) {
      case GestureType.volume:
        return '音量: ${(_currentValue * 100).round()}%';
      case GestureType.brightness:
        return '亮度: ${(_currentValue * 100).round()}%';
      case GestureType.seek:
        final diff = (_seekPosition?.inSeconds ?? 0) - widget.position.inSeconds;
        final prefix = diff >= 0 ? '+' : '';
        return '$prefix${diff}秒';
      default:
        return '';
    }
  }
}

class VideoProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool enabled;
  final VoidCallback? onSeekStart;
  final Function(Duration)? onSeekEnd;
  final Color? progressColor;
  final Color? backgroundColor;

  const VideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.enabled = true,
    this.onSeekStart,
    this.onSeekEnd,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isDragging = false;
  double _dragProgress = 0.0;

  double get _progress {
    if (_isDragging) return _dragProgress;
    if (widget.duration.inMilliseconds <= 0) return 0;
    return widget.position.inMilliseconds / widget.duration.inMilliseconds;
  }

  void _handleDragStart(DragStartDetails details, double width) {
    if (!widget.enabled) return;
    widget.onSeekStart?.call();
    setState(() {
      _isDragging = true;
      _dragProgress = (details.localPosition.dx / width).clamp(0.0, 1.0);
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    if (!_isDragging || !widget.enabled) return;
    setState(() {
      _dragProgress = (details.localPosition.dx / width).clamp(0.0, 1.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final position = Duration(
      milliseconds: (widget.duration.inMilliseconds * _dragProgress).round(),
    );
    widget.onSeekEnd?.call(position);
    
    setState(() => _isDragging = false);
  }

  void _handleTap(TapUpDetails details, double width) {
    if (!widget.enabled) return;
    final progress = (details.localPosition.dx / width).clamp(0.0, 1.0);
    final position = Duration(
      milliseconds: (widget.duration.inMilliseconds * progress).round(),
    );
    widget.onSeekStart?.call();
    widget.onSeekEnd?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.progressColor ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? Colors.white.withValues(alpha: 0.3);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart: (details) => _handleDragStart(details, width),
          onHorizontalDragUpdate: (details) => _handleDragUpdate(details, width),
          onHorizontalDragEnd: _handleDragEnd,
          onTapUp: (details) => _handleTap(details, width),
          child: Container(
            height: 32,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: (width * _progress.clamp(0.0, 1.0)) - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VideoControlsOverlay extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool controlsVisible;
  final bool canControl;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;
  final Function(Duration)? onSeek;
  final VoidCallback? onToggleFullscreen;

  const VideoControlsOverlay({
    super.key,
    required this.position,
    required this.duration,
    this.isPlaying = false,
    this.controlsVisible = true,
    this.canControl = true,
    this.onPlayPause,
    this.onSeekBackward,
    this.onSeekForward,
    this.onSeek,
    this.onToggleFullscreen,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.controlsVisible,
      child: AnimatedOpacity(
        opacity: widget.controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 中心控制按钮
              Center(
                child: _buildCenterControls(),
              ),
              // 底部控制栏
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.canControl)
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
            onPressed: widget.onSeekBackward,
          ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: widget.canControl ? widget.onPlayPause : null,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.canControl ? Colors.white : Colors.white.withValues(alpha: 0.5),
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        if (widget.canControl)
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
            onPressed: widget.onSeekForward,
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: widget.canControl ? widget.onPlayPause : null,
            ),
            Text(
              _formatDuration(widget.position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VideoProgressBar(
                position: widget.position,
                duration: widget.duration,
                enabled: widget.canControl,
                onSeekStart: () {},
                onSeekEnd: widget.onSeek,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(widget.duration),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: widget.onToggleFullscreen,
            ),
          ],
        ),
      ),
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
}
