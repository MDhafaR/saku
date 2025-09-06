import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartWidget extends StatelessWidget {
  const DonutChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              color: const Color(0xFF3B82F6),
              value: 29.4,
              title: '',
              radius: 50,
            ),
            PieChartSectionData(
              color: const Color(0xFF10B981),
              value: 21.5,
              title: '',
              radius: 50,
            ),
            PieChartSectionData(
              color: const Color(0xFF8B5CF6),
              value: 18.6,
              title: '',
              radius: 50,
            ),
            PieChartSectionData(
              color: const Color(0xFFF59E0B),
              value: 11.1,
              title: '',
              radius: 50,
            ),
            PieChartSectionData(
              color: const Color(0xFF6B7280),
              value: 19.4,
              title: '',
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
