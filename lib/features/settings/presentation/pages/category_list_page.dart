import 'package:flutter/material.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  bool _isExpense = true;

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
  ];

  @override
  Widget build(BuildContext context) {
    final categories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Atur Kategori',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Toggle Buttons
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense
                            ? const Color(0xFF2563EB)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pengeluaran',
                        style: TextStyle(
                          color: _isExpense ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense
                            ? const Color(0xFF20B2AA)
                            : Colors
                                  .transparent, // Teal for Income? Or keep Blue? Blue is fine.
                        // Actually let's use a distinct color for Income if we want, or keep consistent Blue.
                        // Design image used same blue for selected tab. I'll stick to blue for primary active state,
                        // but maybe Green for income-related things?
                        // Let's use Blue for selected state generally to match "Pengeluaran" tab in image.
                        // Wait, image "Pengeluaran" was blue. "Pemasukan" was grey.
                        // If I click Pemasukan, it should probably become Blue (active).
                        // I will use Blue for active state regardless of tab.
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pemasukan',
                        style: TextStyle(
                          color: !_isExpense ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // Edit Button
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {},
                      ),
                      // Drag Handle
                      Icon(Icons.drag_handle, color: Colors.grey[400]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
