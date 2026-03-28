import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonthNavigation extends StatelessWidget {
  final String currentMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onMonthTap;

  const MonthNavigation({
    super.key,
    required this.currentMonth,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBtnColor = isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPreviousMonth,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: navBtnColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_left,
                color: cs.onSurface.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: onMonthTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  Text(
                    currentMonth,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurface,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onNextMonth,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: navBtnColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
