import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChartWidget extends StatefulWidget {
  const DonutChartWidget({super.key});

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Makanan', 'value': 29.4, 'color': const Color(0xFF3B82F6)},
    {'name': 'Transport', 'value': 21.5, 'color': const Color(0xFF10B981)},
    {'name': 'Belanja', 'value': 18.6, 'color': const Color(0xFF8B5CF6)},
    {'name': 'Hiburan', 'value': 11.1, 'color': const Color(0xFFF59E0B)},
    {'name': 'Lainnya', 'value': 19.4, 'color': const Color(0xFF6B7280)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 55,
              sections: List.generate(categories.length, (index) {
                final isTouched = index == touchedIndex;
                final category = categories[index];
                return PieChartSectionData(
                  color: category['color'] as Color,
                  value: category['value'] as double,
                  title: '',
                  radius: isTouched ? 58 : 50,
                  borderSide: isTouched
                      ? const BorderSide(color: Colors.white, width: 3)
                      : BorderSide.none,
                );
              }),
            ),
          ),
          // Center text showing selected category
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: touchedIndex != -1
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    key: ValueKey(touchedIndex),
                    children: [
                      Text(
                        categories[touchedIndex]['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(categories[touchedIndex]['value'] as double).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    key: ValueKey('default'),
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
