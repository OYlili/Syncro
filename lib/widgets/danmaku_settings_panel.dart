import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/danmaku_settings.dart';
import '../providers/danmaku_settings_provider.dart';

class DanmakuSettingsPanel extends StatelessWidget {
  const DanmakuSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isDark),
              Divider(
                color: isDark ? Colors.white24 : Colors.black12, 
                height: 1
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSwitchTile(
                        context,
                        isDark,
                        title: '显示弹幕',
                        subtitle: provider.isEnabled ? '已开启' : '已关闭',
                        value: provider.isEnabled,
                        onChanged: provider.setEnabled,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, isDark, '弹幕速度'),
                      _buildSpeedSelector(context, isDark, provider),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, isDark, '不透明度'),
                      _buildOpacitySlider(context, isDark, provider),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, isDark, '显示区域'),
                      _buildAreaSelector(context, isDark, provider),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, isDark, '字体大小'),
                      _buildFontSizeSlider(context, isDark, provider),
                      const SizedBox(height: 24),
                      _buildResetButton(context, isDark, provider),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '弹幕显示设置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white70 : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, 
    bool isDark, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black45;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildSpeedSelector(BuildContext context, bool isDark, DanmakuSettingsProvider provider) {
    return Row(
      children: DanmakuSpeed.values.map((speed) {
        final isSelected = provider.globalConfig.speed == speed;
        final label = _getSpeedLabel(speed);
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: speed != DanmakuSpeed.values.last ? 8 : 0,
            ),
            child: _buildOptionButton(
              context,
              isDark,
              label: label,
              isSelected: isSelected,
              onTap: () => provider.setSpeed(speed),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getSpeedLabel(DanmakuSpeed speed) {
    switch (speed) {
      case DanmakuSpeed.slow:
        return '慢速 0.5x';
      case DanmakuSpeed.normal:
        return '正常 1.0x';
      case DanmakuSpeed.fast:
        return '快速 1.5x';
    }
  }

  Widget _buildOpacitySlider(BuildContext context, bool isDark, DanmakuSettingsProvider provider) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: provider.opacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: provider.setOpacity,
                ),
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                '${(provider.opacity * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAreaSelector(BuildContext context, bool isDark, DanmakuSettingsProvider provider) {
    return Row(
      children: DanmakuArea.values.map((area) {
        final isSelected = provider.globalConfig.area == area;
        final label = _getAreaLabel(area);
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: area != DanmakuArea.values.last ? 8 : 0,
            ),
            child: _buildOptionButton(
              context,
              isDark,
              label: label,
              isSelected: isSelected,
              onTap: () => provider.setArea(area),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getAreaLabel(DanmakuArea area) {
    switch (area) {
      case DanmakuArea.full:
        return '全屏';
      case DanmakuArea.topHalf:
        return '上半屏';
      case DanmakuArea.bottomHalf:
        return '下半屏';
    }
  }

  Widget _buildOptionButton(
    BuildContext context, 
    bool isDark, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected 
        ? Theme.of(context).colorScheme.primary
        : isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05);
    final borderColor = isSelected 
        ? Theme.of(context).colorScheme.primary
        : isDark ? Colors.white24 : Colors.black12;
    final textColor = isSelected 
        ? Colors.white 
        : isDark ? Colors.white70 : Colors.black54;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, bool isDark, DanmakuSettingsProvider provider) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: provider.fontSize,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: provider.setFontSize,
                ),
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                '${(provider.fontSize * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, bool isDark, DanmakuSettingsProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: provider.resetGlobalConfig,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white70 : Colors.black54,
          side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('恢复默认设置'),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    final danmakuSettingsProvider = context.read<DanmakuSettingsProvider>();
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: danmakuSettingsProvider,
        child: const DanmakuSettingsPanel(),
      ),
    );
  }
}
