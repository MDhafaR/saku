import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/statistics_state.dart';

class PeriodDateNavigator extends StatelessWidget {
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback? onCustomTap;

  const PeriodDateNavigator({
    super.key,
    required this.period,
    required this.targetDate,
    this.customRange,
    required this.onDateChanged,
    this.onCustomTap,
  });

  void _onPrevious() {
    switch (period) {
      case 'Daily':
        onDateChanged(
          DateTime(targetDate.year, targetDate.month, targetDate.day - 1),
        );
        break;
      case 'Monthly':
        onDateChanged(DateTime(targetDate.year, targetDate.month - 1, 1));
        break;
      case 'Yearly':
        onDateChanged(DateTime(targetDate.year - 1, 1, 1));
        break;
    }
  }

  void _onNext() {
    switch (period) {
      case 'Daily':
        onDateChanged(
          DateTime(targetDate.year, targetDate.month, targetDate.day + 1),
        );
        break;
      case 'Monthly':
        onDateChanged(DateTime(targetDate.year, targetDate.month + 1, 1));
        break;
      case 'Yearly':
        onDateChanged(DateTime(targetDate.year + 1, 1, 1));
        break;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    int tempYear = targetDate.year;
    int tempMonth = targetDate.month;

    final shortMonthNames = l10n.isIndonesian
        ? [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Agu',
            'Sep',
            'Okt',
            'Nov',
            'Des',
          ]
        : [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: cs.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Year row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              tempYear--;
                            });
                          },
                          icon: Icon(
                            Icons.chevron_left,
                            color: cs.onSurface,
                            size: 24.sp,
                          ),
                        ),
                        Text(
                          '$tempYear',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              tempYear++;
                            });
                          },
                          icon: Icon(
                            Icons.chevron_right,
                            color: cs.onSurface,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Month grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.0,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                      ),
                      itemCount: 12,
                      itemBuilder: (ctx, index) {
                        final m = index + 1;
                        final isSelected = m == tempMonth;
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            onDateChanged(DateTime(tempYear, m, 1));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.onSurface
                                  : cs.surfaceContainerHighest.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              shortMonthNames[index],
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? cs.surface
                                    : cs.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showYearPicker(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.isIndonesian ? 'Pilih Tahun' : 'Select Year'),
          content: SizedBox(
            width: 300.w,
            height: 300.h,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              selectedDate: targetDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime);
              },
            ),
          ),
        );
      },
    );
    if (picked != null) {
      onDateChanged(DateTime(picked.year, 1, 1));
    }
  }

  String _formatDateLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (period) {
      case 'Daily':
        return DateFormat('d MMMM yyyy', l10n.dateLocaleCode).format(targetDate);
      case 'Monthly':
        return DateFormat('MMMM yyyy', l10n.dateLocaleCode).format(targetDate);
      case 'Yearly':
        return DateFormat('yyyy').format(targetDate);
      case 'Custom':
        if (customRange != null) {
          final start = DateFormat('dd/MM/yyyy').format(customRange!.start);
          final end = DateFormat('dd/MM/yyyy').format(customRange!.end);
          return '$start - $end';
        }
        return l10n.selectDateRangeTitle;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (period == 'All') {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBtnColor = isDark
        ? cs.surfaceContainerLow
        : const Color(0xFFF3F4F6);

    // For Custom, render single compact badge showing the range
    if (period == 'Custom') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Center(
          child: GestureDetector(
            onTap: onCustomTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: navBtnColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16.sp,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDateLabel(context),
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.edit_calendar_outlined,
                    size: 15.sp,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // For Daily, Monthly, Yearly: Render Arrow - Label - Arrow
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _onPrevious,
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: navBtnColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_left,
                color: cs.onSurface.withValues(alpha: 0.6),
                size: 18.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (period == 'Daily') {
                _showDatePicker(context);
              } else if (period == 'Monthly') {
                _showMonthYearPicker(context);
              } else if (period == 'Yearly') {
                _showYearPicker(context);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDateLabel(context),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurface,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _onNext,
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: navBtnColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.6),
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
