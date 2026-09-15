import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/cubit/security_cubit.dart';
import '../../../settings/presentation/cubit/security_state.dart';
import '../../../statistics/presentation/cubit/statistics_state.dart';
import '../../../../core/presentation/components/financial_summary_card.dart';
import 'financial_metric_info_modal.dart';

class FinancialDashboardSummary extends StatelessWidget {
  final double income;
  final double expense;
  final double total;
  final double prevIncome;
  final double prevExpense;
  final double prevTotal;
  final bool isLoading;
  final String period;
  final DateTime? targetDate;
  final AppDateTimeRange? customRange;

  const FinancialDashboardSummary({
    super.key,
    required this.income,
    required this.expense,
    required this.total,
    required this.prevIncome,
    required this.prevExpense,
    required this.prevTotal,
    this.isLoading = false,
    this.period = 'Monthly',
    this.targetDate,
    this.customRange,
  });

  String _formatPercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? '+100%' : '0%';
    final change = ((current - previous) / previous) * 100;
    if (change.abs() >= 100 || change == change.roundToDouble()) {
      return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}%';
    }
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
  }

  Color _getPercentageColor(
    double current,
    double previous, {
    bool invert = false,
  }) {
    if (previous == 0 && current == 0) return Colors.grey;
    final change = previous == 0
        ? (current > 0 ? 100 : 0)
        : ((current - previous) / previous) * 100;

    if (change == 0) return Colors.grey;

    if (invert) {
      // For expense: increase is bad (red), decrease is good (green)
      return change > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    } else {
      // For income/total: increase is good (green), decrease is bad (red)
      return change > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        final isMasked = state.isBalanceSensorEnabled;

        final incomePercentageStr = _formatPercentage(income, prevIncome);
        final incomePercentageColor = _getPercentageColor(income, prevIncome);

        final expensePercentageStr = _formatPercentage(expense, prevExpense);
        final expensePercentageColor = _getPercentageColor(
          expense,
          prevExpense,
          invert: true,
        );

        final totalPercentageStr = _formatPercentage(total, prevTotal);
        final totalPercentageColor = _getPercentageColor(total, prevTotal);

        return Skeletonizer(
          enabled: isLoading,
          child: Row(
            children: [
              Expanded(
                child: FinancialSummaryCard(
                  title: 'Income',
                  amount: isMasked
                      ? '••••••'
                      : 'Rp ${CurrencyFormatter.format(income.toStringAsFixed(0))}',
                  percentage: incomePercentageStr,
                  percentageColor: incomePercentageColor,
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF10B981),
                  onTap: () {
                    FinancialMetricInfoModal.show(
                      context,
                      metricType: 'income',
                      currentAmount: income,
                      prevAmount: prevIncome,
                      percentageStr: incomePercentageStr,
                      percentageColor: incomePercentageColor,
                      isMasked: isMasked,
                      period: period,
                      targetDate: targetDate,
                      customRange: customRange,
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FinancialSummaryCard(
                  title: 'Expense',
                  amount: isMasked
                      ? '••••••'
                      : 'Rp ${CurrencyFormatter.format(expense.toStringAsFixed(0))}',
                  percentage: expensePercentageStr,
                  percentageColor: expensePercentageColor,
                  icon: Icons.trending_down,
                  iconColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFEF4444),
                  onTap: () {
                    FinancialMetricInfoModal.show(
                      context,
                      metricType: 'expense',
                      currentAmount: expense,
                      prevAmount: prevExpense,
                      percentageStr: expensePercentageStr,
                      percentageColor: expensePercentageColor,
                      isMasked: isMasked,
                      period: period,
                      targetDate: targetDate,
                      customRange: customRange,
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FinancialSummaryCard(
                  title: 'Total',
                  amount: isMasked
                      ? '••••••'
                      : 'Rp ${CurrencyFormatter.format(total.abs().toStringAsFixed(0))}',
                  percentage: totalPercentageStr,
                  percentageColor: totalPercentageColor,
                  icon: Icons.account_balance_wallet,
                  iconColor: const Color(0xFF6366F1),
                  backgroundColor: const Color(0xFF6366F1),
                  amountColor: total >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  onTap: () {
                    FinancialMetricInfoModal.show(
                      context,
                      metricType: 'total',
                      currentAmount: total,
                      prevAmount: prevTotal,
                      percentageStr: totalPercentageStr,
                      percentageColor: totalPercentageColor,
                      isMasked: isMasked,
                      period: period,
                      targetDate: targetDate,
                      customRange: customRange,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
