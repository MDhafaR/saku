import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/local/database/app_database.dart';
import 'statistics_state.dart';
import 'package:drift/drift.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final AppDatabase _db;

  StatisticsCubit(this._db) : super(const StatisticsInitial());

  Future<void> loadStatistics(
    String period, {
    AppDateTimeRange? customRange,
  }) async {
    emit(const StatisticsLoading());

    try {
      final now = DateTime.now();
      DateTime start;
      DateTime end = now;
      DateTime prevStart;
      DateTime prevEnd;

      switch (period) {
        case 'Daily':
          start = DateTime(now.year, now.month, now.day);
          prevStart = start.subtract(const Duration(days: 1));
          prevEnd = start.subtract(const Duration(seconds: 1));
          break;
        case 'Monthly':
          start = DateTime(now.year, now.month, 1);
          prevStart = DateTime(now.year, now.month - 1, 1);
          prevEnd = start.subtract(const Duration(seconds: 1));
          break;
        case 'Yearly':
          start = DateTime(now.year, 1, 1);
          prevStart = DateTime(now.year - 1, 1, 1);
          prevEnd = start.subtract(const Duration(seconds: 1));
          break;
        case 'Custom':
          if (customRange == null) {
            emit(const StatisticsError('Custom range not provided'));
            return;
          }
          start = customRange.start;
          end = customRange.end;
          final duration = end.difference(start);
          prevEnd = start.subtract(const Duration(seconds: 1));
          prevStart = prevEnd.subtract(duration);
          break;
        case 'All':
        default:
          start = DateTime(2000);
          prevStart = DateTime(1999);
          prevEnd = DateTime(1999, 12, 31);
          break;
      }

      // Fetch current period data
      final income = await _db.transactionDao.getTotalIncome(start, end);
      final expense = await _db.transactionDao.getTotalExpense(start, end);
      final balance = income - expense;

      // Fetch previous period data for percentages
      final prevIncome = await _db.transactionDao.getTotalIncome(
        prevStart,
        prevEnd,
      );
      final prevExpense = await _db.transactionDao.getTotalExpense(
        prevStart,
        prevEnd,
      );
      final prevBalance = prevIncome - prevExpense;

      final incomePercentage = _calculatePercentage(income, prevIncome);
      final expensePercentage = _calculatePercentage(expense, prevExpense);
      final totalPercentage = _calculatePercentage(balance, prevBalance);

      // Fetch chart data
      List<ChartDataPoint> chartData = [];
      if (period == 'Yearly') {
        final monthlyStats = await _db.transactionDao.getMonthlyStats(
          start,
          end,
        );
        chartData = _processMonthlyStats(monthlyStats, start, end);
      } else {
        final dailyStats = await _db.transactionDao.getDailyStats(start, end);
        chartData = _processDailyStats(dailyStats, start, end);
      }

      // Fetch category breakdown
      final breakdown = await _db.transactionDao.getCategoryBreakdown(
        start,
        end,
        'expense',
      );
      final totalExp = breakdown.fold<double>(
        0,
        (sum, item) =>
            sum + (item.read<double>(_db.transactions.amount.sum()) ?? 0),
      );

      final List<CategoryBreakdownItem> categoryItems = [];
      for (final row in breakdown) {
        final id = row.read<int>(_db.categories.id)!;
        final name = row.read<String>(_db.categories.name) ?? 'Unknown';
        final amount = row.read<double>(_db.transactions.amount.sum()) ?? 0;
        final color = row.read<int>(_db.categories.iconColor) ?? 0xFF2196F3;
        final icon = row.read<String>(_db.categories.icon) ?? 'category';
        final count = row.read<int>(_db.transactions.id.count()) ?? 0;

        // Fetch previous total for trend
        final prevTotal = await _db.transactionDao.getTotalByCategory(
          id,
          prevStart,
          prevEnd,
        );
        final trendVal = _calculatePercentage(amount, prevTotal);

        // Fetch top transactions
        final topTxs = await _db.transactionDao.getTopTransactionsByCategory(
          id,
          start,
          end,
        );

        categoryItems.add(
          CategoryBreakdownItem(
            id: id,
            name: name,
            amount: amount,
            color: color,
            icon: icon,
            percentage: totalExp > 0 ? (amount / totalExp) * 100 : 0,
            transactionCount: count,
            trendValue: "${trendVal.abs().toStringAsFixed(1)}%",
            isTrendUp: trendVal > 0,
            topTransactions: topTxs,
          ),
        );
      }

      emit(
        StatisticsLoaded(
          totalIncome: income,
          totalExpense: expense,
          totalBalance: balance,
          incomePercentage: incomePercentage,
          expensePercentage: expensePercentage,
          totalPercentage: totalPercentage,
          prevIncome: prevIncome,
          prevExpense: prevExpense,
          prevTotal: prevBalance,
          chartData: chartData,
          categoryBreakdown: categoryItems,
          period: period,
          customRange: customRange,
        ),
      );
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  double _calculatePercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  List<ChartDataPoint> _processDailyStats(
    List<TypedResult> stats,
    DateTime start,
    DateTime end,
  ) {
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    for (var row in stats) {
      final type = row.read<String>(_db.transactions.type);
      final date = row.read<String>(_db.transactions.transactionDate.date);
      final amount = row.read<double>(_db.transactions.amount.sum()) ?? 0;

      if (date != null) {
        if (type == 'income') {
          incomeMap[date] = amount;
        } else {
          expenseMap[date] = amount;
        }
      }
    }

    List<ChartDataPoint> result = [];
    int days = end.difference(start).inDays + 1;
    // Limit to 30 days if too many
    if (days > 31) days = 31;

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      result.add(
        ChartDataPoint(
          date: date,
          income: incomeMap[dateKey] ?? 0,
          expense: expenseMap[dateKey] ?? 0,
        ),
      );
    }
    return result;
  }

  List<ChartDataPoint> _processMonthlyStats(
    List<TypedResult> stats,
    DateTime start,
    DateTime end,
  ) {
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    // SQLite strftime('%Y-%m') output
    for (var row in stats) {
      final type = row.read<String>(_db.transactions.type);
      final monthExpr = row.read<String>(
        _db.transactions.transactionDate.strftime('%Y-%m'),
      );
      final amount = row.read<double>(_db.transactions.amount.sum()) ?? 0;

      if (monthExpr != null) {
        if (type == 'income') {
          incomeMap[monthExpr] = amount;
        } else {
          expenseMap[monthExpr] = amount;
        }
      }
    }

    List<ChartDataPoint> result = [];
    for (int i = 0; i < 12; i++) {
      final date = DateTime(start.year, i + 1, 1);
      final monthKey = "${date.year}-${(i + 1).toString().padLeft(2, '0')}";
      result.add(
        ChartDataPoint(
          date: date,
          income: incomeMap[monthKey] ?? 0,
          expense: expenseMap[monthKey] ?? 0,
        ),
      );
    }
    return result;
  }
}
