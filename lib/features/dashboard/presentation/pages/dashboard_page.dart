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
import '../../../settings/presentation/cubit/theme_cubit.dart';

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
  List<TransactionWithDetails> _allItems = const [];

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
    final maxSelectableAmount = _computeAmountUpperBound(_allItems);
    showModalBottomSheet<DashboardFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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

  void _deleteTransfer(int id) async {
    await _cubit.deleteTransfer(id);
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  List<TransactionWithDetails> _getFilteredItems(
    List<TransactionWithDetails> allItems,
  ) {
    final now = DateTime.now();
    final minimumDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 29));

    final filteredByDate = allItems.where((item) {
      switch (_activeFilter.dateRange) {
        case DashboardDateRange.last30Days:
          return !item.date.isBefore(minimumDate);
        case DashboardDateRange.customRange:
          if (_activeFilter.customStartDate == null ||
              _activeFilter.customEndDate == null) {
            return true;
          }
          final itemDate = DateTime(
            item.date.year,
            item.date.month,
            item.date.day,
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
          return !itemDate.isBefore(startDate) && !itemDate.isAfter(endDate);
        case DashboardDateRange.selectedMonth:
          return _isSameMonth(item.date, _selectedDate);
      }
    });

    return filteredByDate.where((item) {
      if (_activeFilter.transactionTypes.isNotEmpty &&
          _activeFilter.transactionTypes.length < 3 &&
          !_activeFilter.transactionTypes.contains(item.type)) {
        return false;
      }
      if (_activeFilter.walletIds.isNotEmpty) {
        if (item.isTransfer) {
          final fromId = item.transfer?.fromWalletId;
          final toId = item.transfer?.toWalletId;
          final matchesFrom =
              fromId != null && _activeFilter.walletIds.contains(fromId);
          final matchesTo =
              toId != null && _activeFilter.walletIds.contains(toId);
          if (!matchesFrom && !matchesTo) return false;
        } else {
          final wId = item.transaction?.walletId;
          if (wId == null || !_activeFilter.walletIds.contains(wId)) {
            return false;
          }
        }
      }
      if (_activeFilter.categoryIds.isNotEmpty) {
        if (item.isTransfer) return false;
        final cId = item.transaction?.categoryId;
        if (cId == null || !_activeFilter.categoryIds.contains(cId)) {
          return false;
        }
      }
      final hasAmountFilter =
          _activeFilter.amountUpperBound > 0 &&
          (_activeFilter.amountRange.start > 0 ||
              _activeFilter.amountRange.end < _activeFilter.amountUpperBound);
      if (hasAmountFilter &&
          (item.amount < _activeFilter.amountRange.start ||
              item.amount > _activeFilter.amountRange.end)) {
        return false;
      }

      if (_searchQuery.isEmpty) return true;

      if (item.isTransfer) {
        final transfer = item.transfer!;
        final fromWalletName =
            _walletsCache[transfer.fromWalletId]?.name.toLowerCase() ?? '';
        final toWalletName =
            _walletsCache[transfer.toWalletId]?.name.toLowerCase() ?? '';
        final desc = transfer.description.toLowerCase();
        final amountText = transfer.amount.toStringAsFixed(0);

        return 'transfer'.contains(_searchQuery) ||
            'pindah'.contains(_searchQuery) ||
            fromWalletName.contains(_searchQuery) ||
            toWalletName.contains(_searchQuery) ||
            desc.contains(_searchQuery) ||
            amountText.contains(_searchQuery);
      } else {
        final transaction = item.transaction!;
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
      }
    }).toList();
  }

  double _computeAmountUpperBound(List<TransactionWithDetails> items) {
    final rawMax = items.fold<double>(
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

    if (_activeFilter.transactionTypes.isNotEmpty &&
        _activeFilter.transactionTypes.length < 3) {
      final types = <String>[];
      if (_activeFilter.transactionTypes.contains('income')) {
        types.add('Pemasukan');
      }
      if (_activeFilter.transactionTypes.contains('expense')) {
        types.add('Pengeluaran');
      }
      if (_activeFilter.transactionTypes.contains('transfer')) {
        types.add('Transfer');
      }
      parts.add(types.join(', '));
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

    if (_activeFilter.walletIds.isNotEmpty) {
      if (_activeFilter.walletIds.length == 1) {
        final walletName = _walletsCache[_activeFilter.walletIds.first]?.name;
        if (walletName != null && walletName.isNotEmpty) {
          parts.add(walletName);
        }
      } else {
        parts.add('${_activeFilter.walletIds.length} Dompet');
      }
    }

    if (_activeFilter.categoryIds.isNotEmpty) {
      parts.add('${_activeFilter.categoryIds.length} Kategori');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 14.sp,
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _buildFilterSummaryText(),
              style: TextStyle(
                fontSize: 11.sp,
                color: cs.onSurface.withValues(alpha: 0.6),
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
        final cs = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: cs.surface,
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
                          color: cs.onSurface,
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
                                  color: cs.surface,
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
                                        color: cs.onSurface.withValues(
                                          alpha: 0.2,
                                        ),
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
                                        color: cs.onSurface,
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
                                                  ? cs.onSurface
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
                                                    ? cs.surface
                                                    : cs.onSurface.withValues(
                                                        alpha: 0.6,
                                                      ),
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
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_drop_down,
                              color: cs.onSurface,
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
                          color: cs.onSurface,
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
                                ? cs.onSurface
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
                                  ? cs.surface
                                  : cs.onSurface.withValues(alpha: 0.6),
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
                        backgroundColor: cs.onSurface,
                        foregroundColor: cs.surface,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              List<TransactionWithDetails> allItems = [];
              if (state is TransactionLoaded) {
                final txItems = state.transactions.map((t) {
                  return TransactionWithDetails(
                    transaction: t,
                    category: _categoriesCache[t.categoryId],
                    wallet: _walletsCache[t.walletId],
                  );
                });
                final trItems = state.transfers.map((tr) {
                  return TransactionWithDetails(
                    transfer: tr,
                    wallet: _walletsCache[tr.fromWalletId],
                    toWallet: _walletsCache[tr.toWalletId],
                  );
                });
                allItems = [...txItems, ...trItems];
              }
              _allItems = allItems;

              final filteredItems = _getFilteredItems(
                allItems,
              );

              return Column(
                children: [
                  // Fixed header section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        _buildHeader(),

                        // Month navigation
                        components.MonthNavigation(
                          currentMonth:
                              '${_months[_selectedDate.month - 1]} ${_selectedDate.year}',
                          onPreviousMonth: _onPreviousMonth,
                          onNextMonth: _onNextMonth,
                          onMonthTap: _selectMonthYear,
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
                    child: _buildTransactionList(state, filteredItems),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Saku',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? colorScheme.onSurfaceVariant : Colors.grey[600],
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    TransactionState state,
    List<TransactionWithDetails> items,
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

    if (items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      );
    }

    // Group by date
    final groupedTransactions = groupTransactionsByDate(
      items,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupedTransactions.entries.map(
            (entry) => TransactionSection(
              sectionTitle: entry.key,
              transactions: entry.value,
              onDeleteTransaction: _deleteTransaction,
              onDeleteTransfer: _deleteTransfer,
            ),
          ),
          // Bottom padding for FAB
          SizedBox(height: 120.h),
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
