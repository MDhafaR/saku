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
      name: 'John Smith',
      avatarUrl: '',
      amount: 850,
      dueDate: DateTime(2024, 1, 25),
      status: DebtStatus.overdue,
      type: 'debt',
    ),
    Debt(
      id: '2',
      name: 'Sarah Johnson',
      avatarUrl: '',
      amount: 1200,
      dueDate: DateTime(2024, 2, 15),
      status: DebtStatus.dueSoon,
      type: 'debt',
    ),
    Debt(
      id: '3',
      name: 'Mike Wilson',
      avatarUrl: '',
      amount: 400,
      dueDate: DateTime(2024, 3, 10),
      status: DebtStatus.pending,
      type: 'debt',
    ),
  ];

  final List<Debt> paidDebts = [
    Debt(
      id: '4',
      name: 'Emma Davis',
      avatarUrl: '',
      amount: 300,
      dueDate: DateTime(2024, 1, 20),
      paidDate: DateTime(2024, 1, 20),
      status: DebtStatus.paid,
      type: 'debt',
    ),
    Debt(
      id: '5',
      name: 'Alex Brown',
      avatarUrl: '',
      amount: 280,
      dueDate: DateTime(2024, 1, 18),
      paidDate: DateTime(2024, 1, 18),
      status: DebtStatus.paid,
      type: 'debt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        150,
      ), // Extra bottom padding for navigation bar and FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards untuk Debt
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Debt',
                  amount: '\$2,450',
                  backgroundColor: const Color(0xFFD32F2F),
                  textColor: const Color(0xFFB71C1C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Paid This Month',
                  amount: '\$580',
                  backgroundColor: const Color(0xFF388E3C),
                  textColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Unpaid Debts Section
          Text(
            'Unpaid (${unpaidDebts.length})',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...unpaidDebts.map((debt) => DebtItem(debt: debt)),
          const SizedBox(height: 32),

          // Paid Debts Section
          Text(
            'Paid (${paidDebts.length})',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...paidDebts.map((debt) => DebtItem(debt: debt)),
        ],
      ),
    );
  }
}
