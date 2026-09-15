import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;
  final Wallet? wallet;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.category,
    this.wallet,
    this.onDelete,
    this.onEdit,
  });

  bool get isIncome => transaction.type == 'income';

  String get _formattedAmount {
    final formatted = CurrencyFormatter.format(
      transaction.amount.toStringAsFixed(0),
    );
    return isIncome ? '+Rp $formatted' : '-Rp $formatted';
  }

  String get _iconName => category?.icon ?? 'category';

  Color get _iconColor {
    return Color(category?.iconColor ?? 0xFF2196F3);
  }

  Color get _backgroundColor {
    return _iconColor.withValues(alpha: 0.15);
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDay = DateTime(
      transaction.transactionDate.year,
      transaction.transactionDate.month,
      transaction.transactionDate.day,
    );

    String dateLabel;
    if (transactionDay == today) {
      dateLabel = 'Hari ini';
    } else if (transactionDay == yesterday) {
      dateLabel = 'Kemarin';
    } else {
      dateLabel = DateFormat(
        'dd MMM yyyy',
        'id',
      ).format(transaction.transactionDate);
    }

    final timeLabel = DateFormat('HH:mm').format(transaction.transactionDate);
    return '$dateLabel, $timeLabel';
  }

  String? get _noteText {
    if (transaction.description.trim().isNotEmpty) {
      return transaction.description.trim();
    }
    if (transaction.note != null && transaction.note!.trim().isNotEmpty) {
      return transaction.note!.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      margin: EdgeInsets.only(bottom: 8.h),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildBottomSheet(context),
        );
      },
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: CategoryIcon(
              iconName: _iconName,
              color: _iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.name ?? 'Uncategorized',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_noteText != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _noteText!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 2.h),
                Text(
                  wallet?.name ?? 'Unknown Wallet',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formattedAmount,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isIncome
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFD32F2F),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
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
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CategoryIcon(
                  iconName: _iconName,
                  color: _iconColor,
                  size: 26.sp,
                ),
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
                          category?.name ?? 'Uncategorized',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          _formattedAmount,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: isIncome
                                ? const Color(0xFF2E7D32)
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
                          _formatDateTime(),
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
                          wallet?.name ?? 'Unknown',
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

          // Description Box (if has note or description)
          if (transaction.description.isNotEmpty ||
              (transaction.note?.isNotEmpty ?? false))
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: isDark ? cs.surfaceContainerLow : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? cs.outline.withValues(alpha: 0.3) : const Color(0xFFF0F0F0),
                ),
              ),
              child: Text(
                transaction.note ?? transaction.description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: cs.onSurface.withValues(alpha: 0.8),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to edit page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionPage(
                          existingTransaction: transaction,
                          existingCategory: category,
                          existingWallet: wallet,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(
                        color: cs.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    overlayColor: cs.onSurface.withValues(alpha: 0.05),
                  ),
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Show delete confirmation
                    _showDeleteConfirmation(context);
                  },
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Hapus Transaksi',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi ini?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
