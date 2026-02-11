import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../cubit/statistics_state.dart';

class BarChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: const Center(child: Text('No data available')),
      );
    }

    double maxVal = 0;
    for (var point in data) {
      if (point.income > maxVal) maxVal = point.income;
      if (point.expense > maxVal) maxVal = point.expense;
    }
    // Add 20% buffer
    maxVal = maxVal == 0 ? 10 : maxVal * 1.2;

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(16.w),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35.w,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('');
                  final style = TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  );
                  return Text(_formatValue(value), style: style);
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30.h,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const Text('');

                  // Show labels strategically
                  final interval = (data.length / 5).ceil();
                  if (index % interval != 0 && index != data.length - 1) {
                    return const Text('');
                  }

                  final style = TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  );

                  final date = data[index].date;
                  String label;
                  if (data.length <= 12) {
                    label = DateFormat('MMM').format(date);
                  } else {
                    label = DateFormat('dd').format(date);
                  }

                  return Text(label, style: style);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data
              .asMap()
              .entries
              .map(
                (e) => _makeGroupData(e.key, e.value.income, e.value.expense),
              )
              .toList(),
          barTouchData: BarTouchData(enabled: false),
          maxY: maxVal,
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: const Color(0xFF10B981),
          width: 8.w,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.r),
            topRight: Radius.circular(2.r),
          ),
        ),
        BarChartRodData(
          toY: expense,
          color: const Color(0xFFEF4444),
          width: 8.w,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.r),
            topRight: Radius.circular(2.r),
          ),
        ),
      ],
      barsSpace: 2.w,
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
