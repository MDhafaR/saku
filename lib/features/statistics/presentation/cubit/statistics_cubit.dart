import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/local/database/app_database.dart';
import 'statistics_state.dart';
import 'package:drift/drift.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final AppDatabase _db;

  StatisticsCubit(this._db) : super(const StatisticsInitial());

  Future<void> loadStatistics(
    String period, {
    DateTime? targetDate,
    AppDateTimeRange? customRange,
  }) async {
    final anchor = targetDate ?? DateTime.now();
    emit(StatisticsLoading(
      period: period,
      targetDate: anchor,
      customRange: customRange,
    ));

    try {
      DateTime start;
      DateTime end;
      DateTime prevStart;
      DateTime prevEnd;

      switch (period) {
        case 'Daily':
          start = DateTime(anchor.year, anchor.month, anchor.day);
          end = DateTime(anchor.year, anchor.month, anchor.day, 23, 59, 59);
          prevStart = start.subtract(const Duration(days: 1));
          prevEnd = DateTime(prevStart.year, prevStart.month, prevStart.day, 23, 59, 59);
          break;
        case 'Monthly':
          start = DateTime(anchor.year, anchor.month, 1);
          final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
          end = DateTime(anchor.year, anchor.month, daysInMonth, 23, 59, 59);
          prevStart = DateTime(anchor.year, anchor.month - 1, 1);
          final daysInPrevMonth = DateTime(anchor.year, anchor.month, 0).day;
          prevEnd = DateTime(prevStart.year, prevStart.month, daysInPrevMonth, 23, 59, 59);
          break;
        case 'Yearly':
          start = DateTime(anchor.year, 1, 1);
          end = DateTime(anchor.year, 12, 31, 23, 59, 59);
          prevStart = DateTime(anchor.year - 1, 1, 1);
          prevEnd = DateTime(anchor.year - 1, 12, 31, 23, 59, 59);
          break;
        case 'Custom':
          if (customRange == null) {
            emit(const StatisticsError('Custom range not provided'));
            return;
          }
          start = customRange.start;
          end = DateTime(
            customRange.end.year,
            customRange.end.month,
            customRange.end.day,
            23,
            59,
            59,
          );
          final duration = end.difference(start);
          prevEnd = start.subtract(const Duration(seconds: 1));
          prevStart = prevEnd.subtract(duration);
          break;
        case 'All':
        default:
          start = DateTime(2000);
          end = DateTime.now();
          prevStart = DateTime(1999);
          prevEnd = DateTime(1999, 12, 31, 23, 59, 59);
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

      // Fetch chart data based on period
      List<ChartDataPoint> chartData = [];
      if (period == 'Daily') {
        final hourlyStats = await _db.transactionDao.getHourlyStats(start, end);
        chartData = _processHourlyStats(hourlyStats, start);
      } else if (period == 'Monthly') {
        final dailyStats = await _db.transactionDao.getDailyStats(start, end);
        chartData = _processDailyStats(dailyStats, start, end);
      } else if (period == 'Yearly') {
        final monthlyStats = await _db.transactionDao.getMonthlyStats(
          start,
          end,
        );
        chartData = _processMonthlyStats(monthlyStats, start.year);
      } else if (period == 'Custom') {
        final totalDays = end.difference(start).inDays + 1;
        if (totalDays <= 31) {
          final dailyStats = await _db.transactionDao.getDailyStats(start, end);
          chartData = _processDailyStats(dailyStats, start, end);
        } else if (totalDays <= 365 * 2) {
          final monthlyStats = await _db.transactionDao.getMonthlyStats(
            start,
            end,
          );
          chartData = _processCustomMonthlyStats(monthlyStats, start, end);
        } else {
          final yearlyStats = await _db.transactionDao.getYearlyStats(
            start,
            end,
          );
          chartData = _processYearlyStats(yearlyStats, start.year, end.year);
        }
      } else {
        // period == 'All'
        final earliestDate =
            await _db.transactionDao.getEarliestTransactionDate();
        final now = DateTime.now();
        final effectiveStart = earliestDate ?? DateTime(now.year, 1, 1);
        final yearDiff = now.year - effectiveStart.year;

        if (yearDiff == 0) {
          // All transactions in the same year -> Show 12 months of this year
          final monthlyStats = await _db.transactionDao.getMonthlyStats(
            DateTime(now.year, 1, 1),
            DateTime(now.year, 12, 31, 23, 59, 59),
          );
          chartData = _processMonthlyStats(monthlyStats, now.year);
        } else if (yearDiff <= 2) {
          // 2-3 years -> Show all months across the years
          final startMonth = DateTime(
            effectiveStart.year,
            effectiveStart.month,
            1,
          );
          final endMonth = DateTime(now.year, 12, 31, 23, 59, 59);
          final monthlyStats = await _db.transactionDao.getMonthlyStats(
            startMonth,
            endMonth,
          );
          chartData = _processCustomMonthlyStats(
            monthlyStats,
            startMonth,
            endMonth,
          );
        } else {
          // More than 2 years -> Show yearly bars/points
          final yearlyStats = await _db.transactionDao.getYearlyStats(
            DateTime(effectiveStart.year, 1, 1),
            DateTime(now.year, 12, 31, 23, 59, 59),
          );
          chartData = _processYearlyStats(
            yearlyStats,
            effectiveStart.year,
            now.year,
          );
        }
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
          targetDate: anchor,
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

  List<ChartDataPoint> _processHourlyStats(
    List<TypedResult> stats,
    DateTime date,
  ) {
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    for (var row in stats) {
      final type = row.read<String>(_db.transactions.type);
      final hour = row.read<String>(
        _db.transactions.transactionDate.strftime('%H'),
      );
      final amount = row.read<double>(_db.transactions.amount.sum()) ?? 0;

      if (hour != null) {
        if (type == 'income') {
          incomeMap[hour] = amount;
        } else {
          expenseMap[hour] = amount;
        }
      }
    }

    List<ChartDataPoint> result = [];
    for (int h = 0; h < 24; h += 2) {
      final hourKey = h.toString().padLeft(2, '0');
      final nextHourKey = (h + 1).toString().padLeft(2, '0');
      final inc = (incomeMap[hourKey] ?? 0) + (incomeMap[nextHourKey] ?? 0);
      final exp = (expenseMap[hourKey] ?? 0) + (expenseMap[nextHourKey] ?? 0);
      final dt = DateTime(date.year, date.month, date.day, h);
      result.add(
        ChartDataPoint(
          date: dt,
          income: inc,
          expense: exp,
          customLabel: '$hourKey:00',
        ),
      );
    }
    return result;
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
    if (days <= 0) days = 1;

    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      result.add(
        ChartDataPoint(
          date: date,
          income: incomeMap[dateKey] ?? 0,
          expense: expenseMap[dateKey] ?? 0,
          customLabel: '${date.day}',
        ),
      );
    }
    return result;
  }

  List<ChartDataPoint> _processMonthlyStats(
    List<TypedResult> stats,
    int year,
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

    const monthNames = [
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

    List<ChartDataPoint> result = [];
    for (int i = 0; i < 12; i++) {
      final date = DateTime(year, i + 1, 1);
      final monthKey = "$year-${(i + 1).toString().padLeft(2, '0')}";
      result.add(
        ChartDataPoint(
          date: date,
          income: incomeMap[monthKey] ?? 0,
          expense: expenseMap[monthKey] ?? 0,
          customLabel: monthNames[i],
        ),
      );
    }
    return result;
  }

  List<ChartDataPoint> _processCustomMonthlyStats(
    List<TypedResult> stats,
    DateTime start,
    DateTime end,
  ) {
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

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

    const monthNames = [
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

    List<ChartDataPoint> result = [];
    DateTime curr = DateTime(start.year, start.month, 1);
    final stop = DateTime(end.year, end.month, 1);

    while (!curr.isAfter(stop)) {
      final monthKey = "${curr.year}-${curr.month.toString().padLeft(2, '0')}";
      final label = start.year == end.year
          ? monthNames[curr.month - 1]
          : "${monthNames[curr.month - 1]} '${curr.year.toString().substring(2)}";
      result.add(
        ChartDataPoint(
          date: curr,
          income: incomeMap[monthKey] ?? 0,
          expense: expenseMap[monthKey] ?? 0,
          customLabel: label,
        ),
      );
      curr = DateTime(curr.year, curr.month + 1, 1);
    }
    return result;
  }

  List<ChartDataPoint> _processYearlyStats(
    List<TypedResult> stats,
    int startYear,
    int endYear,
  ) {
    Map<String, double> incomeMap = {};
    Map<String, double> expenseMap = {};

    for (var row in stats) {
      final type = row.read<String>(_db.transactions.type);
      final yearExpr = row.read<String>(
        _db.transactions.transactionDate.strftime('%Y'),
      );
      final amount = row.read<double>(_db.transactions.amount.sum()) ?? 0;

      if (yearExpr != null) {
        if (type == 'income') {
          incomeMap[yearExpr] = amount;
        } else {
          expenseMap[yearExpr] = amount;
        }
      }
    }

    List<ChartDataPoint> result = [];
    for (int y = startYear; y <= endYear; y++) {
      final yearKey = y.toString();
      result.add(
        ChartDataPoint(
          date: DateTime(y, 1, 1),
          income: incomeMap[yearKey] ?? 0,
          expense: expenseMap[yearKey] ?? 0,
          customLabel: yearKey,
        ),
      );
    }
    return result;
  }
}
