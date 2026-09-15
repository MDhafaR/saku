import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/category_icon.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/local/database/app_database.dart';
import '../cubit/statistics_state.dart';
import '../pages/category_transactions_page.dart';

class CategoryDetailCard extends StatelessWidget {
  final CategoryBreakdownItem item;
  final bool isExpanded;
  final VoidCallback? onTap;
  final String period;
  final DateTime? targetDate;
  final AppDateTimeRange? customRange;

  const CategoryDetailCard({
    super.key,
    required this.item,
    this.isExpanded = true,
    this.onTap,
    this.period = 'Monthly',
    this.targetDate,
    this.customRange,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(item.color);

    return GestureDetector(
      onTap: onTap,
      child: SakuCard(
        margin: EdgeInsets.zero,
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
                  child: CategoryIcon(
                    iconName: item.icon,
                    color: color,
                    size: 18.sp,
                  ),
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
                      SizedBox(height: 6.h),
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
                  ? _buildExpandedContent(context, color)
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trend Badge
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(top: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: item.isTrendUp
                  ? const Color(0xFFFEE2E2) // Red bg (increase in expense)
                  : const Color(0xFFDCFCE7), // Green bg (decrease)
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              item.isTrendUp ? '↑ ${item.trendValue}' : '↓ ${item.trendValue}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: item.isTrendUp
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
        ),

        if (item.topTransactions.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3), height: 1.h),
          SizedBox(height: 8.h),
          Text(
            'Top 3 Transaksi Terbesar',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          ...item.topTransactions.map(
            (tx) => _buildTransactionItem(tx, color, item.icon),
          ),
          SizedBox(height: 2.h),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryTransactionsPage(
                    categoryId: item.id,
                    categoryName: item.name,
                    iconName: item.icon,
                    color: color,
                    totalAmount: item.amount,
                    percentage: item.percentage,
                    trendValue: item.trendValue,
                    isTrendUp: item.isTrendUp,
                    period: period,
                    targetDate: targetDate ?? DateTime.now(),
                    customRange: customRange,
                    initialTransactions: item.topTransactions,
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

  Widget _buildTransactionItem(Transaction tx, Color color, String iconName) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: CategoryIcon(
                  iconName: iconName,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 14.sp,
                ),
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
      },
    );
  }
}
