import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/debt.dart';
import '../widgets/summary_card.dart';
import '../widgets/debt_item.dart';

class DebtPage extends StatelessWidget {
  DebtPage({super.key});

  // Sample data sesuai dengan gambar
  final List<Debt> unpaidDebts = [
    Debt(
      id: '1',
      name: 'Budi Santoso',
      avatarUrl: '',
      amount: 850000,
      dueDate: DateTime(2024, 1, 25),
      status: DebtStatus.overdue,
      type: 'debt',
    ),
    Debt(
      id: '2',
      name: 'Sarah Wijaya',
      avatarUrl: '',
      amount: 1200000,
      dueDate: DateTime(2024, 2, 15),
      status: DebtStatus.dueSoon,
      type: 'debt',
    ),
    Debt(
      id: '3',
      name: 'Ahmad Rizki',
      avatarUrl: '',
      amount: 400000,
      dueDate: DateTime(2024, 3, 10),
      status: DebtStatus.pending,
      type: 'debt',
    ),
  ];

  final List<Debt> paidDebts = [
    Debt(
      id: '4',
      name: 'Dewi Lestari',
      avatarUrl: '',
      amount: 300000,
      dueDate: DateTime(2024, 1, 20),
      paidDate: DateTime(2024, 1, 20),
      status: DebtStatus.paid,
      type: 'debt',
    ),
    Debt(
      id: '5',
      name: 'Andi Pratama',
      avatarUrl: '',
      amount: 280000,
      dueDate: DateTime(2024, 1, 18),
      paidDate: DateTime(2024, 1, 18),
      status: DebtStatus.paid,
      type: 'debt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary Cards - Fixed at top
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
          child: Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Utang',
                  amount: 'Rp2.450.000',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: const Color(0xFFEF4444),
                  isNegative: true,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SummaryCard(
                  title: 'Sudah Dibayar',
                  amount: 'Rp580.000',
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
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unpaid Debts Section
                Row(
                  children: [
                    Text(
                      'Belum Lunas',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${unpaidDebts.length}',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...unpaidDebts.map((debt) => DebtItem(debt: debt)),
                SizedBox(height: 16.h),

                // Paid Debts Section
                Row(
                  children: [
                    Text(
                      'Sudah Lunas',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${paidDebts.length}',
                        style: TextStyle(
                          color: const Color(0xFF10B981),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...paidDebts.map((debt) => DebtItem(debt: debt)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
