import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../cubit/statistics_state.dart';

class LineChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;

  const LineChartWidget({super.key, required this.data});

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
      height: 185.h,
      padding: EdgeInsets.only(top: 8.h, right: 8.w),
      child: LineChart(
        LineChartData(
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
                reservedSize: 22.h,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const Text('');

                  // Show only 5-6 labels to avoid crowding
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
                  } else if (data.length <= 31) {
                    label = DateFormat('d').format(date);
                  } else {
                    label = DateFormat('MM/yy').format(date);
                  }

                  return Text(label, style: style);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3.w,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                  .toList(),
              isCurved: true,
              color: const Color(0xFFEF4444),
              barWidth: 3.w,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: maxVal,
        ),
      ),
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
