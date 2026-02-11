import 'package:equatable/equatable.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class CategoryBreakdownItem {
  final String name;
  final double amount;
  final int color;
  final double percentage;

  const CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

class ChartDataPoint {
  final DateTime date;
  final double income;
  final double expense;

  const ChartDataPoint({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class StatisticsLoaded extends StatisticsState {
  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final double incomePercentage;
  final double expensePercentage;
  final double totalPercentage;
  final List<ChartDataPoint> chartData;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final String period;
  final AppDateTimeRange? customRange;

  const StatisticsLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalBalance,
    required this.incomePercentage,
    required this.expensePercentage,
    required this.totalPercentage,
    required this.chartData,
    required this.categoryBreakdown,
    required this.period,
    this.customRange,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    totalBalance,
    incomePercentage,
    expensePercentage,
    totalPercentage,
    chartData,
    categoryBreakdown,
    period,
    customRange,
  ];
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppDateTimeRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const AppDateTimeRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}
