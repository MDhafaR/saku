import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import 'transaction_item.dart';

/// A grouped section of transactions by date
class TransactionSection extends StatelessWidget {
  final String sectionTitle;
  final List<TransactionWithDetails> transactions;
  final Function(int transactionId)? onDeleteTransaction;
  final Function(int transferId)? onDeleteTransfer;

  const TransactionSection({
    super.key,
    required this.sectionTitle,
    required this.transactions,
    this.onDeleteTransaction,
    this.onDeleteTransfer,
  });

  double get _dailyTotal {
    double total = 0.0;
    for (final item in transactions) {
      if (item.isTransfer) {
        if (item.transfer != null && item.transfer!.fee > 0) {
          total -= item.transfer!.fee;
        }
      } else if (item.transaction?.type == 'income') {
        total += item.transaction!.amount;
      } else if (item.transaction?.type == 'expense') {
        total -= item.transaction!.amount;
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
              transfer: item.transfer,
              category: item.category,
              wallet: item.wallet,
              toWallet: item.toWallet,
              onDelete: () {
                if (item.isTransfer && item.transfer != null) {
                  onDeleteTransfer?.call(item.transfer!.id);
                } else if (item.transaction != null) {
                  onDeleteTransaction?.call(item.transaction!.id);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to hold transaction or transfer with its related category and wallet(s)
class TransactionWithDetails {
  final Transaction? transaction;
  final Transfer? transfer;
  final Category? category;
  final Wallet? wallet;
  final Wallet? toWallet;

  TransactionWithDetails({
    this.transaction,
    this.transfer,
    this.category,
    this.wallet,
    this.toWallet,
  }) : assert(transaction != null || transfer != null);

  bool get isTransfer => transfer != null;
  DateTime get date => isTransfer ? transfer!.transferDate : transaction!.transactionDate;
  double get amount => isTransfer ? transfer!.amount : transaction!.amount;
  String get type => isTransfer ? 'transfer' : transaction!.type;
}

/// Groups transactions and transfers by date (Today, Yesterday, or formatted date)
Map<String, List<TransactionWithDetails>> groupTransactionsByDate(
  List<TransactionWithDetails> transactions, [
  AppLocalizations? l10n,
]) {
  final Map<String, List<TransactionWithDetails>> grouped = {};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final todayLabel = l10n?.today ?? 'Hari Ini';
  final yesterdayLabel = l10n?.yesterday ?? 'Kemarin';
  final dateLocale = l10n?.dateLocaleCode ?? 'id';

  // Sort items newest first by date
  final sorted = List<TransactionWithDetails>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  for (final item in sorted) {
    final itemDay = DateTime(
      item.date.year,
      item.date.month,
      item.date.day,
    );

    String key;
    if (itemDay == today) {
      key = todayLabel;
    } else if (itemDay == yesterday) {
      key = yesterdayLabel;
    } else {
      key = DateFormat(
        'dd MMMM yyyy',
        dateLocale,
      ).format(item.date);
    }

    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(item);
  }

  return grouped;
}
