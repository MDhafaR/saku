import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/statistics_state.dart';
import '../../../../core/utils/currency_formatter.dart';

class TopCategoriesWidget extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;

  const TopCategoriesWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (categories.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          l10n.noCategoriesRecorded,
          style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final topList = categories.take(5).toList();

    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Column(
        children: topList.map((category) {
          final isLast = topList.last == category;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
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
                      color: colorScheme.onSurface,
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
                    color: colorScheme.onSurface,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${category.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
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
