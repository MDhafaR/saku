import 'package:flutter/material.dart';
import 'transaction_item.dart';

class TransactionSection extends StatelessWidget {
  final String sectionTitle;
  final List<TransactionData> transactions;

  const TransactionSection({
    super.key,
    required this.sectionTitle,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...transactions.map(
          (transaction) => TransactionItem(
            category: transaction.category,
            paymentMethod: transaction.paymentMethod,
            amount: transaction.amount,
            icon: transaction.icon,
            iconColor: transaction.iconColor,
            backgroundColor: transaction.backgroundColor,
            isIncome: transaction.isIncome,
          ),
        ),
      ],
    );
  }
}

class TransactionData {
  final String category;
  final String paymentMethod;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isIncome;

  TransactionData({
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.isIncome = false,
  });
}
