import 'package:flutter/foundation.dart';
import 'ffmpeg_service.dart';
import 'track_service.dart';

class FFmpegServiceMobile implements FFmpegService {
  @override
  Future<Map<String, List<TrackInfo>>> extractTracks(String filePath) async {
    try {
      final tracks = await TrackService.getTracks(filePath);
      return tracks;
    } catch (e) {
      debugPrint('Error extracting tracks: $e');
      return {
        'video': <TrackInfo>[],
        'audio': <TrackInfo>[],
        'subtitle': <TrackInfo>[],
      };
    }
  }

  @override
  Future<String> extractSubtitleToVtt(String filePath, int trackIndex, String outputDir) async {
    debugPrint('Subtitle extraction not supported on Android. Please use external subtitle files.');
    throw UnimplementedError('Subtitle extraction not supported on Android');
  }
}
