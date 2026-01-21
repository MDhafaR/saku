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
import '../../../transactions/presentation/pages/add_transaction_page.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
  }
}
