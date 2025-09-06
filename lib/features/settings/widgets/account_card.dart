import 'package:flutter/material.dart';
import '../../../../domain/entities/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: account.iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(account.iconPath),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Account info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rp ${_formatCurrency(account.balance)}',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF999999),
            size: 16,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'ovo':
        return Icons.payment;
      case 'dana':
        return Icons.mobile_friendly;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
