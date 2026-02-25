import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/playlist.dart';
import '../providers/sync_provider.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, sync, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildHeader(context, sync),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlaylistSection(context, sync),
                      const SizedBox(height: 16),
                      _buildSubtitleSection(context, sync),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SyncProvider sync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.playlist_play,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '播放列表',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (sync.isHost && sync.playlist.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              onPressed: () => _showClearPlaylistDialog(context, sync),
              tooltip: '清除列表',
            ),
          if (sync.isHost)
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加'),
              onPressed: () => _addVideos(context, sync),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaylistSection(BuildContext context, SyncProvider sync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              '视频列表',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (sync.playlist.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${sync.playlist.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (sync.playlist.isEmpty)
          _buildEmptyPlaylistState(context, sync)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sync.playlist.items.length,
            itemBuilder: (context, index) {
              final item = sync.playlist.items[index];
              final isPlaying = index == sync.playlist.currentIndex;
              
              return _PlaylistItemTile(
                item: item,
                index: index,
                isPlaying: isPlaying,
                canSwitch: sync.isHost,
                onTap: () => _switchEpisode(context, sync, index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyPlaylistState(BuildContext context, SyncProvider sync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              '播放列表为空',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (sync.isHost) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _addVideos(context, sync),
                child: const Text('添加视频'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleSection(BuildContext context, SyncProvider sync) {
    final hasSubtitle = sync.externalSubtitlePath != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.subtitles_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              '外挂字幕',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (hasSubtitle)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '已加载',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasSubtitle) ...[
                      Text(
                        sync.externalSubtitlePath!.split(Platform.pathSeparator).last,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '所有房间成员将自动加载此字幕',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ] else
                      Text(
                        sync.isHost ? '可选择 .srt 或 .ass 字幕文件' : '房主未加载外挂字幕',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              if (sync.isHost) ...[
                if (hasSubtitle)
                  IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    onPressed: () => sync.clearExternalSubtitle(),
                    tooltip: '清除字幕',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                    onPressed: () => _addSubtitle(context, sync),
                    tooltip: '添加字幕',
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addVideos(BuildContext context, SyncProvider sync) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final paths = result.paths.whereType<String>().toList();
        debugPrint('Selected ${paths.length} videos');
        if (paths.isNotEmpty) {
          if (sync.playlist.isEmpty) {
            await sync.setPlaylist(paths);
          } else {
            await sync.addFiles(paths);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking videos: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e')),
        );
      }
    }
  }

  Future<void> _showClearPlaylistDialog(BuildContext context, SyncProvider sync) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清除播放列表', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要清除全部视频吗？此操作不可恢复。',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await sync.clearPlaylist();
    }
  }

  Future<void> _addSubtitle(BuildContext context, SyncProvider sync) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'ass', 'ssa', 'sub'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        await sync.loadExternalSubtitle(path);
      }
    }
  }

  Future<void> _switchEpisode(BuildContext context, SyncProvider sync, int index) async {
    if (!sync.isHost) return;
    await sync.switchToEpisode(index);
  }
}

class _PlaylistItemTile extends StatelessWidget {
  final PlaylistItem item;
  final int index;
  final bool isPlaying;
  final bool canSwitch;
  final VoidCallback onTap;

  const _PlaylistItemTile({
    required this.item,
    required this.index,
    required this.isPlaying,
    required this.canSwitch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: isPlaying 
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: canSwitch ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isPlaying 
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: isPlaying
                      ? Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: colorScheme.onPrimary,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                        color: isPlaying ? colorScheme.primary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.duration > 0)
                      Text(
                        _formatDuration(item.duration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              if (canSwitch && !isPlaying)
                Icon(
                  Icons.play_circle_outline,
                  size: 20,
                  color: colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
