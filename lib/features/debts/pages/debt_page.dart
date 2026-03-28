import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../presentation/cubit/debt_cubit.dart';
import '../presentation/cubit/debt_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/debt_item.dart';

class DebtPage extends StatelessWidget {
  const DebtPage({super.key});

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
          final allDebts = state.debts.where((d) => d.type == 'debt').toList();
          final unpaidDebts = allDebts
              .where((d) => d.status != 'paid')
              .toList();
          final paidDebts = allDebts.where((d) => d.status == 'paid').toList();

          final totalDebt = allDebts.fold<double>(
            0.0,
            (sum, d) => sum + d.totalAmount,
          );
          final totalPaid = allDebts.fold<double>(
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
                        title: 'Total Utang',
                        amount: 'Rp${_formatAmount(totalDebt)}',
                        icon: Icons.arrow_downward_rounded,
                        iconColor: const Color(0xFFEF4444),
                        isNegative: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: SummaryCard(
                        title: 'Sudah Dibayar',
                        amount: 'Rp${_formatAmount(totalPaid)}',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Scrollable content
              Expanded(
                child: allDebts.isEmpty
                    ? _buildEmptyState(context)
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (unpaidDebts.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Belum Lunas',
                                unpaidDebts.length,
                                const Color(0xFFF3F4F6),
                                const Color(0xFF6B7280),
                              ),
                              SizedBox(height: 10.h),
                              ...unpaidDebts.map(
                                (debt) => DebtItem(
                                  debt: debt,
                                  personName:
                                      state.persons[debt.personId]?.name ??
                                      'Unknown',
                                  phone: state.persons[debt.personId]?.phone,
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                            if (paidDebts.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                'Sudah Lunas',
                                paidDebts.length,
                                const Color(0xFFDCFCE7),
                                const Color(0xFF10B981),
                              ),
                              SizedBox(height: 10.h),
                              ...paidDebts.map(
                                (debt) => DebtItem(
                                  debt: debt,
                                  personName:
                                      state.persons[debt.personId]?.name ??
                                      'Unknown',
                                  phone: state.persons[debt.personId]?.phone,
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
            'Belum ada utang',
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
