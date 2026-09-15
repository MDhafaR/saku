import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../components/category_detail_card.dart';
import '../components/expense_comparison_chart.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';

class CategoryDetailPage extends StatefulWidget {
  final String period;
  final DateTime? targetDate;
  final AppDateTimeRange? customRange;

  const CategoryDetailPage({
    super.key,
    this.period = 'Monthly',
    this.targetDate,
    this.customRange,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late String currentPeriod;
  late DateTime selectedDate;
  AppDateTimeRange? currentCustomRange;
  int? _expandedIndex =
      0; // Default: first card is expanded, null = all collapsed

  @override
  void initState() {
    super.initState();
    currentPeriod = widget.period;
    selectedDate = widget.targetDate ?? DateTime.now();
    currentCustomRange = widget.customRange;
  }

  String _formatPeriodBadge(String period, DateTime date, AppDateTimeRange? range) {
    switch (period.toLowerCase()) {
      case 'daily':
        return DateFormat('d MMM yyyy', 'id_ID').format(date);
      case 'monthly':
        return DateFormat('MMM yyyy', 'id_ID').format(date);
      case 'yearly':
        return DateFormat('yyyy', 'id_ID').format(date);
      case 'custom':
        if (range != null) {
          final s = DateFormat('dd/MM', 'id_ID').format(range.start);
          final e = DateFormat('dd/MM', 'id_ID').format(range.end);
          return '$s - $e';
        }
        return 'Kustom';
      case 'all':
      default:
        return 'Semua Waktu';
    }
  }

  Future<void> _handleDateSelectorTap(BuildContext context) async {
    final cubit = context.read<StatisticsCubit>();

    switch (currentPeriod.toLowerCase()) {
      case 'daily':
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && mounted) {
          setState(() {
            selectedDate = picked;
          });
          cubit.loadStatistics(
            'Daily',
            targetDate: picked,
          );
        }
        break;

      case 'monthly':
        await _selectMonthYear(context);
        break;

      case 'yearly':
        final pickedYear = await _showYearPicker(context, selectedDate);
        if (pickedYear != null && mounted) {
          final newDate = DateTime(pickedYear, selectedDate.month, selectedDate.day);
          setState(() {
            selectedDate = newDate;
          });
          cubit.loadStatistics(
            'Yearly',
            targetDate: newDate,
          );
        }
        break;

      case 'custom':
        final pickedRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: currentCustomRange != null
              ? DateTimeRange(
                  start: currentCustomRange!.start,
                  end: currentCustomRange!.end,
                )
              : null,
        );
        if (pickedRange != null && mounted) {
          final appRange = AppDateTimeRange(
            start: pickedRange.start,
            end: pickedRange.end,
          );
          setState(() {
            currentCustomRange = appRange;
          });
          cubit.loadStatistics(
            'Custom',
            customRange: appRange,
          );
        }
        break;

      case 'all':
      default:
        break;
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final cubit = context.read<StatisticsCubit>();
    DateTime tempDate = DateTime(selectedDate.year, selectedDate.month);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Year navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year - 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showYearPicker(context, tempDate).then((
                            selectedYear,
                          ) {
                            if (selectedYear != null) {
                              setModalState(() {
                                tempDate = DateTime(
                                  selectedYear,
                                  tempDate.month,
                                );
                              });
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tempDate.year}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year + 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

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
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == tempDate.month;

                      final monthNames = [
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
                      ];

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempDate = DateTime(tempDate.year, month);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monthNames[index],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Select button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempDate);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Pilih',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        selectedDate = picked;
      });

      cubit.loadStatistics(
        'Monthly',
        targetDate: picked,
      );
    }
  }

  Future<int?> _showYearPicker(BuildContext context, DateTime tempDate) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'Pilih Tahun',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: 11, // 2020-2030
                itemBuilder: (ctx, i) {
                  final year = 2020 + i;
                  final isYearSelected = year == tempDate.year;
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(year),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isYearSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isYearSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isYearSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  void _onCardTap(int index) {
    setState(() {
      // Toggle: if already expanded, collapse it; otherwise expand this one
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return locator<StatisticsCubit>()
          ..loadStatistics(
            currentPeriod,
            targetDate: selectedDate,
            customRange: currentCustomRange,
          );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rincian Kategori',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20.sp,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StatisticsError) {
              return Center(child: Text(state.message));
            }

            if (state is StatisticsLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Total & Month/Period
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pengeluaran',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              CurrencyFormatter.formatRupiah(
                                state.totalExpense,
                              ),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: currentPeriod.toLowerCase() == 'all'
                              ? null
                              : () => _handleDateSelectorTap(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _formatPeriodBadge(
                                    currentPeriod,
                                    selectedDate,
                                    currentCustomRange,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (currentPeriod.toLowerCase() != 'all') ...[
                                  SizedBox(width: 2.w),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 14.sp,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Comparison Chart
                    ExpenseComparisonChart(categories: state.categoryBreakdown),
                    SizedBox(height: 10.h),

                    // Category Cards with expand/collapse
                    if (state.categoryBreakdown.isEmpty)
                      SizedBox(
                        height: 200.h,
                        child: const Center(
                          child: Text('Tidak ada data transaksi'),
                        ),
                      )
                    else
                      ...List.generate(state.categoryBreakdown.length, (index) {
                        final item = state.categoryBreakdown[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CategoryDetailCard(
                            item: item,
                            isExpanded: _expandedIndex == index,
                            onTap: () => _onCardTap(index),
                            period: currentPeriod,
                            targetDate: selectedDate,
                            customRange: currentCustomRange,
                          ),
                        );
                      }),
                    SizedBox(height: 10.h),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
