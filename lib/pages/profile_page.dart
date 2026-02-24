import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../themes/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/statistics_provider.dart';
import '../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileContent();
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = context.read<UserProvider>();
    _nicknameController.text = userProvider.displayName;
    _selectedAvatarPath = userProvider.avatarPath;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedAvatarPath = pickedFile.path;
        });
        
        final userProvider = context.read<UserProvider>();
        await userProvider.updateAvatar(pickedFile.path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像已更新')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择头像失败: $e')),
        );
      }
    }
  }

  Future<void> _saveNickname() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateNickname(_nicknameController.text);

    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('昵称已保存')),
        );
      } else if (userProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userProvider.error!)),
        );
      }
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    final userProvider = context.read<UserProvider>();
    _nicknameController.text = userProvider.displayName;
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: const Text('我的'),
        ),
        Expanded(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1200) {
                    return _buildDesktopLayout(context, colorScheme, userProvider);
                  } else if (constraints.maxWidth >= 600) {
                    return _buildTabletLayout(context, colorScheme, userProvider);
                  } else {
                    return _buildMobileLayout(context, colorScheme, userProvider);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          _buildProfileHeader(context, colorScheme, userProvider),
          const SizedBox(height: AppTheme.spacingL),
          _buildStatsSection(context, colorScheme),
          const SizedBox(height: AppTheme.spacingL),
          _buildRecentActivity(context, colorScheme, shrinkWrap: true),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 280,
            child: _buildProfileHeader(context, colorScheme, userProvider),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              children: [
                _buildStatsSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildRecentActivity(context, colorScheme, shrinkWrap: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: _buildProfileHeader(context, colorScheme, userProvider),
          ),
          const SizedBox(width: AppTheme.spacingXL),
          Expanded(
            child: Column(
              children: [
                _buildStatsSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildRecentActivity(context, colorScheme, shrinkWrap: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            _buildAvatar(context, colorScheme, userProvider),
            const SizedBox(height: AppTheme.spacingM),
            _buildNicknameSection(context, colorScheme, userProvider),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '点击头像更换',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    final avatarPath = _selectedAvatarPath ?? userProvider.avatarPath;

    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: avatarPath != null
                  ? Image.file(
                      File(avatarPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.onPrimaryContainer,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: colorScheme.onPrimaryContainer,
                    ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameSection(BuildContext context, ColorScheme colorScheme, UserProvider userProvider) {
    if (_isEditing) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nicknameController,
              textAlign: TextAlign.center,
              maxLength: UserModel.maxNicknameLength,
              decoration: InputDecoration(
                hintText: '输入昵称',
                counterText: '${_nicknameController.text.length}/${UserModel.maxNicknameLength}',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
              ),
              validator: UserModel.validateNickname,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('取消'),
                ),
                const SizedBox(width: AppTheme.spacingS),
                FilledButton(
                  onPressed: _saveNickname,
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          userProvider.displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextButton.icon(
          onPressed: _startEditing,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('编辑昵称'),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, ColorScheme colorScheme) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return Row(
            children: [
              Expanded(child: _buildStatCard(context, colorScheme, Icons.movie, '观看时长', '...')),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(child: _buildStatCard(context, colorScheme, Icons.group, '加入房间', '...')),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(child: _buildStatCard(context, colorScheme, Icons.play_circle, '观看视频', '...')),
            ],
          );
        }
        
        final stats = statsProvider.statistics;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                colorScheme,
                Icons.movie,
                '观看时长',
                stats.formattedWatchDurationShort,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                colorScheme,
                Icons.group,
                '加入房间',
                '${stats.roomJoinCount} 次',
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                colorScheme,
                Icons.play_circle,
                '观看视频',
                '${stats.videoWatchCount} 个',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, ColorScheme colorScheme, {bool shrinkWrap = false}) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        final activities = statsProvider.recentActivities;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '最近活动',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (activities.isNotEmpty)
                      TextButton(
                        onPressed: () => _showClearActivitiesDialog(context, statsProvider),
                        child: const Text('清除'),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            '暂无活动记录',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: shrinkWrap,
                    physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
                    itemCount: activities.length > 10 ? 10 : activities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityItem(context, colorScheme, activities[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearActivitiesDialog(BuildContext context, StatisticsProvider statsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除统计数据'),
        content: const Text('确定要清除所有统计数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              statsProvider.clearStatistics();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    ColorScheme colorScheme,
    String activity,
  ) {
    IconData icon;
    Color iconColor;
    
    if (activity.contains('观看')) {
      icon = Icons.play_circle_outline;
      iconColor = colorScheme.primary;
    } else if (activity.contains('房间')) {
      icon = Icons.group;
      iconColor = colorScheme.secondary;
    } else if (activity.contains('创建')) {
      icon = Icons.add_circle_outline;
      iconColor = colorScheme.tertiary;
    } else {
      icon = Icons.history;
      iconColor = colorScheme.outline;
    }
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(activity),
    );
  }
}
