import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transactionCount, // "12 Transaksi"
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            percentage, // "29.4%"
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar line
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: _parsePercentage(percentage),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
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
                    size: 24,
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
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTrendUp
                  ? const Color(0xFFFEE2E2) // Red bg
                  : const Color(0xFFDCFCE7), // Green bg
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isTrendUp ? '↑ $trendValue' : '↓ $trendValue',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isTrendUp
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
            ),
          ),
        ),

        if (topTransactions != null && topTransactions!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 20),
          const Text(
            'Top 3 Transaksi Terbesar',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...topTransactions!.map((tx) => _buildTransactionItem(tx)),
          const SizedBox(height: 8),
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
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: Color(0xFF111111), // Dark - matches design system
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12), // Keep it rounded
              border: Border.all(color: const Color(0xFFF9FAFB)),
            ),
            child: Icon(
              tx['icon'] as IconData,
              color: const Color(0xFF9CA3AF),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx['date'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Text(
            tx['amount'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
