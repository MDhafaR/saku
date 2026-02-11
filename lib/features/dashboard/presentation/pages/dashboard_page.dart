import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../../core/presentation/components/financial_summary_card.dart';
import '../components/components.dart' as components;
import '../components/filter_bottom_sheet.dart';
import '../components/transaction_section.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

/// Dashboard page showing recent transactions and summary information.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();
  late final TransactionCubit _cubit;

  // Cache for categories and wallets
  Map<int, Category> _categoriesCache = {};
  Map<int, Wallet> _walletsCache = {};

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
    _cubit.start();
    _loadCategoriesAndWallets();
  }

  Future<void> _loadCategoriesAndWallets() async {
    final db = locator<AppDatabase>();

    // Load all categories
    final expenseCategories = await db.categoryDao.getExpenseCategories();
    final incomeCategories = await db.categoryDao.getIncomeCategories();
    final allCategories = [...expenseCategories, ...incomeCategories];

    // Load all wallets
    final wallets = await db.walletDao.getAllWallets();

    setState(() {
      _categoriesCache = {for (var c in allCategories) c.id: c};
      _walletsCache = {for (var w in wallets) w.id: w};
    });
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
    // TODO: Implement search logic
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: const FilterBottomSheet(),
      ),
    );
  }

  void _deleteTransaction(int id) async {
    await _cubit.deleteTransaction(id);
    // Reload cache after deletion (wallet balance might have changed)
    _loadCategoriesAndWallets();
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

  String _formatPercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? '+100%' : '0%';
    final change = ((current - previous) / previous) * 100;
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

              // Filter for current month
              final currentTransactions = allTransactions
                  .where((t) => _isSameMonth(t.transactionDate, _selectedDate))
                  .toList();

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
                        _buildSummaryCards(
                          income,
                          expense,
                          total,
                          prevIncome,
                          prevExpense,
                          prevTotal,
                        ),

                        // Search bar
                        components.SearchBar(
                          onChanged: _onSearchChanged,
                          onFilterTap: _onFilterTap,
                        ),
                      ],
                    ),
                  ),

                  // Scrollable transaction sections
                  Expanded(
                    child: _buildTransactionList(state, currentTransactions),
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

  Widget _buildSummaryCards(
    double income,
    double expense,
    double total,
    double prevIncome,
    double prevExpense,
    double prevTotal,
  ) {
    return Row(
      children: [
        Expanded(
          child: FinancialSummaryCard(
            title: 'Income',
            amount: 'Rp ${CurrencyFormatter.format(income.toStringAsFixed(0))}',
            percentage: _formatPercentage(income, prevIncome),
            percentageColor: _getPercentageColor(income, prevIncome),
            icon: Icons.trending_up,
            iconColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFF10B981),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: FinancialSummaryCard(
            title: 'Expense',
            amount:
                'Rp ${CurrencyFormatter.format(expense.toStringAsFixed(0))}',
            percentage: _formatPercentage(expense, prevExpense),
            percentageColor: _getPercentageColor(
              expense,
              prevExpense,
              invert: true,
            ),
            icon: Icons.trending_down,
            iconColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFEF4444),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: FinancialSummaryCard(
            title: 'Total',
            amount:
                'Rp ${CurrencyFormatter.format(total.abs().toStringAsFixed(0))}',
            percentage: _formatPercentage(total, prevTotal),
            percentageColor: _getPercentageColor(total, prevTotal),
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF6366F1),
            backgroundColor: const Color(0xFF6366F1),
            amountColor: total >= 0
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    TransactionState state,
    List<Transaction> transactions,
  ) {
    if (state is TransactionLoading) {
      return const Center(child: CircularProgressIndicator());
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
