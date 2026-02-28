import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class SubtitleProvider extends ChangeNotifier {
  List<SubtitleTrack> _tracks = [];
  SubtitleTrack? _currentTrack;
  String? _currentTrackId;
  String? _lastActiveTrackId;
  String? _externalSubtitleUrl;

  Player? _player;

  List<SubtitleTrack> get tracks => _tracks;
  SubtitleTrack? get currentTrack => _currentTrack;
  String? get currentTrackId => _currentTrackId;
  String? get lastActiveTrackId => _lastActiveTrackId;
  String? get externalSubtitleUrl => _externalSubtitleUrl;
  bool get isSubtitleEnabled => _currentTrackId != null && _currentTrackId != 'off';

  void setPlayer(Player player) {
    _player = player;
    _listenToTracks();
  }

  void _listenToTracks() {
    if (_player == null) return;

    _player!.stream.tracks.listen((tracks) {
      _tracks = tracks.subtitle;
      notifyListeners();
    });
  }

  void setTracks(List<SubtitleTrack> tracks) {
    _tracks = tracks;
    notifyListeners();
  }

  Future<void> selectTrack(String trackId) async {
    if (_player == null) return;

    if (trackId == 'off') {
      _lastActiveTrackId = _currentTrackId;
      _currentTrackId = 'off';
      _currentTrack = null;
      await _player!.setSubtitleTrack(SubtitleTrack.no());
    } else {
      final track = _tracks.firstWhere(
        (t) => t.id == trackId,
        orElse: () => SubtitleTrack.auto(),
      );
      _currentTrackId = trackId;
      _currentTrack = track;
      await _player!.setSubtitleTrack(track);
    }
    notifyListeners();
  }

  Future<void> restoreLastSubtitle() async {
    if (_lastActiveTrackId != null && _lastActiveTrackId != 'off') {
      await selectTrack(_lastActiveTrackId!);
    }
  }

  Future<void> disableSubtitle() async {
    await selectTrack('off');
  }

  void setExternalSubtitleUrl(String? url) {
    _externalSubtitleUrl = url;
    notifyListeners();
  }

  void hydrateFromSnapshot(Map<String, dynamic> snapshot) {
    final subtitleTracksJson = snapshot['subtitleTracks'] as List<dynamic>?;
    final currentSubtitleId = snapshot['currentSubtitleId'] as String?;
    final externalSubtitleUrl = snapshot['externalSubtitleUrl'] as String?;

    if (subtitleTracksJson != null) {
      _tracks = [];
    }

    if (currentSubtitleId != null) {
      _currentTrackId = currentSubtitleId;
    }

    if (externalSubtitleUrl != null) {
      _externalSubtitleUrl = externalSubtitleUrl;
    }

    notifyListeners();
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'subtitleTracks': _tracks.map((t) {
        return {
          'id': t.id,
          'language': t.language,
          'title': t.title,
        };
      }).toList(),
      'currentSubtitleId': _currentTrackId,
      'externalSubtitleUrl': _externalSubtitleUrl,
    };
  }
}
