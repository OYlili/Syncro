import 'dart:io';
import 'ffmpeg_service.dart';
import 'ffmpeg_service_desktop.dart';
import 'ffmpeg_service_mobile.dart';

class FFmpegServiceFactory {
  static FFmpegService create() {
    if (Platform.isAndroid || Platform.isIOS) {
      return FFmpegServiceMobile();
    } else {
      return FFmpegServiceDesktop();
    }
  }
}
