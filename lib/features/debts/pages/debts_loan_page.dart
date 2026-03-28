import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/injection.dart';
import '../presentation/cubit/debt_cubit.dart';
import '../presentation/pages/add_loan_page.dart';
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
    return BlocProvider<DebtCubit>(
      create: (_) => locator<DebtCubit>()..start(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section (Dashboard style)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: Text(
                  'Utang & Piutang',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              // Tab Selector - Sliding Pill style
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24.r),
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
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4.r,
                                    offset: Offset(0, 2.h),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward_rounded,
                                          size: 14.sp,
                                          color: _selectedTab == 0
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Utang',
                                          style: TextStyle(
                                            color: _selectedTab == 0
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward_rounded,
                                          size: 14.sp,
                                          color: _selectedTab == 1
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Piutang',
                                          style: TextStyle(
                                            color: _selectedTab == 1
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
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
                );
                }),
              ),
              SizedBox(height: 8.h),
              // Tab Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTab == 0
                      ? const DebtPage(key: ValueKey('debt'))
                      : const LoanPage(key: ValueKey('loan')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
