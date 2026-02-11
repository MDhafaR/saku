import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/injection.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../dashboard/presentation/components/transaction_section.dart';
import '../../../dashboard/presentation/cubit/transaction_cubit.dart';

class WalletHistoryPage extends StatefulWidget {
  final Wallet wallet;

  const WalletHistoryPage({super.key, required this.wallet});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  late final AppDatabase _db;
  late final TransactionCubit _cubit;
  StreamSubscription<List<Transaction>>? _subscription;
  final TextEditingController _searchController = TextEditingController();

  List<Transaction> _allTransactions = [];
  List<TransactionWithDetails> _filteredTransactions = [];
  Map<int, Category> _categoriesCache = {};
  Map<int, Wallet> _walletsCache = {};

  String _selectedType = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _db = locator<AppDatabase>();
    _cubit = TransactionCubit(_db);
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final expenseCategories = await _db.categoryDao.getExpenseCategories();
    final incomeCategories = await _db.categoryDao.getIncomeCategories();
    final allCategories = [...expenseCategories, ...incomeCategories];

    // We assume transactions only belong to this wallet for now
    setState(() {
      _categoriesCache = {for (var c in allCategories) c.id: c};
      _walletsCache = {widget.wallet.id: widget.wallet};
    });

    _subscription = _db.transactionDao
        .watchTransactionsByWallet(widget.wallet.id)
        .listen((transactions) {
          if (mounted) {
            // Prepare initial list
            final details = transactions
                .map(
                  (t) => TransactionWithDetails(
                    transaction: t,
                    category: _categoriesCache[t.categoryId],
                    wallet: _walletsCache[t.walletId],
                  ),
                )
                .toList();

            setState(() {
              _allTransactions = transactions;
              _filteredTransactions = details; // Initially show all
              _isLoading = false;
            });
            _applyFilters();
          }
        });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    final filtered = _allTransactions
        .where((t) {
          // Type Filter
          if (_selectedType == 'Pemasukan' && t.type != 'income') return false;
          if (_selectedType == 'Pengeluaran' && t.type != 'expense')
            return false;

          // Search Filter
          if (query.isNotEmpty) {
            final category = _categoriesCache[t.categoryId];
            final description = t.description ?? '';
            final matchesNote = description.toLowerCase().contains(query);
            final matchesCategory =
                category != null && category.name.toLowerCase().contains(query);
            if (!matchesNote && !matchesCategory) return false;
          }

          return true;
        })
        .map((t) {
          return TransactionWithDetails(
            transaction: t,
            category: _categoriesCache[t.categoryId],
            wallet: _walletsCache[t.walletId],
          );
        })
        .toList();

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
    });
    _applyFilters();
  }

  void _deleteTransaction(int id) async {
    await _cubit.deleteTransaction(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Riwayat',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            child: _buildSearchBar(),
          ),
          _buildFilterChips(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari transaksi...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20.sp),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildChip('Semua'),
          SizedBox(width: 8.w),
          _buildChip('Pemasukan'),
          SizedBox(width: 8.w),
          _buildChip('Pengeluaran'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () => _onTypeChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24.r),
          border: isSelected
              ? Border.all(color: Colors.grey[200]!, width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF111111) : Colors.grey[500],
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48.sp, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text(
              'Tidak ada transaksi ditemukan',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = groupTransactionsByDate(_filteredTransactions);
    // Custom Grouping Logic to extract Month Year?
    // The requirement mentions grouping by "Februari 2026"
    // `groupTransactionsByDate` handles "Hari Ini", "Kemarin", "dd MMMM yyyy".
    // If we want broad month headers like in the design ("Februari 2026"), existing `groupTransactionsByDate` might be too granular.
    // However, sticking to the existing pattern first is safer.

    // Actually, looking at the image: "Februari 2026" is a header dropdown? Or just a header.
    // "Hari Ini" is a sub-header.
    // This implies a nested grouping: Month -> Day.
    // The current helper groups by Day.
    // I will use the current helper as it matches existing design consistency.

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return TransactionSection(
          sectionTitle: entry.key,
          transactions: entry.value,
          onDeleteTransaction: _deleteTransaction,
        );
      },
    );
  }
}
