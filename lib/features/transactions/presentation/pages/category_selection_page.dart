import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategorySelectionPage extends StatefulWidget {
  final bool isExpense;

  const CategorySelectionPage({super.key, required this.isExpense});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'Makanan & Minuman',
      'icon': Icons.fastfood,
      'color': const Color(0xFFF87171),
    },
    {
      'name': 'Transportasi',
      'icon': Icons.directions_bus,
      'color': const Color(0xFF34D399),
    },
    {
      'name': 'Belanja Bulanan',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFFBBF24),
    },
    {
      'name': 'Hiburan & Hobi',
      'icon': Icons.movie,
      'color': const Color(0xFF818CF8),
    },
    {
      'name': 'Tagihan Rumah',
      'icon': Icons.home,
      'color': const Color(0xFFFB923C),
    },
    {
      'name': 'Kesehatan',
      'icon': Icons.medical_services,
      'color': const Color(0xFFF87171),
    },
    {
      'name': 'Pendidikan',
      'icon': Icons.school,
      'color': const Color(0xFF3B82F6),
    },
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Gaji',
      'icon': Icons.attach_money,
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Hadiah',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFF472B6),
    },
    {
      'name': 'Investasi',
      'icon': Icons.trending_up,
      'color': const Color(0xFF3B82F6),
    },
    {'name': 'Bonus', 'icon': Icons.stars, 'color': const Color(0xFFFBBF24)},
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.isExpense
        ? _expenseCategories
        : _incomeCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Category List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, {
                      'name': category['name'],
                      'icon': category['icon'],
                      'color': category['color'],
                      'isExpense': widget.isExpense,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: (category['color'] as Color).withOpacity(
                              0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            color: category['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name
                        Expanded(
                          child: Text(
                            category['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        // Arrow
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add category page
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
