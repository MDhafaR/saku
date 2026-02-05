import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChartPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionText;
  final VoidCallback? onActionTap;
  final List<Widget>? headerActions;

  const ChartPanel({
    super.key,
    required this.title,
    required this.child,
    this.actionText,
    this.onActionTap,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (headerActions != null) ...headerActions!,
              if (actionText != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }
}
