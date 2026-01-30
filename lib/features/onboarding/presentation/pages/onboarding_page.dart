import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Track Every Expense',
      description:
          'Effortlessly monitor your spending habits with smart categorization and instant expense logging',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF10B981), // Semantic Green
    ),
    OnboardingData(
      title: 'Smart Analytics',
      description:
          'Get insights into your spending patterns with detailed analytics and visual reports',
      icon: Icons.analytics,
      color: const Color(0xFF3B82F6), // Blue
    ),
    OnboardingData(
      title: 'Easy Management',
      description:
          'Manage your finances effortlessly with intuitive tools and automated categorization',
      icon: Icons.trending_up,
      color: const Color(0xFFF59E0B), // Orange
    ),
    OnboardingData(
      title: 'Secure & Private',
      description:
          'Your financial data is encrypted and stored securely on your device',
      icon: Icons.security,
      color: const Color(0xFFEF4444), // Semantic Red
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Design system background
      body: SafeArea(
        child: Column(
          children: [
            // Top section with skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App logo/icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: () {
                      context.read<OnboardingCubit>().completeOnboarding();
                    },
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF), // Muted Gray
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content with PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            // Bottom section with dots and next button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: index == _currentPage
                              ? const Color(0xFF111111) // Primary Dark
                              : const Color(0xFFE5E7EB), // Light border
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.read<OnboardingCubit>().completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF111111,
                        ), // Primary Dark
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            24,
                          ), // Button radius
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _onboardingData.length - 1
                            ? 'Lanjut'
                            : 'Mulai Sekarang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(data.icon, size: 60, color: data.color),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            data.title,
            style: const TextStyle(
              color: Color(0xFF111111), // Primary Dark
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: const TextStyle(
              color: Color(0xFF6B7280), // Dark Muted
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
