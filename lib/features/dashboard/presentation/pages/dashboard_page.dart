import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/injection.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../components/components.dart' as components;
import '../components/filter_bottom_sheet.dart';
import '../components/transaction_section.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import '../widgets/financial_dashboard_summary.dart';

/// Dashboard page showing recent transactions and summary information.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  late final TransactionCubit _cubit;
  bool _isLoading = true;
  String _searchQuery = '';
  DashboardFilterResult _activeFilter = const DashboardFilterResult();
  List<Transaction> _allTransactions = const [];

  // Cache for categories and wallets
  Map<int, Category> _categoriesCache = {};
  Map<int, Wallet> _walletsCache = {};

  // Stream subscriptions to keep cache in sync
  StreamSubscription<List<Category>>? _categoriesSubscription;
  StreamSubscription<List<Wallet>>? _walletsSubscription;
  bool _categoriesReady = false;
  bool _walletsReady = false;

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = locator<TransactionCubit>();
    _startWatchingCategoriesAndWallets();
  }

  void _startWatchingCategoriesAndWallets() {
    final db = locator<AppDatabase>();

    // Watch all categories for real-time updates (icon changes, etc.)
    _categoriesSubscription = db.categoryDao.watchAllCategories().listen((
      categories,
    ) {
      if (mounted) {
        setState(() {
          _categoriesCache = {for (var c in categories) c.id: c};
          _categoriesReady = true;
        });
        _maybeStartTransactions();
      }
    });

    // Watch all wallets for real-time updates
    _walletsSubscription = db.walletDao.watchAllWallets().listen((wallets) {
      if (mounted) {
        setState(() {
          _walletsCache = {for (var w in wallets) w.id: w};
          _walletsReady = true;
        });
        _maybeStartTransactions();
      }
    });
  }

  void _maybeStartTransactions() {
    if (_categoriesReady && _walletsReady && _isLoading) {
      // Start listening to transactions only AFTER cache is ready
      if (!_cubit.isClosed) {
        _cubit.start();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _onFilterTap() {
    final maxSelectableAmount = _computeAmountUpperBound(_allTransactions);
    showModalBottomSheet<DashboardFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: FilterBottomSheet(
          initialFilter: _activeFilter,
          wallets: _walletsCache.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
          categories: _categoriesCache.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
          maxSelectableAmount: maxSelectableAmount,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _activeFilter = result;
        });
      }
    });
  }

  void _deleteTransaction(int id) async {
    await _cubit.deleteTransaction(id);
  }

  double _calculateIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> allTransactions) {
    final now = DateTime.now();
    final minimumDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 29));

    final filteredByDate = allTransactions.where((transaction) {
      switch (_activeFilter.dateRange) {
        case DashboardDateRange.last30Days:
          return !transaction.transactionDate.isBefore(minimumDate);
        case DashboardDateRange.customRange:
          if (_activeFilter.customStartDate == null ||
              _activeFilter.customEndDate == null) {
            return true;
          }
          final txDate = DateTime(
            transaction.transactionDate.year,
            transaction.transactionDate.month,
            transaction.transactionDate.day,
          );
          final startDate = DateTime(
            _activeFilter.customStartDate!.year,
            _activeFilter.customStartDate!.month,
            _activeFilter.customStartDate!.day,
          );
          final endDate = DateTime(
            _activeFilter.customEndDate!.year,
            _activeFilter.customEndDate!.month,
            _activeFilter.customEndDate!.day,
          );
          return !txDate.isBefore(startDate) && !txDate.isAfter(endDate);
        case DashboardDateRange.selectedMonth:
          return _isSameMonth(transaction.transactionDate, _selectedDate);
      }
    });

    return filteredByDate.where((transaction) {
      if (_activeFilter.transactionType == DashboardTransactionType.income &&
          transaction.type != 'income') {
        return false;
      }
      if (_activeFilter.transactionType == DashboardTransactionType.expense &&
          transaction.type != 'expense') {
        return false;
      }
      if (_activeFilter.walletId != null &&
          transaction.walletId != _activeFilter.walletId) {
        return false;
      }
      if (_activeFilter.categoryIds.isNotEmpty &&
          !_activeFilter.categoryIds.contains(transaction.categoryId)) {
        return false;
      }
      final hasAmountFilter = _activeFilter.amountUpperBound > 0 &&
          (_activeFilter.amountRange.start > 0 ||
              _activeFilter.amountRange.end < _activeFilter.amountUpperBound);
      if (hasAmountFilter &&
          (transaction.amount < _activeFilter.amountRange.start ||
              transaction.amount > _activeFilter.amountRange.end)) {
        return false;
      }

      if (_searchQuery.isEmpty) return true;

      final categoryName =
          _categoriesCache[transaction.categoryId]?.name.toLowerCase() ?? '';
      final walletName =
          _walletsCache[transaction.walletId]?.name.toLowerCase() ?? '';
      final description = transaction.description.toLowerCase();
      final note = (transaction.note ?? '').toLowerCase();
      final amountText = transaction.amount.toStringAsFixed(0);

      return categoryName.contains(_searchQuery) ||
          walletName.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          note.contains(_searchQuery) ||
          amountText.contains(_searchQuery);
    }).toList();
  }

  double _computeAmountUpperBound(List<Transaction> transactions) {
    final rawMax = transactions.fold<double>(
      0,
      (max, t) => t.amount > max ? t.amount : max,
    );
    if (rawMax <= 0) {
      return 1000000;
    }
    final padded = rawMax * 1.2;
    final digits = padded.floor().toString().length;
    final step = switch (digits) {
      <= 3 => 100.0,
      4 => 1000.0,
      5 => 10000.0,
      6 => 100000.0,
      7 => 1000000.0,
      _ => 10000000.0,
    };
    return (padded / step).ceil() * step;
  }

  String _buildFilterSummaryText() {
    final parts = <String>[];

    if (_activeFilter.transactionType == DashboardTransactionType.income) {
      parts.add('Pemasukan');
    } else if (_activeFilter.transactionType ==
        DashboardTransactionType.expense) {
      parts.add('Pengeluaran');
    }

    switch (_activeFilter.dateRange) {
      case DashboardDateRange.selectedMonth:
        break;
      case DashboardDateRange.last30Days:
        parts.add('30 hari terakhir');
        break;
      case DashboardDateRange.customRange:
        if (_activeFilter.customStartDate != null &&
            _activeFilter.customEndDate != null) {
          final format = DateFormat('dd MMM', 'id');
          parts.add(
            '${format.format(_activeFilter.customStartDate!)} - ${format.format(_activeFilter.customEndDate!)}',
          );
        }
        break;
    }

    if (_activeFilter.walletId != null) {
      final walletName = _walletsCache[_activeFilter.walletId!]?.name;
      if (walletName != null && walletName.isNotEmpty) {
        parts.add(walletName);
      }
    }

    if (_activeFilter.categoryIds.isNotEmpty) {
      parts.add('${_activeFilter.categoryIds.length} kategori');
    }

    if (_activeFilter.amountUpperBound > 0 &&
        (_activeFilter.amountRange.start > 0 ||
            _activeFilter.amountRange.end < _activeFilter.amountUpperBound)) {
      parts.add(
        'Nominal Rp ${CurrencyFormatter.format(_activeFilter.amountRange.start.toStringAsFixed(0))} - Rp ${CurrencyFormatter.format(_activeFilter.amountRange.end.toStringAsFixed(0))}',
      );
    }

    if (_searchQuery.isNotEmpty) {
      parts.add('Cari: "$_searchQuery"');
    }

    if (parts.isEmpty) {
      return 'Filter default: bulan dipilih';
    }

    return parts.join(' • ');
  }

  Widget _buildFilterSummary() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, size: 14.sp, color: const Color(0xFF4B5563)),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _buildFilterSummaryText(),
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonthYear() async {
    DateTime tempDate = DateTime(_selectedDate.year, _selectedDate.month);

    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Year navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year - 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_left,
                          color: const Color(0xFF111111),
                          size: 24.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<int>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 16.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.r),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 4.h,
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Pilih Tahun',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            childAspectRatio: 2.0,
                                            crossAxisSpacing: 8.w,
                                            mainAxisSpacing: 8.h,
                                          ),
                                      itemCount: 11, // 2020-2030
                                      itemBuilder: (ctx, i) {
                                        final year = 2020 + i;
                                        final isYearSelected =
                                            year == tempDate.year;
                                        return GestureDetector(
                                          onTap: () =>
                                              Navigator.of(ctx).pop(year),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isYearSelected
                                                  ? const Color(0xFF111111)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$year',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: isYearSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isYearSelected
                                                    ? Colors.white
                                                    : const Color(0xFF4B5563),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12.h),
                                  ],
                                ),
                              );
                            },
                          ).then((selectedYear) {
                            if (selectedYear != null) {
                              setModalState(() {
                                tempDate = DateTime(
                                  selectedYear,
                                  tempDate.month,
                                );
                              });
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tempDate.year}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_drop_down,
                              color: const Color(0xFF111111),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year + 1,
                              tempDate.month,
                            );
                          });
                        },
                        icon: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF111111),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Month grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == tempDate.month;

                      // Short month names in Indonesian
                      final monthNames = [
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

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempDate = DateTime(tempDate.year, month);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF111111)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monthNames[index],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempDate);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Pilih',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              List<Transaction> allTransactions = [];
              if (state is TransactionLoaded) {
                allTransactions = state.transactions;
              }
              _allTransactions = allTransactions;

              // Base for summary cards (month focused)
              final currentTransactions = allTransactions
                  .where((t) => _isSameMonth(t.transactionDate, _selectedDate))
                  .toList();
              final filteredTransactions = _getFilteredTransactions(
                allTransactions,
              );

              // Filter for previous month
              final prevDate = DateTime(
                _selectedDate.year,
                _selectedDate.month - 1,
              );
              final prevTransactions = allTransactions
                  .where((t) => _isSameMonth(t.transactionDate, prevDate))
                  .toList();

              final income = _calculateIncome(currentTransactions);
              final expense = _calculateExpense(currentTransactions);
              final total = income - expense;

              final prevIncome = _calculateIncome(prevTransactions);
              final prevExpense = _calculateExpense(prevTransactions);
              final prevTotal = prevIncome - prevExpense;

              return Column(
                children: [
                  // Fixed header section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildHeader(),

                        // Month navigation
                        components.MonthNavigation(
                          currentMonth:
                              '${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                          onPreviousMonth: _onPreviousMonth,
                          onNextMonth: _onNextMonth,
                          onMonthTap: _selectMonthYear,
                        ),

                        // Summary cards with real data
                        FinancialDashboardSummary(
                          income: income,
                          expense: expense,
                          total: total,
                          prevIncome: prevIncome,
                          prevExpense: prevExpense,
                          prevTotal: prevTotal,
                          isLoading: _isLoading,
                        ),

                        // Search bar
                        components.SearchBar(
                          onChanged: _onSearchChanged,
                          onFilterTap: _onFilterTap,
                          hasActiveFilter: _activeFilter.hasActiveFilters,
                        ),
                        if (_activeFilter.hasActiveFilters ||
                            _searchQuery.isNotEmpty)
                          _buildFilterSummary(),
                      ],
                    ),
                  ),

                  // Scrollable transaction sections
                  Expanded(
                    child: _buildTransactionList(state, filteredTransactions),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Saku',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.dark_mode_outlined,
            color: Colors.grey[600],
            size: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    TransactionState state,
    List<Transaction> transactions,
  ) {
    if (state is TransactionLoading ||
        state is TransactionInitial ||
        _isLoading) {
      return _buildSkeletonTransactions();
    }

    if (state is TransactionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Error loading transactions',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap tombol + untuk menambah transaksi',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    // Convert transactions to TransactionWithDetails
    final transactionsWithDetails = transactions.map((t) {
      return TransactionWithDetails(
        transaction: t,
        category: _categoriesCache[t.categoryId],
        wallet: _walletsCache[t.walletId],
      );
    }).toList();

    // Group by date
    final groupedTransactions = groupTransactionsByDate(
      transactionsWithDetails,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupedTransactions.entries.map(
            (entry) => TransactionSection(
              sectionTitle: entry.key,
              transactions: entry.value,
              onDeleteTransaction: _deleteTransaction,
            ),
          ),
          // Bottom padding for FAB
          SizedBox(height: 140.h),
        ],
      ),
    );
  }

  /// Builds skeleton placeholder items matching the TransactionItem layout
  Widget _buildSkeletonTransactions() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 24.h),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton section title
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 4 skeleton transaction items
            ...List.generate(4, (_) => _buildSkeletonItem()),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return SakuCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.category, color: Colors.blue, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Name',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Wallet Name',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-Rp 100.000',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD32F2F),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _walletsSubscription?.cancel();
    _cubit.close();
    super.dispose();
  }
}
