import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

class AudioTrackProvider extends ChangeNotifier {
  List<AudioTrack> _tracks = [];
  AudioTrack? _currentTrack;
  String? _currentTrackId;

  Player? _player;

  List<AudioTrack> get tracks => _tracks;
  AudioTrack? get currentTrack => _currentTrack;
  String? get currentTrackId => _currentTrackId;

  void setPlayer(Player player) {
    _player = player;
    _listenToTracks();
  }

  void _listenToTracks() {
    if (_player == null) return;

    _player!.stream.tracks.listen((tracks) {
      _tracks = tracks.audio;
      notifyListeners();
    });
  }

  void setTracks(List<AudioTrack> tracks) {
    _tracks = tracks;
    notifyListeners();
  }

  Future<void> selectTrack(String trackId) async {
    if (_player == null) return;

    final track = _tracks.firstWhere(
      (t) => t.id == trackId,
      orElse: () => AudioTrack.auto(),
    );
    _currentTrackId = trackId;
    _currentTrack = track;
    await _player!.setAudioTrack(track);
    notifyListeners();
  }

  void hydrateFromSnapshot(Map<String, dynamic> snapshot) {
    final audioTracksJson = snapshot['audioTracks'] as List<dynamic>?;
    final currentAudioId = snapshot['currentAudioId'] as String?;

    if (audioTracksJson != null) {
      _tracks = [];
    }

    if (currentAudioId != null) {
      _currentTrackId = currentAudioId;
    }

    notifyListeners();
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'audioTracks': _tracks.map((t) {
        return {
          'id': t.id,
          'language': t.language,
          'title': t.title,
        };
      }).toList(),
      'currentAudioId': _currentTrackId,
    };
  }
}
