import 'package:flutter/material.dart';

import '../components/category_detail_card.dart';
import '../components/expense_comparison_chart.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String selectedMonth = 'Jan 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rincian Kategori',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xFF1F2937),
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Total & Month
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '\$2,890.00',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE), // Light Blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedMonth,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF0284C7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comparison Chart
            const ExpenseComparisonChart(),
            const SizedBox(height: 24),

            // Category Cards
            CategoryDetailCard(
              categoryName: 'Makan & Minum',
              transactionCount: '12 Transaksi',
              amount: '\$850.00',
              percentage: '29.4%',
              icon: Icons.restaurant,
              color: const Color(0xFFF59E0B), // Amber
              isTrendUp: true,
              trendValue: '12%',
              topTransactions: const [
                {
                  'icon': Icons.coffee,
                  'name': 'Starbucks Coffee',
                  'date': '12 Jan',
                  'amount': '-\$15.50',
                },
                {
                  'icon': Icons.shopping_basket,
                  'name': 'Superindo Groceries',
                  'date': '10 Jan',
                  'amount': '-\$120.00',
                },
                {
                  'icon': Icons.set_meal, // Sushi icon replacement
                  'name': 'Sushi Tei',
                  'date': '08 Jan',
                  'amount': '-\$45.00',
                },
              ],
            ),
            const SizedBox(height: 16),
            const CategoryDetailCard(
              categoryName: 'Transportasi',
              transactionCount: '8 Transaksi',
              amount: '\$620.00',
              percentage: '21.5%',
              icon: Icons.directions_car, // Car icon
              color: Color(0xFF3B82F6), // Blue
              isTrendUp: false,
              trendValue: '5%',
            ),
            const SizedBox(height: 16),
            CategoryDetailCard(
              categoryName: 'Belanja',
              transactionCount: '5 Transaksi',
              amount: '\$450.00',
              percentage: '15.6%',
              icon: Icons.shopping_bag,
              color: const Color(0xFFEC4899), // Pink
              isTrendUp: true,
              trendValue: '5%',
              // Force empty top transactions for now as per design implies folded state
              topTransactions: const [],
            ),
            const SizedBox(height: 16),
            const CategoryDetailCard(
              categoryName: 'Tagihan',
              transactionCount: '3 Transaksi',
              amount: '\$290.00',
              percentage: '10.0%',
              icon: Icons.receipt_long,
              color: Color(0xFF10B981), // Green
              isTrendUp: false, // Defaulting
              trendValue: '-',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
