import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';

class TimePeriodSelector extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final Function(DateTimeRange)? onCustomDateSelected;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.onCustomDateSelected,
  });

  @override
  State<TimePeriodSelector> createState() => _TimePeriodSelectorState();
}

class _TimePeriodSelectorState extends State<TimePeriodSelector> {
  final List<String> periods = ['All', 'Daily', 'Monthly', 'Yearly', 'Custom'];

  String _getPeriodLabel(String period, AppLocalizations l10n) {
    switch (period) {
      case 'All':
        return l10n.periodAll;
      case 'Daily':
        return l10n.periodDaily;
      case 'Weekly':
        return l10n.periodWeekly;
      case 'Monthly':
        return l10n.periodMonthly;
      case 'Yearly':
        return l10n.periodYearly;
      case 'Custom':
        return l10n.periodCustom;
      default:
        return period;
    }
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      initialEntryMode: DatePickerEntryMode.input, // Shows compact dialog first
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111111),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && widget.onCustomDateSelected != null) {
      widget.onCustomDateSelected!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = periods.indexOf(widget.selectedPeriod);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / periods.length;

          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: (selectedIndex >= 0 ? selectedIndex : 0) * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: periods.map((period) {
                  final isSelected = widget.selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.onPeriodChanged(period);
                        if (period == 'Custom') {
                          _showDateRangePicker();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 3.w,
                        ),
                        child: Text(
                          _getPeriodLabel(period, l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
