import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/statistics_state.dart';

class ChartScale {
  final double maxY;
  final double interval;

  const ChartScale({required this.maxY, required this.interval});

  factory ChartScale.fromMax(double maxVal) {
    if (maxVal <= 0) {
      return const ChartScale(maxY: 10.0, interval: 2.5);
    }

    final targetMax = maxVal * 1.15;
    final exponent = (math.log(targetMax) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toDouble();
    final fraction = targetMax / magnitude;

    double niceFraction;
    double niceIntervalFraction;

    if (fraction <= 1.2) {
      niceFraction = 1.2;
      niceIntervalFraction = 0.3;
    } else if (fraction <= 2.0) {
      niceFraction = 2.0;
      niceIntervalFraction = 0.5;
    } else if (fraction <= 2.5) {
      niceFraction = 2.5;
      niceIntervalFraction = 0.5;
    } else if (fraction <= 4.0) {
      niceFraction = 4.0;
      niceIntervalFraction = 1.0;
    } else if (fraction <= 5.0) {
      niceFraction = 5.0;
      niceIntervalFraction = 1.0;
    } else if (fraction <= 8.0) {
      niceFraction = 8.0;
      niceIntervalFraction = 2.0;
    } else {
      niceFraction = 10.0;
      niceIntervalFraction = 2.5;
    }

    final maxY = niceFraction * magnitude;
    final interval = niceIntervalFraction * magnitude;

    return ChartScale(maxY: maxY, interval: interval);
  }
}

class BarChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (data.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Text(
            l10n.noDataAvailable,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ),
      );
    }

    double maxVal = 0;
    for (var point in data) {
      if (point.income > maxVal) maxVal = point.income;
      if (point.expense > maxVal) maxVal = point.expense;
    }

    final scale = ChartScale.fromMax(maxVal);

    return Container(
      height: 185.h,
      padding: EdgeInsets.only(top: 8.h, right: 8.w),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: scale.interval,
                reservedSize: 38.w,
                getTitlesWidget: (value, meta) {
                  if (value <= 0) return const Text('');

                  final stepRatio = value / scale.interval;
                  if ((stepRatio - stepRatio.round()).abs() > 0.05) {
                    return const Text('');
                  }

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
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if ((value - value.round()).abs() > 0.05) {
                    return const Text('');
                  }
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const Text('');

                  int step = 1;
                  if (data.length > 20) {
                    step = (data.length / 6).ceil();
                  } else if (data.length > 10) {
                    step = (data.length / 6).ceil();
                  }

                  if (index % step != 0 && index != data.length - 1) {
                    return const Text('');
                  }

                  final style = TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  );

                  final point = data[index];
                  final label =
                      point.customLabel ??
                      (data.length <= 12
                          ? DateFormat('MMM', l10n.dateLocaleCode).format(point.date)
                          : data.length <= 31
                          ? DateFormat('d', l10n.dateLocaleCode).format(point.date)
                          : DateFormat('MM/yy', l10n.dateLocaleCode).format(point.date));

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
          maxY: scale.maxY,
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
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return v == v.roundToDouble()
          ? '${v.toInt()}B'
          : '${v.toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      final v = value / 1000000;
      return v == v.roundToDouble()
          ? '${v.toInt()}M'
          : '${v.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final v = value / 1000;
      return v == v.roundToDouble()
          ? '${v.toInt()}k'
          : '${v.toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
