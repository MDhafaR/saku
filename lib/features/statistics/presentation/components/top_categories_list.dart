import 'package:flutter/material.dart';

class TopCategoriesList extends StatelessWidget {
  const TopCategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryData(
        name: 'Food & Dining',
        amount: '\$850',
        percentage: '29.4%',
        color: Colors.blue[400]!,
      ),
      CategoryData(
        name: 'Transportation',
        amount: '\$620',
        percentage: '21.5%',
        color: Colors.teal[400]!,
      ),
      CategoryData(
        name: 'Shopping',
        amount: '\$480',
        percentage: '18.6%',
        color: Colors.purple[400]!,
      ),
      CategoryData(
        name: 'Entertainment',
        amount: '\$320',
        percentage: '11.1%',
        color: Colors.orange[400]!,
      ),
    ];

    return Column(
      children: categories
          .map((category) => _buildCategoryItem(category))
          .toList(),
    );
  }

  Widget _buildCategoryItem(CategoryData category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            category.amount,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.percentage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryData {
  final String name;
  final String amount;
  final String percentage;
  final Color color;

  CategoryData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
