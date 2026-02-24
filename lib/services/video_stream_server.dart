import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'subtitle_extract_service.dart';
import 'ffmpeg_service_desktop.dart';

class VideoStreamServer {
  static const int defaultPort = 37671;
  static const int maxPortAttempts = 10;

  HttpServer? _server;
  String? _videoPath;
  String? _subtitlePath;
  int _port = 0;
  String? _localIp;
  bool _isRunning = false;
  
  String? currentVideoPath;
  String? _extractedVttPath;

  bool get isRunning => _isRunning;
  int get port => _port;
  String? get videoPath => _videoPath;
  String? get subtitlePath => _subtitlePath;
  String? get videoUrl => _isRunning && _localIp != null
      ? 'http://$_localIp:$_port/video'
      : null;
  String? get subtitleUrl => _isRunning && _localIp != null && _subtitlePath != null
      ? 'http://$_localIp:$_port/subtitle'
      : null;
  String? get extractedVttUrl => _isRunning && _localIp != null && _extractedVttPath != null
      ? 'http://$_localIp:$_port/extracted_subtitle'
      : null;

  Future<String> _getLocalIpAddress() async {
    try {
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting local IP: $e');
    }
    return '127.0.0.1';
  }

  Future<int> findAvailablePort(int startPort) async {
    for (int port = startPort; port < startPort + maxPortAttempts; port++) {
      try {
        final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
        await server.close();
        return port;
      } catch (e) {
        debugPrint('Port $port is in use, trying next...');
      }
    }
    throw Exception('No available port found after $maxPortAttempts attempts');
  }

  Future<bool> start(String videoPath, {int? preferredPort}) async {
    if (_isRunning) {
      await stop();
    }

    _videoPath = videoPath;
    currentVideoPath = videoPath;
    _localIp = await _getLocalIpAddress();

    final file = File(videoPath);
    if (!await file.exists()) {
      debugPrint('❌ Video file does not exist: $videoPath');
      return false;
    }

    final fileLength = await file.length();
    debugPrint('📁 Video file: $videoPath');
    debugPrint('📁 File size: ${(fileLength / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('🌐 Local IP: $_localIp');

    try {
      _port = preferredPort ?? await findAvailablePort(defaultPort);
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isRunning = true;

      _server!.listen((request) => _handleRequest(request));

      debugPrint('✅ Video stream server started on port $_port');
      debugPrint('🎬 Video URL: $videoUrl');
      debugPrint('📺 Test URL in browser: http://127.0.0.1:$_port/video');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to start video stream server: $e');
      _isRunning = false;
      return false;
    }
  }

  Future<bool> startServerOnly({int? preferredPort}) async {
    if (_isRunning) return true;

    _localIp = await _getLocalIpAddress();

    try {
      _port = preferredPort ?? await findAvailablePort(defaultPort);
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isRunning = true;

      _server!.listen((request) => _handleRequest(request));

      debugPrint('✅ Video stream server started on port $_port');
      debugPrint('🌐 Local IP: $_localIp');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to start video stream server: $e');
      _isRunning = false;
      return false;
    }
  }

  void switchVideo(String videoPath) {
    if (!_isRunning) {
      debugPrint('⚠️ Server not running, cannot switch video');
      return;
    }
    
    _videoPath = videoPath;
    currentVideoPath = videoPath;
    _extractedVttPath = null;
    debugPrint('🔄 Switched to video: $videoPath');
  }

  void setSubtitle(String? subtitlePath) {
    _subtitlePath = subtitlePath;
    if (subtitlePath != null) {
      debugPrint('📝 Subtitle set: $subtitlePath');
    } else {
      debugPrint('📝 Subtitle cleared');
    }
  }

  Future<String?> extractAndCacheSubtitle(int trackIndex) async {
    if (currentVideoPath == null) return null;
    
    try {
      final tempDir = await Directory.systemTemp.createTemp('syncro_subtitle_');
      final outputPath = await SubtitleExtractService.extractSubtitleToVtt(
        videoPath: currentVideoPath!,
        trackIndex: trackIndex,
        outputDir: tempDir.path,
      );
      
      if (outputPath != null) {
        _extractedVttPath = outputPath;
        debugPrint('✅ Extracted subtitle cached at: $outputPath');
        return outputPath;
      }
    } catch (e) {
      debugPrint('❌ Error extracting and caching subtitle: $e');
    }
    
    return null;
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
    }
    _isRunning = false;
    _videoPath = null;
    _subtitlePath = null;
    _extractedVttPath = null;
    currentVideoPath = null;
    debugPrint('Video stream server stopped');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final uriPath = request.uri.path;
    
    debugPrint('📥 Request: ${request.method} $uriPath');
    if (request.headers.value('range') != null) {
      debugPrint('   Range: ${request.headers.value('range')}');
    }

    try {
      if (uriPath == '/subtitle') {
        final trackParam = request.uri.queryParameters['track'];
        if (trackParam != null) {
          await _serveEmbeddedSubtitleStream(request, trackParam);
        } else {
          await _serveSubtitle(request);
        }
        return;
      }

      if (uriPath == '/extracted_subtitle') {
        await _serveExtractedVtt(request);
        return;
      }

      if (uriPath == '/tracks') {
        await _serveTracks(request);
        return;
      }

      if (uriPath == '/health') {
        _serveHealth(request);
        return;
      }

      if (_videoPath == null) {
        _serveNoVideo(request);
        return;
      }

      if (uriPath == '/video' || uriPath == '/') {
        await _handleVideoRequest(request);
      } else {
        _serveNotFound(request);
      }
    } catch (e, stack) {
      debugPrint('❌ Error handling request: $e');
      debugPrint('Stack: $stack');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _handleVideoRequest(HttpRequest request) async {
    if (request.method == 'OPTIONS') {
      request.response.headers.set('Content-Type', 'video/x-matroska');
      request.response.headers.set('Accept-Ranges', 'bytes');
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('X-Content-Type-Options', 'nosniff');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    if (request.method != 'GET' && request.method != 'HEAD') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      await request.response.close();
      return;
    }

    final file = File(_videoPath!);
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final fileLength = await file.length();
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    int start = 0;
    int end = fileLength - 1;
    bool isPartial = false;

    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      final parts = rangeHeader.substring(6).split('-');
      if (parts.isNotEmpty) {
        start = int.tryParse(parts[0]) ?? 0;
        if (parts.length > 1 && parts[1].isNotEmpty) {
          end = int.tryParse(parts[1]) ?? (fileLength - 1);
        }
        isPartial = true;
      }
    }

    final response = request.response;
    response.statusCode = isPartial ? HttpStatus.partialContent : HttpStatus.ok;
    response.headers.set('Content-Type', 'video/x-matroska');
    response.headers.set('Accept-Ranges', 'bytes');
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('X-Content-Type-Options', 'nosniff');
    if (isPartial) {
      response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$fileLength');
    }
    response.headers.set(HttpHeaders.contentLengthHeader, end - start + 1);

    if (request.method == 'GET') {
      await response.addStream(file.openRead(start, end + 1));
    }
    await response.close();
  }

  Future<void> _serveSubtitle(HttpRequest request) async {
    if (_subtitlePath == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"No subtitle loaded"}');
      request.response.close();
      return;
    }

    final subtitleFile = File(_subtitlePath!);
    if (!await subtitleFile.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"Subtitle file not found"}');
      request.response.close();
      return;
    }

    final extension = _subtitlePath!.split('.').last.toLowerCase();
    final mimeType = {
      'srt': 'application/x-subrip',
      'ass': 'text/x-ssa',
      'ssa': 'text/x-ssa',
      'sub': 'text/plain',
      'vtt': 'text/vtt',
    }[extension] ?? 'text/plain';
    
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.set('Content-Type', mimeType);
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    request.response.headers.set('Cache-Control', 'no-cache');

    if (request.method == 'OPTIONS') {
      await request.response.close();
      return;
    }

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    try {
      final content = await subtitleFile.readAsBytes();
      request.response.add(content);
      await request.response.close();
      debugPrint('📝 Served subtitle: $_subtitlePath (${content.length} bytes)');
    } catch (e) {
      debugPrint('Error serving subtitle: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _serveExtractedVtt(HttpRequest request) async {
    if (_extractedVttPath == null) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"No extracted subtitle available"}');
      request.response.close();
      return;
    }

    final subtitleFile = File(_extractedVttPath!);
    if (!await subtitleFile.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"Extracted subtitle file not found"}');
      request.response.close();
      return;
    }
    
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.set('Content-Type', 'text/vtt; charset=utf-8');
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
    request.response.headers.set('Cache-Control', 'no-cache');

    if (request.method == 'OPTIONS') {
      await request.response.close();
      return;
    }

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    try {
      final content = await subtitleFile.readAsBytes();
      request.response.add(content);
      await request.response.close();
      debugPrint('📝 Served extracted subtitle: $_extractedVttPath (${content.length} bytes)');
    } catch (e) {
      debugPrint('Error serving extracted subtitle: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  void _serveNoVideo(HttpRequest request) {
    request.response.statusCode = HttpStatus.serviceUnavailable;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"error":"No video loaded"}');
    request.response.close();
  }

  void _serveHealth(HttpRequest request) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status":"ok","running":$_isRunning,"hasVideo":${_videoPath != null},"hasSubtitle":${_subtitlePath != null}}');
    request.response.close();
  }

  void _serveNotFound(HttpRequest request) {
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('Not Found');
    request.response.close();
  }

  Future<void> _serveTracks(HttpRequest request) async {
    if (currentVideoPath == null) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"No video loaded"}');
      request.response.close();
      return;
    }

    final file = File(currentVideoPath!);
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"Video file not found"}');
      request.response.close();
      return;
    }

    try {
      final tracks = await SubtitleExtractService.extractTracks(currentVideoPath!);
      
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.set('Content-Type', 'application/json');
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.write(jsonEncode(tracks));
      await request.response.close();
    } catch (e) {
      debugPrint('❌ Error extracting tracks: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"Failed to extract tracks: $e"}');
      await request.response.close();
    }
  }

  Future<void> _serveEmbeddedSubtitleStream(HttpRequest request, String trackParam) async {
    if (currentVideoPath == null) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"No video loaded"}');
      await request.response.close();
      return;
    }

    final trackIndex = int.tryParse(trackParam);
    if (trackIndex == null) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{"error":"Invalid track parameter"}');
      await request.response.close();
      return;
    }

    debugPrint('📝 Extracting subtitle track $trackIndex from: $currentVideoPath');

    try {
      String? ffmpegPath;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final desktopService = FFmpegServiceDesktop();
        ffmpegPath = await desktopService.getFFmpegPathForStreaming();
      }
      
      if (ffmpegPath == null) {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write('{"error":"FFmpeg not found"}');
        await request.response.close();
        return;
      }

      final response = request.response;
      response.statusCode = HttpStatus.ok;
      response.headers.set('Content-Type', 'text/vtt; charset=utf-8');
      response.headers.set('Access-Control-Allow-Origin', '*');
      response.headers.set('Cache-Control', 'no-cache');

      if (request.method == 'OPTIONS' || request.method == 'HEAD') {
        await response.close();
        return;
      }

      final process = await Process.start(
        ffmpegPath,
        [
          '-i', currentVideoPath!,
          '-map', '0:s:$trackIndex',
          '-f', 'webvtt',
          'pipe:1',
        ],
      );

      await process.stdout.pipe(response);
      
      final exitCode = await process.exitCode;
      debugPrint('📝 FFmpeg subtitle extraction completed with exit code: $exitCode');
      
    } catch (e, stack) {
      debugPrint('❌ Error serving embedded subtitle stream: $e');
      debugPrint('Stack: $stack');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.headers.contentType = ContentType.json;
        request.response.write('{"error":"$e"}');
        await request.response.close();
      } catch (_) {}
    }
  }
}
