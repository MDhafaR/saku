import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final l10n = context.l10n;
    if (widget.categories.isEmpty) {
      return SizedBox(
        height: 160.h,
        child: Center(
          child: Text(
            l10n.noDataAvailable,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 150.h,
      padding: EdgeInsets.zero,
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
              centerSpaceRadius: 42.r,
              sections: List.generate(widget.categories.length, (index) {
                final isTouched = index == touchedIndex;
                final category = widget.categories[index];
                return PieChartSectionData(
                  color: Color(category.color),
                  value: category.amount,
                  title: '',
                  radius: isTouched ? 44.r : 36.r,
                  borderSide: isTouched
                      ? BorderSide(color: colorScheme.surface, width: 2.5)
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
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${widget.categories[touchedIndex].percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    key: const ValueKey('default'),
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
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
