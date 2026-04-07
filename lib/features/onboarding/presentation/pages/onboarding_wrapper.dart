import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../debts/presentation/pages/debts_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
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
          // Curved Navigation Bar — adaptive per theme
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedNavigationBar(
              index: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              // Bar gelap di kedua mode agar icon putih tetap terbaca
              color: isDark
                  ? const Color(0xFF1E293B) // Dark slate — seragam dengan FAB
                  : const Color(0xFF1E293B), // Dark slate — light mode
              buttonBackgroundColor: cs.primary, // Biru aksen untuk item aktif
              height: 65.h.clamp(0.0, 75.0),
              animationDuration: const Duration(milliseconds: 300),
              animationCurve: Curves.easeInOut,
              items: List.generate(4, (index) {
                final icons = [
                  Icons.dashboard_rounded,
                  Icons.bar_chart_rounded,
                  Icons.account_balance_wallet_rounded,
                  Icons.settings_rounded,
                ];
                return Icon(
                  icons[index],
                  color: Colors.white, // Putih kontras di atas bar gelap
                  size: 24.sp,
                );
              }),
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
