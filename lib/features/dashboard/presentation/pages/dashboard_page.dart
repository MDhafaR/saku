import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/components.dart' as components;
import '../components/filter_bottom_sheet.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with app name and theme toggle
                  _buildHeader(),
                  SizedBox(height: 4.h),

                  // Month navigation
                  components.MonthNavigation(
                    currentMonth: _currentMonth,
                    onPreviousMonth: _onPreviousMonth,
                    onNextMonth: _onNextMonth,
                  ),

                  // Summary cards
                  _buildSummaryCards(),

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
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransactionSections(),
                    // Bottom padding for FAB
                    SizedBox(height: 140.h),
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
        Text(
          'Saku',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.dark_mode_outlined,
            color: Colors.grey[600],
            size: 20.sp,
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
        SizedBox(width: 12.w),
        components.SummaryCard(
          title: 'Expense',
          amount: '\$2,840',
          icon: Icons.arrow_downward,
          iconColor: Colors.red[700]!,
          backgroundColor: Colors.red[100]!,
        ),
        SizedBox(width: 12.w),
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
