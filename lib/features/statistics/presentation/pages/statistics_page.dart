import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/injection.dart';
import '../components/time_period_selector.dart';
import '../components/period_date_navigator.dart';
import '../components/line_chart_widget.dart';
import '../components/bar_chart_widget.dart';
import '../components/donut_chart_widget.dart';
import '../components/top_categories_widget.dart';
import '../components/income_expense_chart_info_modal.dart';
import '../components/category_breakdown_info_modal.dart';
import '../components/top_categories_info_modal.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart' as state;
import '../../../dashboard/presentation/widgets/financial_dashboard_summary.dart';
import 'category_detail_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isLineChart = true; // true = line chart, false = bar chart

  Future<void> _openCustomDateRangePicker(
    BuildContext context,
    state.AppDateTimeRange? currentRange,
  ) async {
    final cubit = context.read<StatisticsCubit>();
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: currentRange != null
          ? DateTimeRange(start: currentRange.start, end: currentRange.end)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
      initialEntryMode: DatePickerEntryMode.input,
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

    if (result != null && mounted) {
      cubit.loadStatistics(
        'Custom',
        customRange: state.AppDateTimeRange(
          start: result.start,
          end: result.end,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          locator<StatisticsCubit>()..loadStatistics('Monthly'),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<StatisticsCubit, state.StatisticsState>(
            builder: (context, s) {
              final selectedPeriod = s is state.StatisticsLoaded
                  ? s.period
                  : s is state.StatisticsLoading
                  ? s.period
                  : 'Monthly';

              final targetDate = s is state.StatisticsLoaded
                  ? s.targetDate
                  : s is state.StatisticsLoading && s.targetDate != null
                  ? s.targetDate!
                  : DateTime.now();

              final customRange = s is state.StatisticsLoaded
                  ? s.customRange
                  : s is state.StatisticsLoading
                  ? s.customRange
                  : null;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 140.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Time Period Selector
                    TimePeriodSelector(
                      selectedPeriod: selectedPeriod,
                      onPeriodChanged: (period) {
                        if (period == 'Custom') {
                          _openCustomDateRangePicker(context, customRange);
                        } else {
                          context.read<StatisticsCubit>().loadStatistics(
                            period,
                            targetDate: targetDate,
                          );
                        }
                      },
                      onCustomDateSelected: (range) {
                        context.read<StatisticsCubit>().loadStatistics(
                          'Custom',
                          customRange: state.AppDateTimeRange(
                            start: range.start,
                            end: range.end,
                          ),
                        );
                      },
                    ),

                    // Animated Date Navigator below Period Selector
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      child: selectedPeriod == 'All'
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: EdgeInsets.only(top: 6.h, bottom: 2.h),
                              child: PeriodDateNavigator(
                                period: selectedPeriod,
                                targetDate: targetDate,
                                customRange: customRange,
                                onDateChanged: (newDate) {
                                  context
                                      .read<StatisticsCubit>()
                                      .loadStatistics(
                                        selectedPeriod,
                                        targetDate: newDate,
                                      );
                                },
                                onCustomTap: () => _openCustomDateRangePicker(
                                  context,
                                  customRange,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 10.h),

                    if (s is state.StatisticsLoading)
                      SizedBox(
                        height: 350.h,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (s is state.StatisticsError)
                      SizedBox(
                        height: 350.h,
                        child: Center(child: Text(s.message)),
                      )
                    else if (s is state.StatisticsLoaded) ...[
                      // Summary Cards
                      FinancialDashboardSummary(
                        income: s.totalIncome,
                        expense: s.totalExpense,
                        total: s.totalBalance,
                        prevIncome: s.prevIncome,
                        prevExpense: s.prevExpense,
                        prevTotal: s.prevTotal,
                        period: s.period,
                        targetDate: s.targetDate,
                        customRange: s.customRange,
                      ),
                      SizedBox(height: 10.h),

                      // Income vs Expense Chart
                      SakuCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Income vs Expense',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => isLineChart = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: isLineChart
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                              : (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerLow
                                                    : const Color(0xFFF3F4F6)),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.show_chart,
                                          color: isLineChart
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.surface
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                          size: 14.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => isLineChart = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: !isLineChart
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                              : (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainerLow
                                                    : const Color(0xFFF3F4F6)),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.bar_chart,
                                          color: !isLineChart
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.surface
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                          size: 14.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    GestureDetector(
                                      onTap: () =>
                                          IncomeExpenseChartInfoModal.show(
                                        context,
                                        chartData: s.chartData,
                                        period: s.period,
                                        targetDate: s.targetDate,
                                        customRange: s.customRange,
                                        totalIncome: s.totalIncome,
                                        totalExpense: s.totalExpense,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerLow
                                              : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.65),
                                          size: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            isLineChart
                                ? LineChartWidget(data: s.chartData)
                                : BarChartWidget(data: s.chartData),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Category Breakdown
                      SakuCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Category Breakdown',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    GestureDetector(
                                      onTap: () =>
                                          CategoryBreakdownInfoModal.show(
                                        context,
                                        categories: s.categoryBreakdown,
                                        period: s.period,
                                        targetDate: s.targetDate,
                                        customRange: s.customRange,
                                        totalExpense: s.totalExpense,
                                      ),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: EdgeInsets.all(2.w),
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          size: 15.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryDetailPage(
                                          period: s.period,
                                          targetDate: s.targetDate,
                                          customRange: s.customRange,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            DonutChartWidget(categories: s.categoryBreakdown),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Top Categories
                      SakuCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Top Categories',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                GestureDetector(
                                  onTap: () => TopCategoriesInfoModal.show(
                                    context,
                                    categories: s.categoryBreakdown,
                                    period: s.period,
                                    targetDate: s.targetDate,
                                    customRange: s.customRange,
                                    totalExpense: s.totalExpense,
                                  ),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: EdgeInsets.all(2.w),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: 15.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            TopCategoriesWidget(
                              categories: s.categoryBreakdown,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
