import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/statistics_state.dart';
import '../../../../core/utils/currency_formatter.dart';

class TopCategoriesWidget extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;

  const TopCategoriesWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          'No categories recorded',
          style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: categories.take(5).map((category) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Color(category.color),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: const Color(0xFF1F2937),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(
                    category.amount.toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${category.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
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
