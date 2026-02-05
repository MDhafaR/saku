import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/debt.dart';
import '../widgets/summary_card.dart';
import '../widgets/debt_item.dart';

class LoanPage extends StatelessWidget {
  LoanPage({super.key});

  // Sample data untuk loan (piutang)
  final List<Debt> unpaidLoans = [
    Debt(
      id: '1',
      name: 'PT Maju Bersama',
      avatarUrl: '',
      amount: 5000000,
      dueDate: DateTime(2024, 2, 28),
      status: DebtStatus.dueSoon,
      type: 'loan',
    ),
    Debt(
      id: '2',
      name: 'Toko Sejahtera',
      avatarUrl: '',
      amount: 3200000,
      dueDate: DateTime(2024, 3, 15),
      status: DebtStatus.pending,
      type: 'loan',
    ),
  ];

  final List<Debt> paidLoans = [
    Debt(
      id: '3',
      name: 'CV Berkah Jaya',
      avatarUrl: '',
      amount: 1500000,
      dueDate: DateTime(2024, 1, 10),
      paidDate: DateTime(2024, 1, 10),
      status: DebtStatus.paid,
      type: 'loan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 150.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards untuk Loan
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Piutang',
                  amount: 'Rp8.200.000',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SummaryCard(
                  title: 'Sudah Diterima',
                  amount: 'Rp1.500.000',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),

          // Unpaid Loans Section
          Row(
            children: [
              Text(
                'Belum Diterima',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${unpaidLoans.length}',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...unpaidLoans.map((loan) => DebtItem(debt: loan)),
          SizedBox(height: 24.h),

          // Paid Loans Section
          Row(
            children: [
              Text(
                'Sudah Diterima',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${paidLoans.length}',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...paidLoans.map((loan) => DebtItem(debt: loan)),
        ],
      ),
    );
  }
}
