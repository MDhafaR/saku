import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
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
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3.1),
                FlSpot(1, 3.3),
                FlSpot(2, 3.8),
                FlSpot(3, 4.0),
                FlSpot(4, 4.2),
                FlSpot(5, 4.5),
              ],
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10B981).withOpacity(0.1),
              ),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 2.7),
                FlSpot(1, 2.9),
                FlSpot(2, 2.8),
                FlSpot(3, 3.0),
                FlSpot(4, 2.9),
                FlSpot(5, 3.2),
              ],
              isCurved: true,
              color: const Color(0xFFEF4444),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFEF4444).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
