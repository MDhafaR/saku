import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';

class ExpenseComparisonChart extends StatelessWidget {
  const ExpenseComparisonChart({super.key});

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
          _buildComparisonRow('Makan', 850, 0.7, const Color(0xFFF59E0B)),
          SizedBox(height: 12.h),
          _buildComparisonRow('Transport', 620, 0.5, const Color(0xFF2563EB)),
          SizedBox(height: 12.h),
          _buildComparisonRow('Belanja', 450, 0.35, const Color(0xFFE91E63)),
          SizedBox(height: 12.h),
          _buildComparisonRow('Lainnya', 200, 0.15, const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    int amount,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 70.w,
          child: Text(
            label,
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
                widthFactor: percentage,
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
        SizedBox(
          width: 40.w,
          child: Text(
            '\$$amount',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ),
      ],
    );
  }
}
