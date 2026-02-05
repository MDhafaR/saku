import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';

class StatisticsSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color percentageColor;

  const StatisticsSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      padding: EdgeInsets.all(12.w), // Reduced padding
      borderRadius: 24.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: backgroundColor, size: 20.sp),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: percentageColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
