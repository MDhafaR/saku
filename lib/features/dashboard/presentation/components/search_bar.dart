import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final bool hasActiveFilter;

  const SearchBar({
    super.key,
    this.hintText = 'Search transactions...',
    this.onFilterTap,
    this.onChanged,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Glassy dark: putih 6% opacity + border putih halus
    // Light: solid abu‑abu netral + border subtle
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF1F5F9);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFCBD5E1);

    // Warna filter aktif: putih lembut di dark, biru di light
    final activeFilterColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF2563EB);

    // Dot indikator filter aktif
    final activeDotColor = isDark
        ? const Color(0xFF94A3B8) // Slate‑400 — subtle, tidak teriak
        : const Color(0xFF2563EB);

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search,
            color: cs.onSurface.withValues(alpha: 0.35),
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.35),
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 2.h),
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          if (onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: hasActiveFilter
                          ? activeFilterColor
                          : cs.onSurface.withValues(alpha: 0.35),
                      size: 18.sp,
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        right: -2.w,
                        top: -2.h,
                        child: Container(
                          width: 7.w,
                          height: 7.h,
                          decoration: BoxDecoration(
                            color: activeDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
