import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/danmaku_item.dart';
import '../models/danmaku_settings.dart';

class DanmakuView extends StatefulWidget {
  final bool isFullscreen;
  final bool isEnabled;
  final double speedMultiplier;
  final double opacity;
  final DanmakuArea area;
  final double fontSizeMultiplier;

  const DanmakuView({
    super.key,
    this.isFullscreen = false,
    this.isEnabled = true,
    this.speedMultiplier = 1.0,
    this.opacity = 1.0,
    this.area = DanmakuArea.full,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  State<DanmakuView> createState() => DanmakuViewState();
}

class DanmakuViewState extends State<DanmakuView> with SingleTickerProviderStateMixin {
  final List<DanmakuItem> _activeDanmaku = [];
  final List<_TrackInfo> _tracks = [];
  final List<DanmakuItem> _pendingDanmaku = [];
  
  Timer? _animationTimer;
  static const double _baseSpeed = 0.0003;
  static const double _trackHeight = 32.0;
  static const double _fullscreenTrackHeight = 40.0;
  static const int _maxTracks = 15;
  static const int _maxActiveDanmaku = 50;
  
  double _viewWidth = 0;
  double _viewHeight = 0;
  int _lastTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _lastTimestamp = DateTime.now().millisecondsSinceEpoch;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), _onTick);
  }

  void _onTick(Timer timer) {
    if (!widget.isEnabled || _viewWidth <= 0) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final deltaMs = now - _lastTimestamp;
    _lastTimestamp = now;
    
    final delta = deltaMs * _baseSpeed * widget.speedMultiplier;
    
    setState(() {
      for (final danmaku in _activeDanmaku) {
        danmaku.updateProgress(delta);
      }
      
      _activeDanmaku.removeWhere((d) => d.isFinished);
      
      _processPendingDanmaku();
    });
  }

  void _processPendingDanmaku() {
    while (_pendingDanmaku.isNotEmpty && _activeDanmaku.length < _maxActiveDanmaku) {
      final danmaku = _pendingDanmaku.removeAt(0);
      final trackIndex = _findAvailableTrack();
      if (trackIndex != -1) {
        final updatedDanmaku = DanmakuItem(
          id: danmaku.id,
          content: danmaku.content,
          senderName: danmaku.senderName,
          createdAt: danmaku.createdAt,
          speed: danmaku.speed,
          trackIndex: trackIndex,
          colorType: danmaku.colorType,
          customColor: danmaku.customColor,
          position: danmaku.position,
        );
        _activeDanmaku.add(updatedDanmaku);
        _markTrackOccupied(trackIndex, updatedDanmaku);
      } else {
        break;
      }
    }
  }

  int _findAvailableTrack() {
    final trackHeight = widget.isFullscreen ? _fullscreenTrackHeight : _trackHeight;
    final maxTracks = min(_maxTracks, (_viewWidth / 100).floor().clamp(5, _maxTracks));
    
    int startTrack = 0;
    int endTrack = maxTracks;
    
    switch (widget.area) {
      case DanmakuArea.topHalf:
        endTrack = (maxTracks / 2).ceil();
        break;
      case DanmakuArea.bottomHalf:
        startTrack = (maxTracks / 2).floor();
        break;
      case DanmakuArea.full:
        break;
    }
    
    while (_tracks.length < maxTracks) {
      _tracks.add(_TrackInfo());
    }
    
    for (int i = startTrack; i < endTrack && i < _tracks.length; i++) {
      if (!_tracks[i].isOccupied) {
        return i;
      }
    }
    
    int leastOccupiedTrack = startTrack;
    double minOccupancy = double.infinity;
    for (int i = startTrack; i < endTrack && i < _tracks.length; i++) {
      final occupancy = _tracks[i].occupancyProgress;
      if (occupancy < minOccupancy) {
        minOccupancy = occupancy;
        leastOccupiedTrack = i;
      }
    }
    
    return leastOccupiedTrack;
  }

  void _markTrackOccupied(int trackIndex, DanmakuItem danmaku) {
    if (trackIndex < _tracks.length) {
      _tracks[trackIndex].occupy(danmaku);
    }
  }

  void addDanmaku(String content, {String senderName = '', bool isHost = false, int color = 0xFFFFFFFF, int position = 0}) {
    if (!widget.isEnabled || content.trim().isEmpty) return;
    
    final danmakuPosition = DanmakuPosition.values[position.clamp(0, DanmakuPosition.values.length - 1)];
    final danmakuColor = Color(color);
    
    debugPrint('🎨 addDanmaku: content="$content", color=0x${color.toRadixString(16)}, isHost=$isHost');
    
    final danmaku = DanmakuItem(
      id: DanmakuItem.generateId(),
      content: content,
      senderName: senderName,
      createdAt: DateTime.now(),
      speed: 1.0 + Random().nextDouble() * 0.2,
      colorType: isHost ? ColorType.host : ColorType.normal,
      customColor: danmakuColor,
      position: danmakuPosition,
    );
    
    debugPrint('🎨 DanmakuItem: customColor=${danmaku.customColor}, displayColor=${danmaku.displayColor}');
    
    _pendingDanmaku.add(danmaku);
  }

  void clear() {
    setState(() {
      _activeDanmaku.clear();
      _pendingDanmaku.clear();
      for (final track in _tracks) {
        track.release();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewWidth = constraints.maxWidth;
        _viewHeight = constraints.maxHeight;
        
        if (!widget.isEnabled) {
          return const SizedBox.shrink();
        }
        
        final trackHeight = widget.isFullscreen ? _fullscreenTrackHeight : _trackHeight;
        final baseFontSize = widget.isFullscreen ? 18.0 : 14.0;
        final fontSize = baseFontSize * widget.fontSizeMultiplier;
        
        return Opacity(
          opacity: widget.opacity,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: _activeDanmaku.map((danmaku) {
              return _buildDanmakuWidget(danmaku, trackHeight, fontSize);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDanmakuWidget(DanmakuItem danmaku, double trackHeight, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: danmaku.content,
        style: TextStyle(
          color: danmaku.displayColor,
          fontSize: fontSize,
          fontWeight: danmaku.colorType == ColorType.host ? FontWeight.bold : FontWeight.normal,
          shadows: const [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    final textWidth = textPainter.width;
    final totalDistance = _viewWidth + textWidth;
    final startX = _viewWidth;
    final left = startX - (totalDistance * danmaku.progress);
    final top = danmaku.trackIndex * trackHeight;
    
    return Positioned(
      left: left,
      top: top,
      child: Text(
        danmaku.content,
        style: TextStyle(
          color: danmaku.displayColor,
          fontSize: fontSize,
          fontWeight: danmaku.colorType == ColorType.host ? FontWeight.bold : FontWeight.normal,
          shadows: const [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackInfo {
  bool isOccupied = false;
  double occupancyProgress = 0.0;
  String? currentDanmakuId;
  
  void occupy(DanmakuItem danmaku) {
    isOccupied = true;
    currentDanmakuId = danmaku.id;
    occupancyProgress = 0.0;
  }
  
  void release() {
    isOccupied = false;
    currentDanmakuId = null;
    occupancyProgress = 0.0;
  }
}
