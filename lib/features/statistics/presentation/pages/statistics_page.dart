import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../core/injection.dart';
import '../components/time_period_selector.dart';
import '../components/line_chart_widget.dart';
import '../components/bar_chart_widget.dart';
import '../components/donut_chart_widget.dart';
import '../components/top_categories_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<StatisticsCubit>()..loadStatistics('Daily'),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<StatisticsCubit, state.StatisticsState>(
            builder: (context, s) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 140.h),
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
                    SizedBox(height: 12.h),

                    // Time Period Selector
                    TimePeriodSelector(
                      selectedPeriod: s is state.StatisticsLoaded
                          ? s.period
                          : s is state.StatisticsLoading
                          ? s.period
                          : 'Daily',
                      onPeriodChanged: (period) {
                        context.read<StatisticsCubit>().loadStatistics(period);
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
                    SizedBox(height: 16.h),

                    if (s is state.StatisticsLoading)
                      SizedBox(
                        height: 400.h,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (s is state.StatisticsError)
                      SizedBox(
                        height: 400.h,
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
                      ),
                      SizedBox(height: 12.h),

                      // Income vs Expense Chart
                      SakuCard(
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
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            isLineChart
                                ? LineChartWidget(data: s.chartData)
                                : BarChartWidget(data: s.chartData),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Category Breakdown
                      SakuCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CategoryDetailPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF111111),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            DonutChartWidget(categories: s.categoryBreakdown),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Top Categories
                      SakuCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Categories',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111111),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
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
