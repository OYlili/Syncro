import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/player_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/subtitle_style_provider.dart';
import '../providers/subtitle_provider.dart';
import '../providers/audio_track_provider.dart';

class TrackSettingsBottomSheet extends StatelessWidget {
  const TrackSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 500,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.audiotrack), text: '音轨'),
                    Tab(icon: Icon(Icons.subtitles), text: '字幕'),
                    Tab(icon: Icon(Icons.palette), text: '样式'),
                  ],
                  labelStyle: TextStyle(fontSize: 14),
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerHeight: 1,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AudioTrackTab(),
                      _SubtitleTrackTab(),
                      _SubtitleStyleTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    final playerProvider = context.read<PlayerProvider>();
    final syncProvider = context.read<SyncProvider>();
    final subtitleStyleProvider = context.read<SubtitleStyleProvider>();
    final subtitleProvider = context.read<SubtitleProvider>();
    final audioTrackProvider = context.read<AudioTrackProvider>();
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: playerProvider),
          ChangeNotifierProvider.value(value: syncProvider),
          ChangeNotifierProvider.value(value: subtitleStyleProvider),
          ChangeNotifierProvider.value(value: subtitleProvider),
          ChangeNotifierProvider.value(value: audioTrackProvider),
        ],
        child: const TrackSettingsBottomSheet(),
      ),
    );
  }
}

class _AudioTrackTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, AudioTrackProvider>(
      builder: (context, playerProvider, audioTrackProvider, _) {
        final player = playerProvider.player;
        final syncProvider = context.read<SyncProvider>();
        
        if (player == null) {
          return _buildEmptyState(context, Icons.error_outline, '播放器未初始化');
        }
        
        final tracks = audioTrackProvider.tracks;
        final currentTrackId = audioTrackProvider.currentTrackId;
        
        if (tracks.isEmpty) {
          return _buildEmptyState(context, Icons.audiotrack_outlined, '暂无可用音轨');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final isSelected = currentTrackId != null && track.id == currentTrackId;
            
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
              ),
              title: Text(_getTrackTitle(track, index)),
              selected: isSelected,
              onTap: () async {
                await audioTrackProvider.selectTrack(track.id);
                syncProvider.broadcastAudioSelect(track.id);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }

  String _getTrackTitle(AudioTrack track, int index) {
    if (track.title != null && track.title!.isNotEmpty) return track.title!;
    if (track.language != null && track.language!.isNotEmpty) {
      return '音轨 ${index + 1} (${_getLanguageName(track.language!)})';
    }
    return '音轨 ${index + 1}';
  }

  String _getLanguageName(String code) {
    const map = {
      'chi': '中文', 'zho': '中文', 'zh': '中文', 'eng': '英语', 'en': '英语',
      'jpn': '日语', 'ja': '日语', 'kor': '韩语', 'ko': '韩语',
    };
    return map[code.toLowerCase()] ?? code.toUpperCase();
  }
}

class _SubtitleTrackTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerProvider, SyncProvider, SubtitleProvider>(
      builder: (context, playerProvider, syncProvider, subtitleProvider, _) {
        final player = playerProvider.player;
        
        if (player == null) {
          return _buildEmptyState(context, Icons.error_outline, '播放器未初始化');
        }
        
        final tracks = subtitleProvider.tracks;
        final currentTrackId = subtitleProvider.currentTrackId;
        final lastActiveTrackId = subtitleProvider.lastActiveTrackId;
        final isSubtitleOff = currentTrackId == 'off' || currentTrackId == null;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (syncProvider.isHost) ...[
              _buildExternalSubtitleSection(context, syncProvider, subtitleProvider),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
            ],
            Text('内嵌字幕', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                isSubtitleOff
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(isSubtitleOff && lastActiveTrackId != null 
                  ? '恢复字幕' 
                  : '关闭字幕'),
              onTap: () async {
                if (isSubtitleOff && lastActiveTrackId != null) {
                  await subtitleProvider.restoreLastSubtitle();
                  syncProvider.broadcastSubtitleSelect(lastActiveTrackId!);
                } else {
                  await subtitleProvider.disableSubtitle();
                  syncProvider.broadcastSubtitleSelect('off');
                }
                Navigator.of(context).pop();
              },
            ),
            if (tracks.isEmpty)
              _buildEmptyState(context, Icons.subtitles_outlined, '暂无内嵌字幕')
            else
              ...tracks.asMap().entries.map((entry) {
                final track = entry.value;
                final isSelected = currentTrackId != null && track.id == currentTrackId;
                
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(_getTrackTitle(track, entry.key)),
                  selected: isSelected,
                  onTap: () async {
                    await subtitleProvider.selectTrack(track.id);
                    syncProvider.broadcastSubtitleSelect(track.id);
                    Navigator.of(context).pop();
                  },
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildExternalSubtitleSection(BuildContext context, SyncProvider syncProvider, SubtitleProvider subtitleProvider) {
    final hasExternalSub = syncProvider.externalSubtitlePath != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('外挂字幕（房主专属）', style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            )),
          ],
        ),
        const SizedBox(height: 8),
        if (hasExternalSub)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.subtitles, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncProvider.externalSubtitlePath!.split(Platform.pathSeparator).last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => syncProvider.clearExternalSubtitle(),
                ),
              ],
            ),
          )
        else
          FilledButton.tonalIcon(
            icon: const Icon(Icons.add),
            label: const Text('加载外挂字幕'),
            onPressed: () => _loadExternalSubtitle(context, syncProvider),
          ),
      ],
    );
  }

  Future<void> _loadExternalSubtitle(BuildContext context, SyncProvider syncProvider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'sub'],
    );
    
    if (result != null && result.files.first.path != null) {
      await syncProvider.loadExternalSubtitle(result.files.first.path!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('外挂字幕已同步到所有成员')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }

  String _getTrackTitle(SubtitleTrack track, int index) {
    if (track.title != null && track.title!.isNotEmpty) return track.title!;
    if (track.language != null && track.language!.isNotEmpty) {
      return '字幕 ${index + 1} (${_getLanguageName(track.language!)})';
    }
    return '字幕 ${index + 1}';
  }

  String _getLanguageName(String code) {
    const map = {
      'chi': '中文', 'zho': '中文', 'zh': '中文', 'eng': '英语', 'en': '英语',
      'jpn': '日语', 'ja': '日语', 'kor': '韩语', 'ko': '韩语',
    };
    return map[code.toLowerCase()] ?? code.toUpperCase();
  }
}

class _SubtitleStyleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubtitleStyleProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSlider(context, '字体大小', provider.fontSize, 16, 48, provider.setFontSize),
              const SizedBox(height: 16),
              _buildColorSection(context, provider),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.layers, size: 18),
                  const SizedBox(width: 8),
                  const Text('显示背景框'),
                  const Spacer(),
                  Switch(value: provider.showBackground, onChanged: provider.setShowBackground),
                ],
              ),
              const SizedBox(height: 16),
              _buildSlider(context, '不透明度', provider.opacity, 0.3, 1.0, provider.setOpacity, isPercentage: true),
              const SizedBox(height: 16),
              _buildPreview(context, provider),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('恢复默认'),
                  onPressed: provider.reset,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value, double min, double max, Function(double) onChanged, {bool isPercentage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isPercentage ? '${(value * 100).toInt()}%' : value.toInt().toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, divisions: 16, onChanged: onChanged),
      ],
    );
  }

  Widget _buildColorSection(BuildContext context, SubtitleStyleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('字体颜色'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: SubtitleColor.values.map((color) {
            final isSelected = provider.color == color;
            final colorValue = _getColorValue(color);
            
            return GestureDetector(
              onTap: () => provider.setColor(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white24,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected ? Icon(Icons.check, color: colorValue.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, SubtitleStyleProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('预览效果'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Container(
            padding: provider.showBackground ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
            decoration: provider.showBackground ? BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6 * provider.opacity),
              borderRadius: BorderRadius.circular(4),
            ) : null,
            child: Text(
              '字幕预览效果',
              style: TextStyle(
                color: provider.textColor.withValues(alpha: provider.opacity),
                fontSize: provider.fontSize * 0.5,
                fontWeight: FontWeight.w500,
                shadows: provider.showBackground ? null : const [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorValue(SubtitleColor color) {
    switch (color) {
      case SubtitleColor.white: return Colors.white;
      case SubtitleColor.yellow: return const Color(0xFFFFFF00);
      case SubtitleColor.green: return const Color(0xFF00FF00);
      case SubtitleColor.cyan: return const Color(0xFF00FFFF);
    }
  }
}
