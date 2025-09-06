import 'package:flutter/material.dart';
import '../../../domain/entities/debt.dart';
import '../widgets/summary_card.dart';
import '../widgets/debt_item.dart';

class LoanPage extends StatelessWidget {
  LoanPage({super.key});

  // Sample data untuk loan
  final List<Debt> unpaidLoans = [
    Debt(
      id: '1',
      name: 'Bank ABC',
      avatarUrl: '',
      amount: 5000,
      dueDate: DateTime(2024, 2, 28),
      status: DebtStatus.dueSoon,
      type: 'loan',
    ),
    Debt(
      id: '2',
      name: 'Credit Union XYZ',
      avatarUrl: '',
      amount: 3200,
      dueDate: DateTime(2024, 3, 15),
      status: DebtStatus.pending,
      type: 'loan',
    ),
  ];

  final List<Debt> paidLoans = [
    Debt(
      id: '3',
      name: 'Personal Loan Co',
      avatarUrl: '',
      amount: 1500,
      dueDate: DateTime(2024, 1, 10),
      paidDate: DateTime(2024, 1, 10),
      status: DebtStatus.paid,
      type: 'loan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        164,
      ), // Extra bottom padding for navigation bar and FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards untuk Loan
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Loan',
                  amount: '\$8,200',
                  backgroundColor: const Color(0xFF1976D2),
                  textColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Paid This Month',
                  amount: '\$1,500',
                  backgroundColor: const Color(0xFF388E3C),
                  textColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Unpaid Loans Section
          Text(
            'Unpaid (${unpaidLoans.length})',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...unpaidLoans.map((loan) => DebtItem(debt: loan)),
          const SizedBox(height: 32),

          // Paid Loans Section
          Text(
            'Paid (${paidLoans.length})',
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...paidLoans.map((loan) => DebtItem(debt: loan)),
        ],
      ),
    );
  }
}
