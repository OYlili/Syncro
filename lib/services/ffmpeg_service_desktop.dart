import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'ffmpeg_service.dart';

class FFmpegServiceDesktop implements FFmpegService {
  String? _ffmpegPath;

  Future<String?> getFFmpegPathForStreaming() async {
    try {
      return await _getOrExtractFFmpeg();
    } catch (_) {
      return null;
    }
  }

  Future<String> _getOrExtractFFmpeg() async {
    if (_ffmpegPath != null) {
      return _ffmpegPath!;
    }

    final appDir = await getApplicationSupportDirectory();
    final ffmpegDir = Directory(path.join(appDir.path, 'ffmpeg'));
    final binDir = Directory(path.join(ffmpegDir.path, 'bin'));
    String ffmpegExecutableName = Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
    final ffmpegPath = path.join(binDir.path, ffmpegExecutableName);
    final ffmpegFile = File(ffmpegPath);

    final markerFile = File(path.join(ffmpegDir.path, '.extracted'));

    if (await ffmpegFile.exists() && await markerFile.exists()) {
      _ffmpegPath = ffmpegPath;
      return ffmpegPath;
    }

    await ffmpegDir.create(recursive: true);
    await binDir.create(recursive: true);

    try {
      if (Platform.isWindows) {
        await _extractWindowsFFmpeg(binDir);
      } else if (Platform.isMacOS) {
        await _extractMacOSFFmpeg(binDir);
      } else if (Platform.isLinux) {
        await _extractLinuxFFmpeg(binDir);
      }

      await markerFile.writeAsString('${DateTime.now().millisecondsSinceEpoch}');

      _ffmpegPath = ffmpegPath;
      debugPrint('✅ FFmpeg extracted to: $ffmpegPath');
      return ffmpegPath;
    } catch (e) {
      debugPrint('⚠️ Failed to extract FFmpeg from assets: $e, trying system FFmpeg...');
    }

    final systemFFmpegPath = await _findSystemFFmpeg();
    if (systemFFmpegPath != null) {
      _ffmpegPath = systemFFmpegPath;
      return systemFFmpegPath;
    }

    throw Exception('FFmpeg not found in assets or system');
  }

  Future<void> _extractWindowsFFmpeg(Directory binDir) async {
    final files = [
      'ffmpeg.exe',
      'ffprobe.exe',
      'ffplay.exe',
      'avcodec-62.dll',
      'avdevice-62.dll',
      'avfilter-11.dll',
      'avformat-62.dll',
      'avutil-60.dll',
      'swresample-6.dll',
      'swscale-9.dll',
    ];

    for (final fileName in files) {
      final assetPath = 'assets/binaries/windows/bin/$fileName';
      final outputPath = path.join(binDir.path, fileName);
      try {
        final bytes = await rootBundle.load(assetPath);
        await File(outputPath).writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        debugPrint('✅ Extracted: $fileName');
      } catch (e) {
        debugPrint('⚠️ Skipping $fileName: $e');
      }
    }
  }

  Future<void> _extractMacOSFFmpeg(Directory binDir) async {
    final assetPath = 'assets/binaries/macos/ffmpeg';
    final outputPath = path.join(binDir.path, 'ffmpeg');
    final bytes = await rootBundle.load(assetPath);
    await File(outputPath).writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    await Process.run('chmod', ['+x', outputPath]);
  }

  Future<void> _extractLinuxFFmpeg(Directory binDir) async {
    final assetPath = 'assets/binaries/linux/ffmpeg';
    final outputPath = path.join(binDir.path, 'ffmpeg');
    final bytes = await rootBundle.load(assetPath);
    await File(outputPath).writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    await Process.run('chmod', ['+x', outputPath]);
  }

  Future<String?> _findSystemFFmpeg() async {
    final possiblePaths = Platform.isWindows
        ? [
            'ffmpeg',
            r'C:\ffmpeg\bin\ffmpeg.exe',
            r'C:\Program Files\ffmpeg\bin\ffmpeg.exe',
            r'C:\ProgramData\chocolatey\bin\ffmpeg.exe',
          ]
        : ['ffmpeg', '/usr/bin/ffmpeg', '/usr/local/bin/ffmpeg'];

    for (final p in possiblePaths) {
      try {
        if (p == 'ffmpeg') {
          final result = await Process.run('ffmpeg', ['-version']);
          if (result.exitCode == 0) {
            return 'ffmpeg';
          }
        } else {
          final file = File(p);
          if (await file.exists()) {
            return p;
          }
        }
      } catch (_) {}
    }

    return null;
  }

  @override
  Future<Map<String, List<TrackInfo>>> extractTracks(String filePath) async {
    final ffmpegPath = await _getOrExtractFFmpeg();
    final ffprobePath = path.join(path.dirname(ffmpegPath), Platform.isWindows ? 'ffprobe.exe' : 'ffprobe');

    String executable;
    if (await File(ffprobePath).exists()) {
      executable = ffprobePath;
    } else {
      executable = ffmpegPath;
    }

    final result = await Process.run(
      executable,
      [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        filePath,
      ],
    );

    if (result.exitCode == 0 && result.stdout != null) {
      try {
        final jsonData = jsonDecode(result.stdout.toString());
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
        debugPrint('❌ Error parsing FFmpeg output: $e');
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
    final ffmpegPath = await _getOrExtractFFmpeg();
    final outputPath = path.join(
      outputDir,
      'subtitle_${DateTime.now().millisecondsSinceEpoch}.vtt',
    );

    final result = await Process.run(
      ffmpegPath,
      [
        '-i', filePath,
        '-map', '0:s:$trackIndex',
        '-f', 'webvtt',
        '-y',
        outputPath,
      ],
    );

    if (result.exitCode == 0) {
      final file = File(outputPath);
      if (await file.exists()) {
        return outputPath;
      }
    }
    
    debugPrint('❌ FFmpeg subtitle extraction failed with exit code: ${result.exitCode}');
    debugPrint('❌ FFmpeg stderr: ${result.stderr}');
    throw Exception('Failed to extract subtitle');
  }
}
