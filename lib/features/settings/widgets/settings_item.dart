import 'package:flutter/material.dart';
import '../../../../domain/entities/account.dart';

class SettingsItemWidget extends StatelessWidget {
  final SettingsItem item;
  final ValueChanged<bool>? onToggleChanged;

  const SettingsItemWidget({
    super.key,
    required this.item,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(color: colorScheme.outline.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(item.iconPath),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Status or toggle
          if (item.status != null)
            Text(
              item.status!,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (item.status != null) const SizedBox(width: 8),
          if (item.isToggle)
            Switch(
              value: item.toggleValue,
              onChanged: onToggleChanged,
              activeTrackColor: const Color(0xFF8A2BE2),
            )
          else
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'categories':
        return Icons.category;
      case 'security':
        return Icons.security;
      case 'export':
        return Icons.download;
      case 'backup':
        return Icons.backup;
      case 'language':
        return Icons.language;
      case 'theme':
        return Icons.palette;
      case 'import':
        return Icons.file_upload;
      case 'notification':
        return Icons.notifications;
      case 'share':
        return Icons.share;
      case 'about':
        return Icons.info;
      default:
        return Icons.settings;
    }
  }
}
