import 'package:flutter/material.dart';
import '../components/components.dart' as components;

/// Dashboard page showing recent transactions and summary information.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentMonth = 'January 2024';

  void _onPreviousMonth() {
    // TODO: Implement previous month logic
  }

  void _onNextMonth() {
    // TODO: Implement next month logic
  }

  void _onSearchChanged(String query) {
    // TODO: Implement search logic
  }

  void _onFilterTap() {
    // TODO: Implement filter logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with app name and theme toggle
                  _buildHeader(),
                  const SizedBox(height: 8),

                  // Month navigation
                  components.MonthNavigation(
                    currentMonth: _currentMonth,
                    onPreviousMonth: _onPreviousMonth,
                    onNextMonth: _onNextMonth,
                  ),

                  // Summary cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Search bar
                  components.SearchBar(
                    onChanged: _onSearchChanged,
                    onFilterTap: _onFilterTap,
                  ),
                ],
              ),
            ),

            // Scrollable transaction sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransactionSections(),
                    // Bottom padding for FAB
                    const SizedBox(height: 164),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Saku',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.dark_mode_outlined,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        components.SummaryCard(
          title: 'Income',
          amount: '\$4,250',
          icon: Icons.arrow_upward,
          iconColor: Colors.green[700]!,
          backgroundColor: Colors.green[100]!,
        ),
        const SizedBox(width: 12),
        components.SummaryCard(
          title: 'Expense',
          amount: '\$2,840',
          icon: Icons.arrow_downward,
          iconColor: Colors.red[700]!,
          backgroundColor: Colors.red[100]!,
        ),
        const SizedBox(width: 12),
        components.SummaryCard(
          title: 'Total',
          amount: '\$1,410',
          icon: Icons.account_balance_wallet,
          iconColor: Colors.purple[700]!,
          backgroundColor: Colors.purple[100]!,
          textColor: Colors.green[700]!,
        ),
      ],
    );
  }

  Widget _buildTransactionSections() {
    return Column(
      children: [
        components.TransactionSection(
          sectionTitle: 'Today',
          transactions: [
            components.TransactionData(
              category: 'Food & Dining',
              paymentMethod: 'Cash',
              amount: '-\$25.50',
              icon: Icons.restaurant,
              iconColor: Colors.orange[700]!,
              backgroundColor: Colors.orange[100]!,
            ),
            components.TransactionData(
              category: 'Transportation',
              paymentMethod: 'Credit Card',
              amount: '-\$45.00',
              icon: Icons.local_gas_station,
              iconColor: Colors.blue[700]!,
              backgroundColor: Colors.blue[100]!,
            ),
          ],
        ),
        components.TransactionSection(
          sectionTitle: 'Yesterday',
          transactions: [
            components.TransactionData(
              category: 'Salary',
              paymentMethod: 'Bank Account',
              amount: '+\$2,500',
              icon: Icons.work,
              iconColor: Colors.green[700]!,
              backgroundColor: Colors.green[100]!,
              isIncome: true,
            ),
            components.TransactionData(
              category: 'Shopping',
              paymentMethod: 'Debit Card',
              amount: '-\$89.99',
              icon: Icons.shopping_bag,
              iconColor: Colors.purple[700]!,
              backgroundColor: Colors.purple[100]!,
            ),
          ],
        ),
      ],
    );
  }
}
