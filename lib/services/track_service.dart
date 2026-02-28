import 'dart:async';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/foundation.dart';
import 'ffmpeg_service.dart';

class TrackService {
  static Future<Map<String, List<TrackInfo>>> getTracks(String filePath) async {
    final player = Player();
    
    try {
      final completer = Completer<bool>();
      bool completed = false;
      
      final subscription = player.stream.tracks.listen((tracks) {
        if (!completed && (tracks.video.isNotEmpty || tracks.audio.isNotEmpty || tracks.subtitle.isNotEmpty)) {
          completed = true;
          completer.complete(true);
        }
      });
      
      await player.open(Media(filePath), play: false);
      
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (!completed) {
            completer.complete(false);
          }
          return false;
        },
      );
      
      await subscription.cancel();
      
      final videoTracks = player.state.tracks.video.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return TrackInfo(
          id: index,
          language: track.language,
          title: track.title,
          codec: null,
        );
      }).toList();
      
      final audioTracks = player.state.tracks.audio.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return TrackInfo(
          id: index,
          language: track.language,
          title: track.title,
          codec: null,
        );
      }).toList();
      
      final subtitleTracks = player.state.tracks.subtitle.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        return TrackInfo(
          id: index,
          language: track.language,
          title: track.title,
          codec: null,
        );
      }).toList();
      
      return {
        'video': videoTracks,
        'audio': audioTracks,
        'subtitle': subtitleTracks,
      };
    } catch (e) {
      debugPrint('Error getting tracks from media_kit: $e');
      return {
        'video': <TrackInfo>[],
        'audio': <TrackInfo>[],
        'subtitle': <TrackInfo>[],
      };
    } finally {
      await player.dispose();
    }
  }
}
