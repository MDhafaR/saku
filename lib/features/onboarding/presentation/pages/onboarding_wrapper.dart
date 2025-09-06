import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:uuid/uuid.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../debts/presentation/pages/debts_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/injection.dart';
import '../../../../core/constants.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../dashboard/presentation/cubit/transaction_cubit.dart';
import '../../widgets/animated_fab.dart';

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit()..checkOnboardingStatus(),
      child: BlocBuilder<OnboardingCubit, bool>(
        builder: (context, isOnboardingCompleted) {
          if (isOnboardingCompleted) {
            return const MainAppContent();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}

class MainAppContent extends StatefulWidget {
  const MainAppContent({super.key});

  @override
  State<MainAppContent> createState() => _MainAppContentState();
}

class _MainAppContentState extends State<MainAppContent> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const StatisticsPage(),
    const DebtsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(index: _currentIndex, children: _pages),
          // Animated Floating Action Button
          AnimatedFab(
            onPressed: _showAddTransactionBottomSheet,
            onShowAddTransaction: _showAddTransactionBottomSheet,
          ),
          // Curved Navigation Bar - Transparent Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF2D3142).withOpacity(0.1),
                    const Color(0xFF2D3142).withOpacity(0.3),
                    const Color(0xFF2D3142).withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: CurvedNavigationBar(
                index: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                color: const Color.fromARGB(
                  222,
                  45,
                  49,
                  66,
                ), // Fully transparent
                buttonBackgroundColor: const Color(
                  0xFF6C5CE7,
                ), // Purple for selected
                height: 75,
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                items: const [
                  Icon(Icons.dashboard, color: Colors.white, size: 24),
                  Icon(Icons.bar_chart, color: Colors.white, size: 24),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 24,
                  ),
                  Icon(Icons.settings, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionBottomSheet() {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = kCategories.first;
    String selectedType = kTypeExpense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2D3142),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tambah Transaksi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF2D3142),
                decoration: const InputDecoration(
                  labelText: 'Tipe',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: kTypeExpense,
                    child: const Text(
                      'Pengeluaran',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: kTypeIncome,
                    child: const Text(
                      'Pemasukan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setBottomSheetState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF2D3142),
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6C5CE7)),
                  ),
                ),
                items: kCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setBottomSheetState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (descController.text.isNotEmpty &&
                            amountController.text.isNotEmpty) {
                          final transaction = Transaction(
                            id: const Uuid().v4(),
                            description: descController.text,
                            amount: double.parse(amountController.text),
                            category: selectedCategory,
                            type: selectedType,
                            timestamp: DateTime.now(),
                          );

                          final cubit = locator<TransactionCubit>();
                          cubit.addTransaction(transaction);

                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Tambah',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
