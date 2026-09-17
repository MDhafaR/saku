import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/category_transactions_info_modal.dart';
import '../components/description_transactions_info_modal.dart';
import '../components/period_date_navigator.dart';
import '../components/time_period_selector.dart';
import '../cubit/statistics_state.dart';

enum CategorySortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}

extension CategorySortOptionExt on CategorySortOption {
  String get label {
    switch (this) {
      case CategorySortOption.dateDesc:
        return 'Terbaru';
      case CategorySortOption.dateAsc:
        return 'Terlama';
      case CategorySortOption.amountDesc:
        return 'Terbesar';
      case CategorySortOption.amountAsc:
        return 'Terkecil';
    }
  }

  String get description {
    switch (this) {
      case CategorySortOption.dateDesc:
        return 'Tanggal terbaru ke terlama';
      case CategorySortOption.dateAsc:
        return 'Tanggal terlama ke terbaru';
      case CategorySortOption.amountDesc:
        return 'Nominal pengeluaran tertinggi';
      case CategorySortOption.amountAsc:
        return 'Nominal pengeluaran terendah';
    }
  }

  IconData get icon {
    switch (this) {
      case CategorySortOption.dateDesc:
        return Icons.calendar_today_rounded;
      case CategorySortOption.dateAsc:
        return Icons.history_rounded;
      case CategorySortOption.amountDesc:
        return Icons.trending_up_rounded;
      case CategorySortOption.amountAsc:
        return Icons.trending_down_rounded;
    }
  }
}

class CategoryTransactionsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String iconName;
  final Color color;
  final double totalAmount;
  final double percentage;
  final String? trendValue;
  final bool isTrendUp;
  final String period;
  final DateTime targetDate;
  final AppDateTimeRange? customRange;
  final List<Transaction> initialTransactions;

  const CategoryTransactionsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.iconName,
    required this.color,
    required this.totalAmount,
    this.percentage = 0.0,
    this.trendValue,
    this.isTrendUp = false,
    this.period = 'Monthly',
    required this.targetDate,
    this.customRange,
    this.initialTransactions = const [],
  });

  @override
  State<CategoryTransactionsPage> createState() =>
      _CategoryTransactionsPageState();
}

class _CategoryTransactionsPageState extends State<CategoryTransactionsPage> {
  late Future<List<Transaction>> _transactionsFuture;
  CategorySortOption _selectedSort = CategorySortOption.dateDesc;
  late String _period;
  late DateTime _targetDate;
  AppDateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _period = widget.period;
    _targetDate = widget.targetDate;
    _customRange = widget.customRange;
    _loadTransactions();
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
      _transactionsFuture = locator<AppDatabase>()
          .transactionDao
          .getTransactionsByCategory(
            widget.categoryId,
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
              primary: widget.color,
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
      case CategorySortOption.dateDesc:
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        break;
      case CategorySortOption.dateAsc:
        list.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
        break;
      case CategorySortOption.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case CategorySortOption.amountAsc:
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
                  'Pilih prioritas tampilan data riwayat kategori ini',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 14.h),
                ...CategorySortOption.values.map((option) {
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
                              ? widget.color.withValues(alpha: 0.12)
                              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? widget.color
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
                                    ? widget.color.withValues(alpha: 0.2)
                                    : cs.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.icon,
                                size: 16.sp,
                                color: isSelected ? widget.color : cs.onSurfaceVariant,
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
                                      color: isSelected
                                          ? cs.onSurface
                                          : cs.onSurface,
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
                                color: widget.color,
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
          widget.categoryName,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          FutureBuilder<List<Transaction>>(
            future: _transactionsFuture,
            builder: (context, snapshot) {
              final txs = snapshot.data ?? [];
              final dynamicTotal = txs.fold<double>(0.0, (sum, tx) => sum + tx.amount);
              return IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: cs.onSurface,
                  size: 20.sp,
                ),
                onPressed: () {
                  CategoryTransactionsInfoModal.show(
                    context,
                    categoryName: widget.categoryName,
                    iconName: widget.iconName,
                    categoryColor: widget.color,
                    totalAmount: dynamicTotal,
                    percentage: widget.percentage,
                    trendValue: widget.trendValue,
                    isTrendUp: widget.isTrendUp,
                    transactions: txs,
                    period: _period,
                    targetDate: _targetDate,
                    customRange: _customRange,
                  );
                },
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
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
              return _buildTransactionItem(cs, tx, rawTxList);
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, List<Transaction> rawTxList) {
    final dynamicTotal = rawTxList.fold<double>(0.0, (sum, tx) => sum + tx.amount);

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
                  color: widget.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: CategoryIcon(
                  iconName: widget.iconName,
                  color: widget.color,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total ${widget.categoryName}',
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
                        CurrencyFormatter.formatRupiah(dynamicTotal),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
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
                color: widget.color,
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
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CategoryIcon(
                iconName: widget.iconName,
                size: 36.sp,
                color: widget.color,
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

  Widget _buildTransactionItem(
    ColorScheme cs,
    Transaction tx,
    List<Transaction> allCategoryTransactions,
  ) {
    final formattedDate =
        DateFormat('d MMMM yyyy', 'id_ID').format(tx.transactionDate);
    final targetDescription = tx.description.isNotEmpty
        ? tx.description
        : 'Transaksi ${widget.categoryName}';

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: SakuCard(
        margin: EdgeInsets.zero,
        onTap: () {
          DescriptionTransactionsInfoModal.show(
            context,
            description: targetDescription,
            categoryId: widget.categoryId,
            categoryName: widget.categoryName,
            iconName: widget.iconName,
            categoryColor: widget.color,
            categoryTotalAmount: widget.totalAmount,
            allCategoryTransactions: allCategoryTransactions,
            period: widget.period,
            targetDate: widget.targetDate,
            customRange: widget.customRange,
          );
        },
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: CategoryIcon(
                iconName: widget.iconName,
                color: cs.onSurfaceVariant,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description.isNotEmpty
                        ? tx.description
                        : 'Transaksi ${widget.categoryName}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '-${CurrencyFormatter.formatRupiah(tx.amount)}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
