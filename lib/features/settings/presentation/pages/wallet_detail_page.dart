import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../dashboard/presentation/components/transaction_section.dart';
import '../../../dashboard/presentation/cubit/transaction_cubit.dart';
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF111111),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Rekening',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF111111)),
            onSelected: (value) {
              if (value == 'hide') {
                _toggleHideWallet();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(
                      _isHidden ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _isHidden ? 'Show Wallet' : 'Hide Wallet',
                      style: TextStyle(fontSize: 14.sp),
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
            // Blue Header Card
            _buildHeaderCard(),

            // Income/Expense Summary
            _buildSummaryCard(income, expense),

            // Transactions Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mutasi Terakhir',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Transaction List from Database
            _buildTransactionList(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  widget.wallet.type.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                widget.wallet.name,
                style: TextStyle(
                  color: const Color(0xFF111111),
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditWalletPage(wallet: widget.wallet),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: const Color(0xFF111111),
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Saldo Utama',
            style: TextStyle(
              color: const Color(0xFF111111).withOpacity(0.6),
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Rp ${CurrencyFormatter.format(widget.wallet.currentBalance.toStringAsFixed(0))}',
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.arrow_outward, 'Transfer'),
              _buildActionButton(
                Icons.history,
                'Riwayat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WalletHistoryPage(wallet: widget.wallet),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
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
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        size: 12.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Pemasukan',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  'Rp ${CurrencyFormatter.format(income.toStringAsFixed(0))}',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1.w, height: 36.h, color: Colors.grey[200]),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          size: 12.sp,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Rp ${CurrencyFormatter.format(expense.toStringAsFixed(0))}',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
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
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48.sp,
                color: Colors.grey[300],
              ),
              SizedBox(height: 12.h),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Transaksi untuk rekening ini akan muncul di sini',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    // Convert to TransactionWithDetails
    final transactionsWithDetails = _transactions.map((t) {
      return TransactionWithDetails(
        transaction: t,
        category: _categoriesCache[t.categoryId],
        wallet: _walletsCache[t.walletId],
      );
    }).toList();

    // Group by date
    final grouped = groupTransactionsByDate(transactionsWithDetails);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries
            .map(
              (entry) => TransactionSection(
                sectionTitle: entry.key,
                transactions: entry.value,
                onDeleteTransaction: _deleteTransaction,
              ),
            )
            .toList(),
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
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Icon(icon, color: const Color(0xFF111111), size: 18.sp),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
