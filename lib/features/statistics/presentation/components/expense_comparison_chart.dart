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
    return SakuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komparasi Pengeluaran',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          SizedBox(height: 16.h),
          if (categories.isEmpty)
            SizedBox(
              height: 100.h,
              child: const Center(child: Text('Tidak ada data komparasi')),
            )
          else
            ...categories.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildComparisonRow(
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
    String label,
    double amount,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}
