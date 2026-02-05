import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';

class CategoryTransactionsPage extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> transactions;
  final String? totalAmount;

  const CategoryTransactionsPage({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.transactions,
    this.totalAmount,
  });

  String _calculateTotal() {
    if (totalAmount != null) return totalAmount!;

    // Calculate from transactions if not provided
    int total = 0;
    for (final tx in transactions) {
      final amountStr = tx['amount'] as String? ?? '0';
      // Parse amount like "-Rp85.000" -> 85000
      final cleanAmount = amountStr.replaceAll(RegExp(r'[^\d]'), '');
      total += int.tryParse(cleanAmount) ?? 0;
    }

    // Format to Rupiah
    final formatted = total.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF1F2937),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111111),
          ),
        ),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: transactions.length + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }
                final tx = transactions[index - 1];
                return _buildTransactionItem(
                  context,
                  tx,
                  index == transactions.length,
                );
              },
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Total Summary Card
        SakuCard(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total $categoryName',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _calculateTotal(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${transactions.length} Transaksi',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        // Section Title
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48.sp, color: color),
          ),
          SizedBox(height: 24.h),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Transaksi untuk kategori $categoryName\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> tx,
    bool isLast,
  ) {
    final txIcon = tx['icon'] as IconData? ?? icon;
    final txName = tx['name'] as String? ?? 'Transaksi';
    final txDate = tx['date'] as String? ?? '';
    final txAmount = tx['amount'] as String? ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
      child: SakuCard(
        onTap: () => _showTransactionBottomSheet(context, tx),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(txIcon, color: color, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    txDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              txAmount,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionBottomSheet(
    BuildContext context,
    Map<String, dynamic> tx,
  ) {
    final txIcon = tx['icon'] as IconData? ?? icon;
    final txName = tx['name'] as String? ?? 'Transaksi';
    final txDate = tx['date'] as String? ?? '';
    final txAmount = tx['amount'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Icon
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(txIcon, color: color, size: 40.sp),
            ),
            SizedBox(height: 16.h),

            // Transaction Name
            Text(
              txName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8.h),

            // Amount
            Text(
              txAmount,
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
                letterSpacing: -1.0,
              ),
            ),
            SizedBox(height: 16.h),

            // Info Row (Date & Category)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  txDate,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Description Box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(icon, color: color, size: 16.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111111),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: Colors.grey[200], height: 1.h),
                  SizedBox(height: 16.h),
                  Text(
                    'Transaksi $txName pada tanggal $txDate untuk kategori $categoryName.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1.5.w,
                        ),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
