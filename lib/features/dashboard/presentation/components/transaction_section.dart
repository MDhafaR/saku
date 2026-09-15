import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import 'transaction_item.dart';

/// A grouped section of transactions by date
class TransactionSection extends StatelessWidget {
  final String sectionTitle;
  final List<TransactionWithDetails> transactions;
  final Function(int transactionId)? onDeleteTransaction;

  const TransactionSection({
    super.key,
    required this.sectionTitle,
    required this.transactions,
    this.onDeleteTransaction,
  });

  double get _dailyTotal {
    double total = 0.0;
    for (final item in transactions) {
      if (item.transaction.type == 'income') {
        total += item.transaction.amount;
      } else {
        total -= item.transaction.amount;
      }
    }
    return total;
  }

  String get _formattedDailyTotal {
    final total = _dailyTotal;
    final formatted = CurrencyFormatter.format(total.abs().toStringAsFixed(0));
    if (total < 0) {
      return '-Rp $formatted';
    } else if (total > 0) {
      return 'Rp $formatted';
    } else {
      return 'Rp 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  sectionTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formattedDailyTotal,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          ...transactions.map(
            (item) => TransactionItem(
              transaction: item.transaction,
              category: item.category,
              wallet: item.wallet,
              onDelete: () => onDeleteTransaction?.call(item.transaction.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to hold transaction with its related category and wallet
class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final Wallet? wallet;

  TransactionWithDetails({
    required this.transaction,
    this.category,
    this.wallet,
  });
}

/// Groups transactions by date (Today, Yesterday, or formatted date)
Map<String, List<TransactionWithDetails>> groupTransactionsByDate(
  List<TransactionWithDetails> transactions,
) {
  final Map<String, List<TransactionWithDetails>> grouped = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final item in transactions) {
    final transactionDay = DateTime(
      item.transaction.transactionDate.year,
      item.transaction.transactionDate.month,
      item.transaction.transactionDate.day,
    );

    String key;
    if (transactionDay == today) {
      key = 'Hari Ini';
    } else if (transactionDay == yesterday) {
      key = 'Kemarin';
    } else {
      key = DateFormat(
        'dd MMMM yyyy',
        'id',
      ).format(item.transaction.transactionDate);
    }

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(item);
  }

  return grouped;
}
