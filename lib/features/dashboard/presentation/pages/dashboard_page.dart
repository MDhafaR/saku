import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
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
  String _currentMonth = 'Februari 2026';
  late final TransactionCubit _cubit;

  // Cache for categories and wallets
  Map<int, Category> _categoriesCache = {};
  Map<int, Wallet> _walletsCache = {};

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
    // TODO: Implement previous month logic
  }

  void _onNextMonth() {
    // TODO: Implement next month logic
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, state) {
              List<Transaction> transactions = [];
              if (state is TransactionLoaded) {
                transactions = state.transactions;
              }

              final income = _calculateIncome(transactions);
              final expense = _calculateExpense(transactions);
              final total = income - expense;

              return Column(
                children: [
                  // Fixed header section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with app name and theme toggle
                        _buildHeader(),
                        SizedBox(height: 4.h),

                        // Month navigation
                        components.MonthNavigation(
                          currentMonth: _currentMonth,
                          onPreviousMonth: _onPreviousMonth,
                          onNextMonth: _onNextMonth,
                        ),

                        // Summary cards with real data
                        _buildSummaryCards(income, expense, total),

                        // Search bar
                        components.SearchBar(
                          onChanged: _onSearchChanged,
                          onFilterTap: _onFilterTap,
                        ),
                      ],
                    ),
                  ),

                  // Scrollable transaction sections
                  Expanded(child: _buildTransactionList(state, transactions)),
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

  Widget _buildSummaryCards(double income, double expense, double total) {
    return Row(
      children: [
        components.SummaryCard(
          title: 'Income',
          amount: 'Rp ${CurrencyFormatter.format(income.toStringAsFixed(0))}',
          icon: Icons.arrow_upward,
          iconColor: Colors.green[700]!,
          backgroundColor: Colors.green[100]!,
        ),
        SizedBox(width: 12.w),
        components.SummaryCard(
          title: 'Expense',
          amount: 'Rp ${CurrencyFormatter.format(expense.toStringAsFixed(0))}',
          icon: Icons.arrow_downward,
          iconColor: Colors.red[700]!,
          backgroundColor: Colors.red[100]!,
        ),
        SizedBox(width: 12.w),
        components.SummaryCard(
          title: 'Total',
          amount:
              'Rp ${CurrencyFormatter.format(total.abs().toStringAsFixed(0))}',
          icon: Icons.account_balance_wallet,
          iconColor: Colors.purple[700]!,
          backgroundColor: Colors.purple[100]!,
          textColor: total >= 0 ? Colors.green[700]! : Colors.red[700]!,
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
