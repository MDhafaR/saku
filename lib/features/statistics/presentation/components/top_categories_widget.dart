import 'package:flutter/material.dart';

class TopCategoriesWidget extends StatelessWidget {
  const TopCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Food & Dining',
        'amount': '\$850',
        'percentage': '29.4%',
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Transportation',
        'amount': '\$620',
        'percentage': '21.5%',
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Shopping',
        'amount': '\$480',
        'percentage': '18.6%',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Entertainment',
        'amount': '\$320',
        'percentage': '11.1%',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  category['amount'] as String,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category['percentage'] as String,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
