import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/statistics_state.dart';
import '../pages/category_transactions_page.dart';

class CategoryDetailCard extends StatelessWidget {
  final CategoryBreakdownItem item;
  final bool isExpanded;
  final VoidCallback? onTap;

  const CategoryDetailCard({
    super.key,
    required this.item,
    this.isExpanded = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(item.color);
    // In a real app, we'd have a mapping from icon name to IconData
    // For now, let's use a simple helper or just fallback
    final iconData = _getIconData(item.icon);

    return GestureDetector(
      onTap: onTap,
      child: SakuCard(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: color, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatRupiah(item.amount),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.transactionCount} Transaksi',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Progress bar line
                      Stack(
                        children: [
                          Container(
                            height: 4.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (item.percentage / 100).clamp(
                              0.0,
                              1.0,
                            ),
                            child: Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expand/Collapse indicator
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 20.sp,
                  ),
                ),
              ],
            ),

            // Animated expandable content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? _buildExpandedContent(context, color, iconData)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    Color color,
    IconData iconData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trend Badge
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: item.isTrendUp
                  ? const Color(0xFFFEE2E2) // Red bg (increase in expense)
                  : const Color(0xFFDCFCE7), // Green bg (decrease)
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              item.isTrendUp ? '↑ ${item.trendValue}' : '↓ ${item.trendValue}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: item.isTrendUp
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
        ),

        if (item.topTransactions.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3), height: 1.h),
          SizedBox(height: 12.h),
          Text(
            'Top 3 Transaksi Terbesar',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          ...item.topTransactions.map(
            (tx) => _buildTransactionItem(tx, color, iconData),
          ),
          SizedBox(height: 4.h),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryTransactionsPage(
                    categoryName: item.name,
                    icon: iconData,
                    color: color,
                    transactions: item.topTransactions,
                    totalAmount: CurrencyFormatter.formatRupiah(item.amount),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Lihat Semua',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionItem(Transaction tx, Color color, IconData iconData) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Icon(iconData, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 14.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      tx.transactionDate.toString().split(' ')[0], // Simple date
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '-${CurrencyFormatter.formatRupiah(tx.amount)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  IconData _getIconData(String iconName) {
    // This should ideally use the same registry as the rest of the app
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'coffee':
        return Icons.coffee;
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'set_meal':
        return Icons.set_meal;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'checkroom':
        return Icons.checkroom;
      case 'phone_android':
        return Icons.phone_android;
      case 'home':
        return Icons.home;
      case 'bolt':
        return Icons.bolt;
      case 'wifi':
        return Icons.wifi;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.category;
    }
  }
}
