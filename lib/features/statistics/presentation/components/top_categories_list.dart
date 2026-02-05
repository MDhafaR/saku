import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            category.amount,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            category.percentage,
            style: TextStyle(
              fontSize: 12.sp,
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
