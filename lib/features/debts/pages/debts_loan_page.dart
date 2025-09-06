import 'package:flutter/material.dart';
import 'debt_page.dart';
import 'loan_page.dart';

class DebtsLoanPage extends StatelessWidget {
  const DebtsLoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Debt & Loan',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Implement add debt/loan functionality
              },
              icon: const Icon(Icons.add, color: Color(0xFF333333), size: 24),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB), // Grey underline untuk semua tab
                    width: 1,
                  ),
                ),
              ),
              child: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(
                      0xFF8A2BE2,
                    ), // Purple color untuk underline aktif
                    width: 3,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 40), // Lebih lebar
                ),
                labelColor: Color(0xFF8A2BE2), // Purple untuk tab aktif
                unselectedLabelColor: Color(
                  0xFF999999,
                ), // Grey untuk tab tidak aktif
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Debt'),
                  Tab(text: 'Loan'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(children: [DebtPage(), LoanPage()]),
      ),
    );
  }
}
