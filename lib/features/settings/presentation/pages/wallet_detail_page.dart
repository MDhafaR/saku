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
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24.r),
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
                          horizontal: 6.w,
                          vertical: 3.h,
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
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        widget.account.name,
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 12.sp,
                        ),
                      ),
                      const Spacer(),
                      Container(
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
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        '5220 •••• 1234',
                        style: TextStyle(
                          color: const Color(0xFF111111).withOpacity(0.8),
                          fontSize: 13.sp,
                          letterSpacing: 1.w,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.copy,
                        color: const Color(0xFF111111).withOpacity(0.8),
                        size: 14.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Saldo Utama',
                    style: TextStyle(
                      color: const Color(0xFF111111).withOpacity(0.6),
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Rp ${_formatCurrency(widget.account.balance)}',
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
                      _buildActionButton(Icons.tune, 'Atur Saldo'),
                      _buildActionButton(Icons.history, 'Riwayat'),
                    ],
                  ),
                ],
              ),
            ),

            // Income/Expense Summary
            Container(
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
                          'Rp 8.500.000',
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
                            'Rp 4.200.000',
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
            ),

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

            // Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: const Color(0xFF9CA3AF),
                    size: 18.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Cari transaksi (cth: Netflix)...',
                    style: TextStyle(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

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
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6), // Light Gray
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF111111), size: 18.sp),
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

  Widget _buildTransactionItem(
    String title,
    String date,
    String amount,
    IconData icon,
    Color iconColor, {
    bool isIncome = false,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildTransactionBottomSheet(
            title: title,
            date: date,
            amount: amount,
            icon: icon,
            iconColor: iconColor,
            isIncome: isIncome,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: isIncome
                    ? const Color(0xFF10B981)
                    : const Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionBottomSheet({
    required String title,
    required String date,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required bool isIncome,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row - Icon left, details right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: iconColor, size: 26.sp),
              ),
              SizedBox(width: 14.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Amount Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        Text(
                          amount,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: isIncome
                                ? const Color(0xFF10B981)
                                : const Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Date & Method Row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 3.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 12.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.account.name,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Description Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Text(
              "Transaction details for $title",
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF444444),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    overlayColor: Colors.grey[100],
                  ),
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
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
