import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../dashboard/presentation/components/transaction_section.dart';
import '../../../dashboard/presentation/cubit/transaction_cubit.dart';
import '../../../../features/transactions/presentation/pages/transfer_page.dart';
import '../../../../features/transactions/presentation/pages/adjust_balance_page.dart';
import '../../../../features/transactions/presentation/pages/wallet_history_page.dart';
import 'add_edit_wallet_page.dart';

class WalletDetailPage extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailPage({super.key, required this.wallet});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late bool _isHidden;
  late final TransactionCubit _cubit;
  late final AppDatabase _db;
  StreamSubscription<List<Transaction>>? _subscription;

  List<Transaction> _transactions = [];
  Map<int, Category> _categoriesCache = {};
  Map<int, Wallet> _walletsCache = {};
  bool _isLoading = true;

  Wallet get _wallet => _walletsCache[widget.wallet.id] ?? widget.wallet;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.wallet.isHidden;
    _db = locator<AppDatabase>();
    _cubit = TransactionCubit(_db);
    _loadData();
  }

  Future<void> _loadData() async {
    // Load categories cache
    final expenseCategories = await _db.categoryDao.getExpenseCategories();
    final incomeCategories = await _db.categoryDao.getIncomeCategories();
    final allCategories = [...expenseCategories, ...incomeCategories];
    final wallets = await _db.walletDao.getAllWallets();

    setState(() {
      _categoriesCache = {for (var c in allCategories) c.id: c};
      _walletsCache = {for (var w in wallets) w.id: w};
    });

    // Watch transactions for this wallet
    _subscription?.cancel();
    _subscription = _db.transactionDao
        .watchTransactionsByWallet(widget.wallet.id)
        .listen((transactions) {
          setState(() {
            _transactions = transactions;
            _isLoading = false;
          });
        });
  }

  double _calculateIncome() {
    return _transactions
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateExpense() {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  void _toggleHideWallet() async {
    setState(() {
      _isHidden = !_isHidden;
    });
    await _db.walletDao.toggleHidden(widget.wallet.id, _isHidden);
  }

  void _deleteTransaction(int id) async {
    await _cubit.deleteTransaction(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final income = _calculateIncome();
    final expense = _calculateExpense();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Rekening',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
            onSelected: (value) async {
              if (value == 'hide') {
                _toggleHideWallet();
              } else if (value == 'edit') {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditWalletPage(wallet: _wallet),
                  ),
                );
                if (updated == true) {
                  _loadData();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Edit Rekening',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(
                      _isHidden ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 18.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      _isHidden ? 'Tampilkan Rekening' : 'Sembunyikan Rekening',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            _buildHeaderCard(),

            // Income/Expense Summary
            _buildSummaryCard(income, expense),

            // Transactions Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mutasi Terakhir',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Transaction List (Top 3 only)
            _buildTransactionList(),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final wallet = _wallet;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF1A1A1A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Color(wallet.iconColor),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: CategoryIcon(
                    iconName: wallet.icon,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          wallet.type.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        wallet.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditWalletPage(wallet: wallet),
                    ),
                  );
                  if (updated == true) {
                    _loadData();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Saldo Utama',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                Icons.arrow_outward,
                'Transfer',
                onTap: () async {
                  final wallets = await _db.walletDao.getAllWallets();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferPage(wallets: wallets),
                    ),
                  );
                },
              ),
              _buildActionButton(
                Icons.tune_rounded,
                'Ngepasin',
                onTap: () async {
                  final wallets = await _db.walletDao.getAllWallets();
                  if (!mounted) return;
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdjustBalancePage(
                        preselectedWallet: wallet,
                        wallets: wallets,
                      ),
                    ),
                  );
                  if (updated == true) {
                    _loadData();
                  }
                },
              ),
              _buildActionButton(
                Icons.history,
                'Riwayat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WalletHistoryPage(wallet: wallet),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryCard(double income, double expense) {
    return SakuCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      borderRadius: 16.r,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        size: 11.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Rp ${CurrencyFormatter.format(income.toStringAsFixed(0))}',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 32.h,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          size: 11.sp,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Rp ${CurrencyFormatter.format(expense.toStringAsFixed(0))}',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              SizedBox(height: 8.h),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Transaksi untuk rekening ini akan muncul di sini',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Limit to top 3 latest transactions
    final recentTransactions = _transactions.take(3).toList();

    // Convert to TransactionWithDetails
    final transactionsWithDetails = recentTransactions.map((t) {
      return TransactionWithDetails(
        transaction: t,
        category: _categoriesCache[t.categoryId],
        wallet: _walletsCache[t.walletId],
      );
    }).toList();

    // Group by date
    final grouped = groupTransactionsByDate(transactionsWithDetails);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...grouped.entries.map(
            (entry) => TransactionSection(
              sectionTitle: entry.key,
              transactions: entry.value,
              onDeleteTransaction: _deleteTransaction,
            ),
          ),
          if (_transactions.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WalletHistoryPage(wallet: widget.wallet),
                      ),
                    );
                  },
                  icon: Icon(Icons.history_rounded, size: 16.sp),
                  label: Text(
                    'Lihat Semua Riwayat (${_transactions.length})',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

