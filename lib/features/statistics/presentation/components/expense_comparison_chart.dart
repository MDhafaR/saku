import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/statistics_state.dart';

class ExpenseComparisonChart extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;

  const ExpenseComparisonChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SakuCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komparasi Pengeluaran',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 10.h),
          if (categories.isEmpty)
            SizedBox(
              height: 80.h,
              child: Center(
                child: Text(
                  'Tidak ada data komparasi',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...categories.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildComparisonRow(
                  context,
                  item.name,
                  item.amount,
                  item.percentage / 100, // percentage is 0-100
                  Color(item.color),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String label,
    double amount,
    double percentage,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 75.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
