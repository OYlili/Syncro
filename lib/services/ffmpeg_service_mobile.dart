import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'ffmpeg_service.dart';

class FFmpegServiceMobile implements FFmpegService {
  @override
  Future<Map<String, List<TrackInfo>>> extractTracks(String filePath) async {
    final session = await FFprobeKit.execute(
      '-v quiet -print_format json -show_format -show_streams "$filePath"',
    );
    
    final output = await session.getOutput();
    if (output != null) {
      try {
        final jsonData = jsonDecode(output);
        final streams = jsonData['streams'] as List?;
        
        final videoTracks = <TrackInfo>[];
        final audioTracks = <TrackInfo>[];
        final subtitleTracks = <TrackInfo>[];
        
        if (streams != null) {
          for (int i = 0; i < streams.length; i++) {
            final stream = streams[i] as Map<String, dynamic>;
            final codecType = stream['codec_type'] as String?;
            final trackInfo = TrackInfo(
              id: i,
              language: stream['tags']?['language'] ?? 'und',
              title: stream['tags']?['title'],
              codec: stream['codec_name'],
            );
            
            if (codecType == 'video') {
              videoTracks.add(trackInfo);
            } else if (codecType == 'audio') {
              audioTracks.add(trackInfo);
            } else if (codecType == 'subtitle') {
              subtitleTracks.add(trackInfo);
            }
          }
        }
        
        return {
          'video': videoTracks,
          'audio': audioTracks,
          'subtitle': subtitleTracks,
        };
      } catch (e) {
        debugPrint('❌ Error parsing FFprobe output: $e');
      }
    }
    
    return {
      'video': <TrackInfo>[],
      'audio': <TrackInfo>[],
      'subtitle': <TrackInfo>[],
    };
  }

  @override
  Future<String> extractSubtitleToVtt(String filePath, int trackIndex, String outputDir) async {
    final outputPath = path.join(
      outputDir,
      'subtitle_${DateTime.now().millisecondsSinceEpoch}.vtt',
    );

    final session = await FFmpegKit.execute(
      '-i "$filePath" -map 0:s:$trackIndex -f webvtt -y "$outputPath"',
    );

    final returnCode = await session.getReturnCode();
    if (returnCode != null && returnCode.isValueSuccess()) {
      final file = File(outputPath);
      if (await file.exists()) {
        return outputPath;
      }
    }
    
    debugPrint('❌ FFmpeg subtitle extraction failed');
    throw Exception('Failed to extract subtitle');
  }
}
