class TrackInfo {
  final int id;
  final String? language;
  final String? title;
  final String? codec;

  TrackInfo({
    required this.id, this.language, this.title, this.codec});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'title': title,
      'codec': codec,
    };
  }

  factory TrackInfo.fromJson(Map<String, dynamic> json) {
    return TrackInfo(
      id: json['id'] as int,
      language: json['language'] as String?,
      title: json['title'] as String?,
      codec: json['codec'] as String?,
    );
  }
}

abstract class FFmpegService {
  Future<Map<String, List<TrackInfo>>> extractTracks(String filePath);
  Future<String> extractSubtitleToVtt(String filePath, int trackIndex, String outputDir);
}
