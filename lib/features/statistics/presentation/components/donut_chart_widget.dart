import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../cubit/statistics_state.dart';

class DonutChartWidget extends StatefulWidget {
  final List<CategoryBreakdownItem> categories;

  const DonutChartWidget({super.key, required this.categories});

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
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
              centerSpaceRadius: 45,
              sections: List.generate(widget.categories.length, (index) {
                final isTouched = index == touchedIndex;
                final category = widget.categories[index];
                return PieChartSectionData(
                  color: Color(category.color),
                  value: category.amount,
                  title: '',
                  radius: isTouched ? 48 : 40,
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
            child: touchedIndex != -1 && touchedIndex < widget.categories.length
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    key: ValueKey(touchedIndex),
                    children: [
                      Text(
                        widget.categories[touchedIndex].name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.categories[touchedIndex].percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 16,
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
