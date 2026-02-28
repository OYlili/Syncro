import 'ffmpeg_service.dart';
import 'ffmpeg_service_factory.dart';

class SubtitleExtractService {
  static final FFmpegService _ffmpegService = FFmpegServiceFactory.create();

  static Future<Map<String, dynamic>> extractTracks(String videoPath) async {
    final tracks = await _ffmpegService.extractTracks(videoPath);
    
    final audioTracks = tracks['audio']?.map((t) => t.toJson()).toList() ?? <Map<String, dynamic>>[];
    final subtitleTracks = tracks['subtitle']?.map((t) => t.toJson()).toList() ?? <Map<String, dynamic>>[];
    final videoTracks = tracks['video']?.map((t) => t.toJson()).toList() ?? <Map<String, dynamic>>[];
    
    return {
      'video': videoTracks,
      'audio': audioTracks,
      'subtitle': subtitleTracks,
    };
  }

  static Future<String?> extractSubtitleToVtt({
    required String videoPath,
    required int trackIndex,
    required String outputDir,
  }) async {
    try {
      return await _ffmpegService.extractSubtitleToVtt(videoPath, trackIndex, outputDir);
    } catch (e) {
      return null;
    }
  }
}
