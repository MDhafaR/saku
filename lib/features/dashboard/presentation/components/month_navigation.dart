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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_left,
                color: Colors.grey[600],
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black87,
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
