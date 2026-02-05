import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../domain/entities/account.dart';

class WalletDetailPage extends StatefulWidget {
  final Account account;
  final Function(Account) onUpdate;

  const WalletDetailPage({
    super.key,
    required this.account,
    required this.onUpdate,
  });

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late bool _isHidden;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.account.isHidden;
  }

  void _toggleHideWallet() {
    setState(() {
      _isHidden = !_isHidden;
    });

    // Create updated account
    final updatedAccount = Account(
      id: widget.account.id,
      name: widget.account.name,
      type: widget.account.type,
      balance: widget.account.balance,
      iconPath: widget.account.iconPath,
      iconColor: widget.account.iconColor,
      isHidden: _isHidden,
    );

    widget.onUpdate(
      updatedAccount,
    ); // Context might be issue if popped? No, just callback.
  }

  @override
  Widget build(BuildContext context) {
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
            fontSize: 18.sp,
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30.r),
                ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          widget.account.type.toUpperCase(), // e.g. BCA
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        widget.account.name,
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 14.sp,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: const Color(0xFF111111),
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Text(
                        '5220 •••• 1234',
                        style: TextStyle(
                          color: const Color(0xFF111111).withOpacity(0.8),
                          fontSize: 16.sp,
                          letterSpacing: 1.w,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.copy,
                        color: const Color(0xFF111111).withOpacity(0.8),
                        size: 16.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Saldo Utama',
                    style: TextStyle(
                      color: const Color(0xFF111111).withOpacity(0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Rp ${_formatCurrency(widget.account.balance)}',
                    style: TextStyle(
                      color: const Color(0xFF111111),
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.arrow_outward, 'Transfer'),
                      _buildActionButton(Icons.tune, 'Atur Saldo'),
                      _buildActionButton(Icons.history, 'Riwayat'),
                    ],
                  ),
                ],
              ),
            ),

            // Income/Expense Summary
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                            SizedBox(width: 6.w),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Rp 8.500.000',
                          style: TextStyle(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1.w, height: 40.h, color: Colors.grey[200]),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  size: 12.sp,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Rp 4.200.000',
                            style: TextStyle(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mutasi Terakhir',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Cari transaksi (cth: Netflix)...',
                    style: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Transaction List (Mock)
            _buildTransactionItem(
              'Netflix Subscription',
              'Hari ini, 09:41',
              '-Rp 186.000',
              Icons.movie,
              Colors.black,
            ),
            _buildTransactionItem(
              'Starbucks Coffee',
              'Kemarin',
              '-Rp 55.000',
              Icons.coffee,
              Colors.green,
            ),
            _buildTransactionItem(
              'Transfer dari Budi',
              '10 Jan 2024',
              '+Rp 500.000',
              Icons.account_balance_wallet,
              Colors.green,
              isIncome: true,
            ),
            _buildTransactionItem(
              'Indomaret Point',
              '08 Jan 2024',
              '-Rp 120.000',
              Icons.shopping_bag,
              Colors.blue,
            ),
            _buildTransactionItem(
              'Uniqlo Indonesia',
              '05 Jan 2024',
              '-Rp 899.000',
              Icons.checkroom,
              Colors.red,
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6), // Light Gray
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF111111), size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    IconData icon,
    Color iconColor, {
    bool isIncome = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: const Color(0xFF111111),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: isIncome
                  ? const Color(0xFF10B981)
                  : const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple formatter for now, better to use NumberFormat
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
