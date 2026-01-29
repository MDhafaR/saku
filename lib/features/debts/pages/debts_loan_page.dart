import 'package:flutter/material.dart';
import 'debt_page.dart';
import 'loan_page.dart';

class DebtsLoanPage extends StatefulWidget {
  const DebtsLoanPage({super.key});

  @override
  State<DebtsLoanPage> createState() => _DebtsLoanPageState();
}

class _DebtsLoanPageState extends State<DebtsLoanPage> {
  int _selectedTab = 0;

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
          'Utang & Piutang',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement add debt/loan functionality
            },
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFF1F2937),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Tab Selector - Sliding Pill style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / 2;
                  return Stack(
                    children: [
                      // Sliding indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        left: _selectedTab == 0 ? 0 : tabWidth,
                        top: 0,
                        bottom: 0,
                        width: tabWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tab labels
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_selectedTab != 0) {
                                  setState(() => _selectedTab = 0);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 18,
                                      color: _selectedTab == 0
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Utang',
                                      style: TextStyle(
                                        color: _selectedTab == 0
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (_selectedTab != 1) {
                                  setState(() => _selectedTab = 1);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: _selectedTab == 1
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Piutang',
                                      style: TextStyle(
                                        color: _selectedTab == 1
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tab Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedTab == 0
                  ? DebtPage(key: const ValueKey('debt'))
                  : LoanPage(key: const ValueKey('loan')),
            ),
          ),
        ],
      ),
    );
  }
}
