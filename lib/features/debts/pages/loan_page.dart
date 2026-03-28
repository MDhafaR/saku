import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/local/database/app_database.dart';
import '../presentation/cubit/debt_cubit.dart';
import '../presentation/cubit/debt_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/debt_item.dart';

class LoanPage extends StatelessWidget {
  const LoanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebtCubit, DebtState>(
      builder: (context, state) {
        if (state is DebtLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DebtError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is DebtLoaded) {
          final allLoans = state.debts.where((d) => d.type == 'loan').toList();
          final unpaidLoans = allLoans
              .where((d) => d.status != 'paid')
              .toList();
          final paidLoans = allLoans.where((d) => d.status == 'paid').toList();

          final totalLoan = allLoans.fold<double>(
            0.0,
            (sum, d) => sum + d.totalAmount,
          );
          final totalReceived = allLoans.fold<double>(
            0.0,
            (sum, d) => sum + d.paidAmount,
          );

          return Column(
            children: [
              // Summary Cards
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Piutang',
                        amount: 'Rp${_formatAmount(totalLoan)}',
                        icon: Icons.arrow_upward_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: SummaryCard(
                        title: 'Sudah Diterima',
                        amount: 'Rp${_formatAmount(totalReceived)}',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Scrollable content
              Expanded(
                child: allLoans.isEmpty
                    ? _buildEmptyState(context)
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (unpaidLoans.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Belum Diterima',
                                unpaidLoans.length,
                                const Color(0xFFF3F4F6),
                                const Color(0xFF6B7280),
                              ),
                              SizedBox(height: 10.h),
                              ...unpaidLoans.map(
                                (loan) => DebtItem(
                                  debt: loan,
                                  personName:
                                      state.persons[loan.personId]?.name ??
                                      'Unknown',
                                  phone: state.persons[loan.personId]?.phone,
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                            if (paidLoans.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Sudah Diterima',
                                paidLoans.length,
                                const Color(0xFFDCFCE7),
                                const Color(0xFF10B981),
                              ),
                              SizedBox(height: 10.h),
                              ...paidLoans.map(
                                (loan) => DebtItem(
                                  debt: loan,
                                  personName:
                                      state.persons[loan.personId]?.name ??
                                      'Unknown',
                                  phone: state.persons[loan.personId]?.phone,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    Color badgeBg,
    Color badgeText,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: badgeText,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'Belum ada piutang',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}
