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
      backgroundColor: const Color(
        0xFF111827,
      ), // Dark background as per design request reference or Light?

      // User said "ingat tetap dengan styling kita" (remember to keep our styling).
      // Our styling is "Clean & Airy" (Light). The reference image was dark.
      // I should adapt the dark reference to LIGHT theme to match "styling kita".
      // Re-writing Scaffold background to white/light grey.

      // Let's stick to the Light Theme established in previous steps.
      // Background: F5F7FA (Light Grey)
      // AppBar: White
      // Text: Dark Grey/Black
    );
  }
}

// Retrying implementation with correct Light Theme styling.
