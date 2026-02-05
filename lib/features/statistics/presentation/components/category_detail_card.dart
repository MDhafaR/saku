import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../pages/category_transactions_page.dart';

class CategoryDetailCard extends StatelessWidget {
  final String categoryName;
  final String transactionCount;
  final String amount;
  final String percentage;
  final IconData icon;
  final Color color;
  final bool isTrendUp;
  final String trendValue;
  final List<Map<String, dynamic>>? topTransactions;
  final bool isExpanded;
  final VoidCallback? onTap;

  const CategoryDetailCard({
    super.key,
    required this.categoryName,
    required this.transactionCount,
    required this.amount,
    required this.percentage,
    required this.icon,
    required this.color,
    required this.isTrendUp,
    required this.trendValue,
    this.topTransactions,
    this.isExpanded = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SakuCard(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transactionCount, // "12 Transaksi"
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            percentage, // "29.4%"
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Progress bar line
                      Stack(
                        children: [
                          Container(
                            height: 4.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _parsePercentage(percentage),
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
                    color: Colors.grey[400],
                    size: 24.sp,
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
                  ? _buildExpandedContent(context)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
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
              color: isTrendUp
                  ? const Color(0xFFFEE2E2) // Red bg
                  : const Color(0xFFDCFCE7), // Green bg
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              isTrendUp ? '↑ $trendValue' : '↓ $trendValue',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isTrendUp
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
        ),

        if (topTransactions != null && topTransactions!.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Divider(color: Colors.grey[200], height: 1.h),
          SizedBox(height: 20.h),
          Text(
            'Top 3 Transaksi Terbesar',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          ...topTransactions!.map((tx) => _buildTransactionItem(tx)),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryTransactionsPage(
                    categoryName: categoryName,
                    icon: icon,
                    color: color,
                    transactions: topTransactions ?? [],
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
                color: const Color(0xFF111111), // Dark - matches design system
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  double _parsePercentage(String percentage) {
    try {
      return double.parse(percentage.replaceAll('%', '')) / 100;
    } catch (e) {
      return 0.5;
    }
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r), // Keep it rounded
              border: Border.all(color: const Color(0xFFF9FAFB)),
            ),
            child: Icon(
              tx['icon'] as IconData,
              color: const Color(0xFF9CA3AF),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['name'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  tx['date'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            tx['amount'] as String,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
