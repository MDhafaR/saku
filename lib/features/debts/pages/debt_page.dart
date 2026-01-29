import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards untuk Debt
          Row(
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
              const SizedBox(width: 12),
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
          const SizedBox(height: 28),

          // Unpaid Debts Section
          Row(
            children: [
              Text(
                'Belum Lunas',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${unpaidDebts.length}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...unpaidDebts.map((debt) => DebtItem(debt: debt)),
          const SizedBox(height: 24),

          // Paid Debts Section
          Row(
            children: [
              Text(
                'Sudah Lunas',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${paidDebts.length}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...paidDebts.map((debt) => DebtItem(debt: debt)),
        ],
      ),
    );
  }
}
