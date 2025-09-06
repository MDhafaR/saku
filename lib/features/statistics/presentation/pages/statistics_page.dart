import 'package:flutter/material.dart';
import '../../../../core/theme/theme_service.dart';
import '../components/statistics_summary_card.dart';
import '../components/time_period_selector.dart';
import '../components/line_chart_widget.dart';
import '../components/donut_chart_widget.dart';
import '../components/top_categories_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedPeriod = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
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
                      iconColor: Colors.white,
                      backgroundColor: const Color(0xFF10B981),
                      percentageColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticsSummaryCard(
                      title: 'Expense',
                      amount: '\$2,890',
                      percentage: '-8.2%',
                      icon: Icons.trending_down,
                      iconColor: Colors.white,
                      backgroundColor: const Color(0xFFEF4444),
                      percentageColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticsSummaryCard(
                      title: 'Total',
                      amount: '\$1,360',
                      percentage: '+4.3%',
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.white,
                      backgroundColor: const Color(0xFF6366F1),
                      percentageColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Income vs Expense Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.show_chart,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bar_chart,
                                color: Color(0xFF6B7280),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const LineChartWidget(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B82F6),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
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
