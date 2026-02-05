import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopCategoriesWidget extends StatelessWidget {
  const TopCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Food & Dining',
        'amount': '\$850',
        'percentage': '29.4%',
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Transportation',
        'amount': '\$620',
        'percentage': '21.5%',
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Shopping',
        'amount': '\$480',
        'percentage': '18.6%',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Entertainment',
        'amount': '\$320',
        'percentage': '11.1%',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: categories.map((category) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: const Color(0xFF1F2937),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  category['amount'] as String,
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  category['percentage'] as String,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
