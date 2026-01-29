import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  );
                  switch (value.toInt()) {
                    case 2:
                      return const Text('2k', style: style);
                    case 3:
                      return const Text('3k', style: style);
                    case 4:
                      return const Text('4k', style: style);
                    case 5:
                      return const Text('5k', style: style);
                    default:
                      return const Text('');
                  }
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
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  );
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Jan', style: style);
                    case 1:
                      return const Text('Feb', style: style);
                    case 2:
                      return const Text('Mar', style: style);
                    case 3:
                      return const Text('Apr', style: style);
                    case 4:
                      return const Text('May', style: style);
                    case 5:
                      return const Text('Jun', style: style);
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 3.1, 2.7),
            _makeGroupData(1, 3.3, 2.9),
            _makeGroupData(2, 3.8, 2.8),
            _makeGroupData(3, 4.0, 3.0),
            _makeGroupData(4, 4.2, 2.9),
            _makeGroupData(5, 4.5, 3.2),
          ],
          barTouchData: BarTouchData(enabled: false),
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
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: expense,
          color: const Color(0xFFEF4444),
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
      barsSpace: 4,
    );
  }
}
