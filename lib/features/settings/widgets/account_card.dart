import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../data/local/database/app_database.dart';

class AccountCard extends StatelessWidget {
  final Wallet wallet;

  const AccountCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(wallet.iconColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: CategoryIcon(
              iconName: wallet.icon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Account info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rp ${CurrencyFormatter.format(wallet.currentBalance.toStringAsFixed(0))}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Icon(
            Icons.arrow_forward_ios,
            color: colorScheme.onSurfaceVariant,
            size: 12.sp,
          ),
        ],
      ),
    );
  }
}
