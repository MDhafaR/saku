import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/category_detail_card.dart';
import '../components/expense_comparison_chart.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  DateTime selectedDate = DateTime.now();
  int? _expandedIndex =
      0; // Default: first card is expanded, null = all collapsed

  String get selectedMonth => DateFormat('MMM yyyy').format(selectedDate);

  Future<void> _showMonthPicker() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111111),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  void _onCardTap(int index) {
    setState(() {
      // Toggle: if already expanded, collapse it; otherwise expand this one
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                      'Rp2.890.000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedMonth,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Color(0xFF111111),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comparison Chart
            const ExpenseComparisonChart(),
            const SizedBox(height: 24),

            // Category Cards with expand/collapse
            // Makan & Minum - 12 Transaksi
            CategoryDetailCard(
              categoryName: 'Makan & Minum',
              transactionCount: '12 Transaksi',
              amount: 'Rp850.000',
              percentage: '29.4%',
              icon: Icons.restaurant,
              color: const Color(0xFFF59E0B),
              isTrendUp: true,
              trendValue: '12%',
              isExpanded: _expandedIndex == 0,
              onTap: () => _onCardTap(0),
              topTransactions: const [
                {
                  'icon': Icons.coffee,
                  'name': 'Starbucks Coffee',
                  'date': '28 Jan',
                  'amount': '-Rp85.000',
                },
                {
                  'icon': Icons.shopping_basket,
                  'name': 'Superindo Groceries',
                  'date': '26 Jan',
                  'amount': '-Rp320.000',
                },
                {
                  'icon': Icons.set_meal,
                  'name': 'Sushi Tei Dinner',
                  'date': '24 Jan',
                  'amount': '-Rp245.000',
                },
              ],
            ),
            const SizedBox(height: 16),

            // Transportasi - 8 Transaksi
            CategoryDetailCard(
              categoryName: 'Transportasi',
              transactionCount: '8 Transaksi',
              amount: 'Rp620.000',
              percentage: '21.5%',
              icon: Icons.directions_car,
              color: const Color(0xFF3B82F6),
              isTrendUp: false,
              trendValue: '5%',
              isExpanded: _expandedIndex == 1,
              onTap: () => _onCardTap(1),
              topTransactions: const [
                {
                  'icon': Icons.local_gas_station,
                  'name': 'Pertamina SPBU',
                  'date': '27 Jan',
                  'amount': '-Rp150.000',
                },
                {
                  'icon': Icons.two_wheeler,
                  'name': 'Gojek Ride',
                  'date': '25 Jan',
                  'amount': '-Rp45.000',
                },
                {
                  'icon': Icons.directions_car,
                  'name': 'Grab Car',
                  'date': '22 Jan',
                  'amount': '-Rp78.000',
                },
              ],
            ),
            const SizedBox(height: 16),

            // Belanja - 5 Transaksi
            CategoryDetailCard(
              categoryName: 'Belanja',
              transactionCount: '5 Transaksi',
              amount: 'Rp450.000',
              percentage: '15.6%',
              icon: Icons.shopping_bag,
              color: const Color(0xFFEC4899),
              isTrendUp: true,
              trendValue: '8%',
              isExpanded: _expandedIndex == 2,
              onTap: () => _onCardTap(2),
              topTransactions: const [
                {
                  'icon': Icons.checkroom,
                  'name': 'Uniqlo T-Shirt',
                  'date': '26 Jan',
                  'amount': '-Rp199.000',
                },
                {
                  'icon': Icons.phone_android,
                  'name': 'Tokopedia Gadget',
                  'date': '20 Jan',
                  'amount': '-Rp150.000',
                },
                {
                  'icon': Icons.home,
                  'name': 'IKEA Home Decor',
                  'date': '15 Jan',
                  'amount': '-Rp89.000',
                },
              ],
            ),
            const SizedBox(height: 16),

            // Tagihan - 3 Transaksi
            CategoryDetailCard(
              categoryName: 'Tagihan',
              transactionCount: '3 Transaksi',
              amount: 'Rp970.000',
              percentage: '33.5%',
              icon: Icons.receipt_long,
              color: const Color(0xFF10B981),
              isTrendUp: false,
              trendValue: '2%',
              isExpanded: _expandedIndex == 3,
              onTap: () => _onCardTap(3),
              topTransactions: const [
                {
                  'icon': Icons.bolt,
                  'name': 'PLN Listrik',
                  'date': '25 Jan',
                  'amount': '-Rp450.000',
                },
                {
                  'icon': Icons.wifi,
                  'name': 'IndiHome Internet',
                  'date': '20 Jan',
                  'amount': '-Rp350.000',
                },
                {
                  'icon': Icons.water_drop,
                  'name': 'PDAM Air',
                  'date': '18 Jan',
                  'amount': '-Rp170.000',
                },
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
