import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ['Daily', 'Monthly', 'Yearly', 'Custom'];

    return Row(
      children: periods.map((period) {
        final isSelected = period == selectedPeriod;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ElevatedButton(
              onPressed: () => onPeriodChanged(period),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.purple[600]
                    : Colors.grey[800],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                period,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
