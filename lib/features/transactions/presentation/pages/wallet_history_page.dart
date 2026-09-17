import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../dashboard/presentation/components/transaction_item.dart';
import '../../../dashboard/presentation/cubit/transaction_cubit.dart';
import '../../../statistics/presentation/components/period_date_navigator.dart';
import '../../../statistics/presentation/components/time_period_selector.dart';
import '../../../statistics/presentation/cubit/statistics_state.dart';

enum WalletSortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

extension WalletSortOptionExt on WalletSortOption {
  String get label {
    switch (this) {
      case WalletSortOption.dateDesc:
        return 'Terbaru';
      case WalletSortOption.dateAsc:
        return 'Terlama';
      case WalletSortOption.amountDesc:
        return 'Terbesar';
      case WalletSortOption.amountAsc:
        return 'Terkecil';
    }
  }

  String get description {
    switch (this) {
      case WalletSortOption.dateDesc:
        return 'Tanggal terbaru ke terlama';
      case WalletSortOption.dateAsc:
        return 'Tanggal terlama ke terbaru';
      case WalletSortOption.amountDesc:
        return 'Nominal transaksi tertinggi';
      case WalletSortOption.amountAsc:
        return 'Nominal transaksi terendah';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletSortOption.dateDesc:
        return Icons.calendar_today_rounded;
      case WalletSortOption.dateAsc:
        return Icons.history_rounded;
      case WalletSortOption.amountDesc:
        return Icons.trending_up_rounded;
      case WalletSortOption.amountAsc:
        return Icons.trending_down_rounded;
    }
  }
}

class WalletHistoryPage extends StatefulWidget {
  final Wallet wallet;
  final String period;
  final DateTime? targetDate;
  final AppDateTimeRange? customRange;

  const WalletHistoryPage({
    super.key,
    required this.wallet,
    this.period = 'Monthly',
    this.targetDate,
    this.customRange,
  });

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  late final AppDatabase _db;
  late final TransactionCubit _cubit;

  late Future<List<Transaction>> _transactionsFuture;
  WalletSortOption _selectedSort = WalletSortOption.dateDesc;
  late String _period;
  late DateTime _targetDate;
  AppDateTimeRange? _customRange;
  Map<int, Category> _categoriesCache = {};

  Color get _walletColor => Color(widget.wallet.iconColor);

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();
    _cubit = TransactionCubit(_db);
    _period = widget.period;
    _targetDate = widget.targetDate ?? DateTime.now();
    _customRange = widget.customRange;
    _loadTransactions();
    _loadCategories();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final expenseCategories = await _db.categoryDao.getExpenseCategories();
    final incomeCategories = await _db.categoryDao.getIncomeCategories();
    final allCategories = [...expenseCategories, ...incomeCategories];

    if (mounted) {
      setState(() {
        _categoriesCache = {for (var c in allCategories) c.id: c};
      });
    }
  }

  DateTimeRange _computeRange(
    String period,
    DateTime anchor,
    AppDateTimeRange? customRange,
  ) {
    DateTime start;
    DateTime end;
    switch (period.toLowerCase()) {
      case 'daily':
        start = DateTime(anchor.year, anchor.month, anchor.day);
        end = DateTime(anchor.year, anchor.month, anchor.day, 23, 59, 59);
        break;
      case 'monthly':
        start = DateTime(anchor.year, anchor.month, 1);
        final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
        end = DateTime(anchor.year, anchor.month, daysInMonth, 23, 59, 59);
        break;
      case 'yearly':
        start = DateTime(anchor.year, 1, 1);
        end = DateTime(anchor.year, 12, 31, 23, 59, 59);
        break;
      case 'custom':
        if (customRange != null) {
          start = customRange.start;
          end = DateTime(
            customRange.end.year,
            customRange.end.month,
            customRange.end.day,
            23,
            59,
            59,
          );
        } else {
          start = DateTime(anchor.year, anchor.month, 1);
          end = DateTime.now();
        }
        break;
      case 'all':
      default:
        start = DateTime(2000);
        end = DateTime.now();
        break;
    }
    return DateTimeRange(start: start, end: end);
  }

  void _loadTransactions() {
    final range = _computeRange(
      _period,
      _targetDate,
      _customRange,
    );
    setState(() {
      _transactionsFuture = _db.transactionDao.getTransactionsByWallet(
        widget.wallet.id,
        range.start,
        range.end,
      );
    });
  }

  Future<void> _openCustomDateRangePicker() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customRange != null
          ? DateTimeRange(start: _customRange!.start, end: _customRange!.end)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
      initialEntryMode: DatePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _walletColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _customRange = AppDateTimeRange(start: result.start, end: result.end);
        _period = 'Custom';
        _loadTransactions();
      });
    }
  }

  List<Transaction> _sortTransactions(List<Transaction> txList) {
    final list = List<Transaction>.from(txList);
    switch (_selectedSort) {
      case WalletSortOption.dateDesc:
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        break;
      case WalletSortOption.dateAsc:
        list.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
        break;
      case WalletSortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case WalletSortOption.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  void _showSortBottomSheet(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Text(
                  'Urutkan Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Pilih prioritas tampilan data riwayat rekening ini',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 14.h),
                ...WalletSortOption.values.map((option) {
                  final isSelected = _selectedSort == option;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSort = option;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _walletColor.withValues(alpha: 0.12)
                              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? _walletColor
                                : cs.outlineVariant.withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _walletColor.withValues(alpha: 0.2)
                                    : cs.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.icon,
                                size: 16.sp,
                                color: isSelected ? _walletColor : cs.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    option.description,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: _walletColor,
                                size: 20.sp,
                              )
                            else
                              Container(
                                width: 18.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.outlineVariant.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteTransaction(int id) async {
    await _cubit.deleteTransaction(id);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: cs.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.wallet.name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawTxList = snapshot.data ?? [];
          final txList = _sortTransactions(rawTxList);

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: rawTxList.isEmpty ? 2 : txList.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(cs, rawTxList);
              }
              if (rawTxList.isEmpty) {
                return _buildEmptyState(cs);
              }
              final tx = txList[index - 1];
              return TransactionItem(
                transaction: tx,
                category: _categoriesCache[tx.categoryId],
                wallet: widget.wallet,
                onDelete: () => _deleteTransaction(tx.id),
                onEdit: _loadTransactions,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, List<Transaction> rawTxList) {
    final dynamicIncome = rawTxList
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final dynamicExpense = rawTxList
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final dynamicNet = dynamicIncome - dynamicExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Period Selector
        TimePeriodSelector(
          selectedPeriod: _period,
          onPeriodChanged: (newPeriod) {
            setState(() {
              _period = newPeriod;
              _loadTransactions();
            });
          },
          onCustomDateSelected: (range) {
            setState(() {
              _customRange = AppDateTimeRange(start: range.start, end: range.end);
              _period = 'Custom';
              _loadTransactions();
            });
          },
        ),
        SizedBox(height: 8.h),

        // Period Date Navigator
        PeriodDateNavigator(
          period: _period,
          targetDate: _targetDate,
          customRange: _customRange,
          onDateChanged: (newDate) {
            setState(() {
              _targetDate = newDate;
              _loadTransactions();
            });
          },
          onCustomTap: _openCustomDateRangePicker,
        ),
        SizedBox(height: 10.h),

        // Total Summary Card
        SakuCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _walletColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: CategoryIcon(
                  iconName: widget.wallet.icon,
                  color: _walletColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Arus Kas',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dynamicNet >= 0
                            ? '+${CurrencyFormatter.formatRupiah(dynamicNet)}'
                            : '-${CurrencyFormatter.formatRupiah(dynamicNet.abs())}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: dynamicNet > 0
                              ? const Color(0xFF10B981)
                              : dynamicNet < 0
                                  ? const Color(0xFFEF4444)
                                  : cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  '${rawTxList.length} Transaksi',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Section Title with Filter/Sort button opposite to it
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            if (rawTxList.isNotEmpty) _buildSortFilterButton(cs),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildSortFilterButton(ColorScheme cs) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSortBottomSheet(context, cs),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _selectedSort.icon,
                size: 13.sp,
                color: _walletColor,
              ),
              SizedBox(width: 5.w),
              Text(
                _selectedSort.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14.sp,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: _walletColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CategoryIcon(
                iconName: widget.wallet.icon,
                size: 36.sp,
                color: _walletColor,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Tidak ada transaksi pada periode ${_period == 'All' ? 'keseluruhan' : _period.toLowerCase()}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
