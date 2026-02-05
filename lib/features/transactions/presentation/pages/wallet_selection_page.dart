import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class WalletSelectionPage extends StatelessWidget {
  const WalletSelectionPage({super.key});

  // Dummy wallet data - will be replaced with actual data later
  static final List<Map<String, dynamic>> _wallets = [
    {
      'id': '1',
      'name': 'Dompet',
      'type': 'cash',
      'balance': 500000.0,
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF10B981),
    },
    {
      'id': '2',
      'name': 'BCA',
      'type': 'bank',
      'balance': 2500000.0,
      'icon': Icons.account_balance,
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': '3',
      'name': 'OVO',
      'type': 'ewallet',
      'balance': 150000.0,
      'icon': Icons.payment,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': '4',
      'name': 'GoPay',
      'type': 'ewallet',
      'balance': 75000.0,
      'icon': Icons.mobile_friendly,
      'color': const Color(0xFF06B6D4),
    },
    {
      'id': '5',
      'name': 'Dana',
      'type': 'ewallet',
      'balance': 200000.0,
      'icon': Icons.wallet,
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Pilih Wallet',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),

          // Wallet List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0),
              itemCount: _wallets.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final wallet = _wallets[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, wallet);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: (wallet['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            wallet['icon'] as IconData,
                            color: wallet['color'] as Color,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Name & Balance
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet['name'] as String,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Rp ${CurrencyFormatter.format((wallet['balance'] as double).toStringAsFixed(0))}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add wallet page
        },
        backgroundColor: AppTheme.primaryBlue,
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
