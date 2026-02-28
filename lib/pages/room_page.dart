import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/room_provider.dart';
import '../models/room_model.dart';
import 'player_room_page.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoomContent();
  }
}

class RoomContent extends StatefulWidget {
  const RoomContent({super.key});

  @override
  State<RoomContent> createState() => _RoomContentState();
}

class _RoomContentState extends State<RoomContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  Future<void> _startScanning() async {
    final roomProvider = context.read<RoomProvider>();
    if (!roomProvider.isScanning) {
      await roomProvider.startScanning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: const Text('房间'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                final roomProvider = context.read<RoomProvider>();
                await roomProvider.stopScanning();
                await roomProvider.startScanning();
              },
              tooltip: '刷新房间列表',
            ),
          ],
        ),
        Expanded(
          child: Consumer<RoomProvider>(
            builder: (context, roomProvider, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1200) {
                    return _buildDesktopLayout(context, colorScheme, roomProvider);
                  } else if (constraints.maxWidth >= 600) {
                    return _buildTabletLayout(context, colorScheme, roomProvider);
                  } else {
                    return _buildMobileLayout(context, colorScheme, roomProvider);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: _buildActionButtons(context, colorScheme, roomProvider),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: _buildRoomList(context, colorScheme, roomProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [
                _buildActionButtons(context, colorScheme, roomProvider),
                const SizedBox(height: AppTheme.spacingL),
                _buildScanningStatus(context, colorScheme, roomProvider),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: _buildRoomList(context, colorScheme, roomProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Column(
              children: [
                _buildActionButtons(context, colorScheme, roomProvider),
                const SizedBox(height: AppTheme.spacingL),
                _buildScanningStatus(context, colorScheme, roomProvider),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingXL),
          Expanded(
            child: _buildRoomList(context, colorScheme, roomProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Column(
      children: [
        _buildActionCard(
          context,
          colorScheme,
          icon: Icons.add_circle_outline,
          title: '创建房间',
          subtitle: '作为房主',
          color: colorScheme.primaryContainer,
          iconColor: colorScheme.onPrimaryContainer,
          onTap: () => _showCreateRoomDialog(context, roomProvider),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _buildActionCard(
          context,
          colorScheme,
          icon: Icons.login,
          title: '进入房间',
          subtitle: '手动输入地址',
          color: colorScheme.secondaryContainer,
          iconColor: colorScheme.onSecondaryContainer,
          onTap: () => _showManualConnectDialog(context, roomProvider),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningStatus(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            if (roomProvider.isScanning)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.wifi_off,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              roomProvider.isScanning ? '正在扫描局域网...' : '扫描已停止',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    // 显示错误状态
    if (roomProvider.error != null) {
      return _buildErrorState(context, colorScheme, roomProvider);
    }
    
    final rooms = roomProvider.discoveredRooms;

    if (rooms.isEmpty) {
      return _buildEmptyState(context, colorScheme, roomProvider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Row(
            children: [
              Text(
                '发现的房间',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  '${rooms.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingS),
            itemBuilder: (context, index) {
              return _buildRoomCard(context, colorScheme, roomProvider, rooms[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                '扫描出错',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                roomProvider.error ?? '未知错误',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              FilledButton.icon(
                onPressed: () async {
                  await roomProvider.stopScanning();
                  await roomProvider.startScanning();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, RoomProvider roomProvider) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (roomProvider.isScanning) ...[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  '正在扫描局域网房间...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  '请确保房主已创建房间且在同一局域网下',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  '未发现可用房间',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  '请确保房主已创建房间，或手动输入地址',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                FilledButton.icon(
                  onPressed: () => roomProvider.startScanning(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新扫描'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    ColorScheme colorScheme,
    RoomProvider roomProvider,
    RoomModel room,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () => _joinRoom(context, roomProvider, room),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(
                  Icons.play_circle_outline,
                  color: colorScheme.onTertiaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.hostName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Icon(
                          Icons.devices,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          room.displayAddress,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinRoom(
    BuildContext context,
    RoomProvider roomProvider,
    RoomModel room,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('加入房间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('房间名称: ${room.name}'),
            Text('房主: ${room.hostName}'),
            Text('地址: ${room.displayAddress}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('加入'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await roomProvider.joinRoom(room);
      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerRoomPage(
              isHost: false,
              hostIp: room.ipAddress,
              port: room.port,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showCreateRoomDialog(BuildContext context, RoomProvider roomProvider) async {
    final roomNameController = TextEditingController();
    final portController = TextEditingController(text: '37670');
    List<String> videoPaths = [];
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('创建房间'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: roomNameController,
                    decoration: const InputDecoration(
                      labelText: '房间名称',
                      hintText: '输入房间名称',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    validator: RoomProvider.validateRoomName,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextFormField(
                    controller: portController,
                    decoration: const InputDecoration(
                      labelText: '端口号',
                      hintText: '默认 37670',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: RoomProvider.validatePort,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ListTile(
                    leading: Icon(
                      videoPaths.isNotEmpty ? Icons.video_file : Icons.video_library,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      videoPaths.isNotEmpty
                          ? '已选择 ${videoPaths.length} 个视频'
                          : '选择视频文件',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: videoPaths.isNotEmpty
                        ? Text(videoPaths.first.split(Platform.pathSeparator).last)
                        : const Text('可选，支持多选'),
                    trailing: const Icon(Icons.folder_open),
                    onTap: () async {
                      final paths = await roomProvider.pickVideoFiles();
                      if (paths.isNotEmpty) {
                        setState(() {
                          videoPaths = paths;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  
                  final success = await roomProvider.createRoom(
                    roomName: roomNameController.text.trim(),
                    port: int.parse(portController.text.trim()),
                  );

                  if (mounted) {
                    if (success) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerRoomPage(
                            videoPath: videoPaths.isNotEmpty ? videoPaths.first : null,
                            initialVideoPaths: videoPaths,
                            isHost: true,
                            port: int.parse(portController.text.trim()),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(roomProvider.error ?? '创建房间失败')),
                      );
                    }
                  }
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    roomNameController.dispose();
    portController.dispose();
  }

  Future<void> _showManualConnectDialog(BuildContext context, RoomProvider roomProvider) async {
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '37670');
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('手动连接'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP地址',
                      hintText: '例如: 192.168.1.100',
                      prefixIcon: Icon(Icons.computer),
                    ),
                    validator: RoomProvider.validateIpAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextFormField(
                    controller: portController,
                    decoration: const InputDecoration(
                      labelText: '端口号',
                      hintText: '默认 37670',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: RoomProvider.validatePort,
                    enabled: !isLoading,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isLoading) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: AppTheme.spacingS),
                        Text('正在连接...'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      final ip = ipController.text.trim();
                      final port = int.parse(portController.text.trim());

                      try {
                        final result = await roomProvider.testConnection(
                          ipAddress: ip,
                          port: port,
                        ).timeout(
                          const Duration(seconds: 10),
                          onTimeout: () => ConnectionTestResult(
                            success: false,
                            error: '连接超时，请检查IP地址和网络连接',
                          ),
                        );

                        if (!dialogContext.mounted) return;

                        if (result.success) {
                          Navigator.pop(dialogContext);

                          final success = await roomProvider.joinRoomByAddress(
                            ipAddress: ip,
                            port: port,
                          );

                          if (context.mounted) {
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerRoomPage(
                                    isHost: false,
                                    hostIp: ip,
                                    port: port,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(roomProvider.error ?? '加入房间失败'),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        } else {
                          setState(() {
                            isLoading = false;
                            errorMessage = result.error ?? '连接失败';
                          });
                        }
                      } catch (e) {
                        if (!dialogContext.mounted) return;
                        setState(() {
                          isLoading = false;
                          errorMessage = '连接异常: ${e.toString()}';
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('连接'),
            ),
          ],
        ),
      ),
    );

    ipController.dispose();
    portController.dispose();
  }
}
