import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../domain/entities/account.dart';

class SettingsItemWidget extends StatelessWidget {
  final SettingsItem item;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  const SettingsItemWidget({
    super.key,
    required this.item,
    this.onToggleChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SakuCard(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      borderRadius: 14,
      onTap: item.isToggle ? null : onTap,
      child: Row(
        children: [
          // Icon
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: item.iconColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _getIconData(item.iconPath),
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          // Status or toggle
          if (item.status != null)
            Text(
              item.status!,
              style: TextStyle(
                color: const Color(0xFF10B981),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (item.status != null) SizedBox(width: 8.w),
          if (item.isToggle)
            Switch(
              value: item.toggleValue,
              onChanged: onToggleChanged,
              activeTrackColor: const Color(0xFF8A2BE2),
            )
          else
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 14.sp,
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'categories':
        return Icons.grid_view_rounded;
      case 'security':
        return Icons.shield_rounded;
      case 'export':
        return Icons.file_download_rounded;
      case 'backup':
        return Icons.cloud_sync_rounded;
      case 'language':
        return Icons.translate_rounded;
      case 'theme':
        return Icons.palette_rounded;
      case 'import':
        return Icons.file_upload_rounded;
      case 'notification':
        return Icons.notifications_rounded;
      case 'share':
        return Icons.share_rounded;
      case 'about':
        return Icons.info_rounded;
      default:
        return Icons.settings_rounded;
    }
  }
}
