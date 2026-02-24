import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/app_provider.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsContent();
  }
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        AppBar(
          title: const Text('设置'),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1200) {
                return _buildDesktopLayout(context, colorScheme);
              } else if (constraints.maxWidth >= 600) {
                return _buildTabletLayout(context, colorScheme);
              } else {
                return _buildMobileLayout(context, colorScheme);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaybackSection(context, colorScheme),
          const SizedBox(height: AppTheme.spacingL),
          _buildNetworkSection(context, colorScheme),
          const SizedBox(height: AppTheme.spacingL),
          _buildAppearanceSection(context, colorScheme),
          const SizedBox(height: AppTheme.spacingL),
          _buildAboutSection(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPlaybackSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildNetworkSection(context, colorScheme),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              children: [
                _buildAppearanceSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildAboutSection(context, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPlaybackSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildNetworkSection(context, colorScheme),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingXL),
          Expanded(
            child: Column(
              children: [
                _buildAppearanceSection(context, colorScheme),
                const SizedBox(height: AppTheme.spacingL),
                _buildAboutSection(context, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlaybackSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '播放设置'),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.play_circle_outline,
                      '自动播放',
                      '自动播放下一个视频',
                      Switch(
                        value: appProvider.autoPlay,
                        onChanged: (value) {
                          appProvider.setAutoPlay(value);
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.high_quality_outlined,
                      '硬件解码',
                      '使用 GPU 加速视频解码',
                      Switch(
                        value: appProvider.hardwareDecoding,
                        onChanged: (value) {
                          appProvider.setHardwareDecoding(value);
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.volume_up_outlined,
                      '默认音量',
                      '启动时的默认音量',
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Slider(
                              value: appProvider.defaultVolume,
                              onChanged: (value) {
                                appProvider.setDefaultVolume(value);
                              },
                            ),
                          ),
                          Text('${(appProvider.defaultVolume * 100).round()}%'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '网络设置'),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.wifi_outlined,
                      '自动发现房间',
                      '局域网内自动搜索可用房间',
                      Switch(
                        value: appProvider.autoDiscovery,
                        onChanged: (value) {
                          appProvider.setAutoDiscovery(value);
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.sync_outlined,
                      '同步延迟补偿',
                      '补偿网络延迟导致的同步偏差',
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Slider(
                              value: appProvider.syncDelayCompensation,
                              min: 0,
                              max: 2000,
                              onChanged: (value) {
                                appProvider.setSyncDelayCompensation(value);
                              },
                            ),
                          ),
                          Text('${appProvider.syncDelayCompensation.round()}ms'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '外观设置'),
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return Column(
                  children: [
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.palette_outlined,
                      '动态色彩',
                      '使用系统壁纸颜色作为主题色',
                      Switch(
                        value: appProvider.dynamicColor,
                        onChanged: (value) {
                          appProvider.setDynamicColor(value);
                        },
                      ),
                    ),
                    _buildSettingsTile(
                      context,
                      colorScheme,
                      Icons.dark_mode_outlined,
                      '深色模式',
                      '跟随系统设置',
                      DropdownButton<ThemeMode>(
                        value: appProvider.themeMode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('跟随系统'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('浅色'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('深色'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            appProvider.setThemeMode(mode);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '关于'),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: _buildSettingsTile(
                context,
                colorScheme,
                Icons.info_outline,
                '关于 Syncro',
                '版本信息、开源地址',
                const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: colorScheme.onSurface,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
    );
  }
}
