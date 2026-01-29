import 'package:flutter/material.dart';
import '../../../../core/theme/theme_service.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../components/statistics_summary_card.dart';
import '../components/time_period_selector.dart';
import '../components/line_chart_widget.dart';
import '../components/bar_chart_widget.dart';
import '../components/donut_chart_widget.dart';
import '../components/top_categories_widget.dart';
import 'category_detail_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedPeriod = 'Daily';
  bool isLineChart = true; // true = line chart, false = bar chart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Global "Clean & Airy" bg
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            164,
          ), // Extra bottom padding for navigation bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800, // Thicker
                      color: Color(0xFF111111), // Darker Black
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ThemeService.toggleTheme();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: Icon(
                      ThemeService.isLightMode ? Icons.dark_mode : Icons.sunny,
                      color: const Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Time Period Selector
              TimePeriodSelector(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: StatisticsSummaryCard(
                      title: 'Income',
                      amount: '\$4,250',
                      percentage: '+12.5%',
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF10B981),
                      percentageColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticsSummaryCard(
                      title: 'Expense',
                      amount: '\$2,890',
                      percentage: '-8.2%',
                      icon: Icons.trending_down,
                      iconColor: const Color(0xFFEF4444),
                      backgroundColor: const Color(0xFFEF4444),
                      percentageColor: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticsSummaryCard(
                      title: 'Total',
                      amount: '\$1,360',
                      percentage: '+4.3%',
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF6366F1),
                      backgroundColor: const Color(0xFF6366F1),
                      percentageColor: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Income vs Expense Chart
              SakuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Income vs Expense',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => isLineChart = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isLineChart
                                      ? const Color(0xFF111111)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.show_chart,
                                  color: isLineChart
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => isLineChart = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: !isLineChart
                                      ? const Color(0xFF111111)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.bar_chart,
                                  color: !isLineChart
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    isLineChart
                        ? const LineChartWidget()
                        : const BarChartWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Breakdown
              // Category Breakdown
              SakuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
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
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                0xFF111111,
                              ), // Dark to match design system
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DonutChartWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top Categories
              SakuCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const TopCategoriesWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
