import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/danmaku_settings.dart';
import '../providers/danmaku_settings_provider.dart';

class DanmakuStylePicker extends StatelessWidget {
  const DanmakuStylePicker({super.key});

  static const List<DanmakuColor> _displayColors = [
    DanmakuColor.white,
    DanmakuColor.red,
    DanmakuColor.orange,
    DanmakuColor.yellow,
    DanmakuColor.green,
    DanmakuColor.cyan,
    DanmakuColor.blue,
    DanmakuColor.purple,
    DanmakuColor.pink,
  ];

  static int getColorValue(DanmakuColor color) {
    switch (color) {
      case DanmakuColor.white:
        return 0xFFFFFFFF;
      case DanmakuColor.red:
        return 0xFFFF0000;
      case DanmakuColor.orange:
        return 0xFFFFA500;
      case DanmakuColor.yellow:
        return 0xFFFFFF00;
      case DanmakuColor.green:
        return 0xFF00FF00;
      case DanmakuColor.cyan:
        return 0xFF00FFFF;
      case DanmakuColor.blue:
        return 0xFF0000FF;
      case DanmakuColor.purple:
        return 0xFF800080;
      case DanmakuColor.pink:
        return 0xFFFFC0CB;
    }
  }

  static String _getPositionLabel(DanmakuPosition position) {
    switch (position) {
      case DanmakuPosition.scroll:
        return '滚动';
      case DanmakuPosition.topFixed:
        return '顶部';
      case DanmakuPosition.bottomFixed:
        return '底部';
    }
  }

  static IconData _getPositionIcon(DanmakuPosition position) {
    switch (position) {
      case DanmakuPosition.scroll:
        return Icons.swap_horiz;
      case DanmakuPosition.topFixed:
        return Icons.arrow_upward;
      case DanmakuPosition.bottomFixed:
        return Icons.arrow_downward;
    }
  }

  static Future<void> showPickerDialog(BuildContext context) async {
    final danmakuSettingsProvider = context.read<DanmakuSettingsProvider>();
    
    await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: danmakuSettingsProvider,
        child: const _DanmakuStyleDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, settings, child) {
        return GestureDetector(
          onTap: () => showPickerDialog(context),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(settings.sendColorValue),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.palette,
              size: 16,
              color: settings.sendColor == DanmakuColor.white 
                  ? Colors.black54 
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
        );
      },
    );
  }
}

class _DanmakuStyleDialog extends StatelessWidget {
  const _DanmakuStyleDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 16),
            _buildColorSection(context),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 16),
            _buildPositionSection(context),
            const SizedBox(height: 16),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.palette,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '弹幕样式',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection(BuildContext context) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '弹幕颜色',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: DanmakuStylePicker._displayColors.map((color) {
                final isSelected = settings.sendColor == color;
                final colorValue = DanmakuStylePicker.getColorValue(color);
                
                return GestureDetector(
                  onTap: () {
                    settings.setSendColor(color);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(colorValue).withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: Color(colorValue).computeLuminance() > 0.5 
                                ? Colors.black 
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPositionSection(BuildContext context) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, settings, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '弹幕位置',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: DanmakuPosition.values.map((position) {
                final isSelected = settings.sendPosition == position;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      settings.setSendPosition(position);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            DanmakuStylePicker._getPositionIcon(position),
                            size: 18,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DanmakuStylePicker._getPositionLabel(position),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white54,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
        ),
        child: const Text('关闭'),
      ),
    );
  }
}
