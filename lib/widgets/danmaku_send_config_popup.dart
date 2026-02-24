import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/danmaku_settings.dart';
import '../providers/danmaku_settings_provider.dart';

class DanmakuSendConfigPopup extends StatelessWidget {
  const DanmakuSendConfigPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DanmakuSettingsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '弹幕颜色',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              _buildColorSelector(context, provider),
              const SizedBox(height: 12),
              Text(
                '弹幕位置',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              _buildPositionSelector(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSelector(BuildContext context, DanmakuSettingsProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DanmakuColor.values.map((color) {
        final isSelected = provider.sendColor == color;
        return GestureDetector(
          onTap: () => provider.setSendColor(color),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(DanmakuSendConfig(color: color).colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                ),
              ],
            ),
            child: isSelected 
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPositionSelector(BuildContext context, DanmakuSettingsProvider provider) {
    return Row(
      children: DanmakuPosition.values.map((position) {
        final isSelected = provider.sendPosition == position;
        final label = _getPositionLabel(position);
        final icon = _getPositionIcon(position);
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: position != DanmakuPosition.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => provider.setSendPosition(position),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white24,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPositionLabel(DanmakuPosition position) {
    switch (position) {
      case DanmakuPosition.scroll:
        return '滚动';
      case DanmakuPosition.topFixed:
        return '顶端';
      case DanmakuPosition.bottomFixed:
        return '底端';
    }
  }

  IconData _getPositionIcon(DanmakuPosition position) {
    switch (position) {
      case DanmakuPosition.scroll:
        return Icons.swap_horiz;
      case DanmakuPosition.topFixed:
        return Icons.vertical_align_top;
      case DanmakuPosition.bottomFixed:
        return Icons.vertical_align_bottom;
    }
  }

  static Future<void> show(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _DanmakuPopupOverlay(
        position: position,
        onDismiss: () => entry.remove(),
      ),
    );
    
    overlay.insert(entry);
    
    await Future.delayed(const Duration(seconds: 5));
    if (entry.mounted) {
      entry.remove();
    }
  }
}

class _DanmakuPopupOverlay extends StatefulWidget {
  final Offset position;
  final VoidCallback onDismiss;

  const _DanmakuPopupOverlay({
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_DanmakuPopupOverlay> createState() => _DanmakuPopupOverlayState();
}

class _DanmakuPopupOverlayState extends State<_DanmakuPopupOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: widget.position.dx,
              bottom: MediaQuery.of(context).size.height - widget.position.dy,
              child: GestureDetector(
                onTap: () {},
                child: const DanmakuSendConfigPopup(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
