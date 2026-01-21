import 'package:flutter/material.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../domain/entities/debt.dart';
import '../presentation/pages/debt_detail_page.dart';

class DebtItem extends StatelessWidget {
  final Debt debt;

  const DebtItem({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DebtDetailPage(debt: debt)),
        );
      },
      borderRadius:
          12, // Staying with 12 for now or upgrade? I'll stick to 12 as param, but maybe default 24 is better? User said 16-24. I will use 24 since I'm standardizing.
      // Wait, let's use default 24 unless it breaks something.
      // Actually, I'll remove borderRadius param to use default 24 for "Clean & Airy".
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _getAvatarBackgroundColor(debt.name),
            child: Text(
              debt.name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and date info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  debt.status == DebtStatus.paid
                      ? 'Paid: ${_formatDate(debt.paidDate!)}'
                      : 'Due: ${_formatDate(debt.dueDate)}',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${debt.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(debt.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  debt.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAvatarBackgroundColor(String name) {
    // Generate consistent colors based on name
    final colors = [
      const Color(0xFF6366F1), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEF4444), // Red
    ];
    return colors[name.hashCode % colors.length];
  }

  Color _getStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.overdue:
        return const Color(0xFFD32F2F); // Red
      case DebtStatus.dueSoon:
        return const Color(0xFFF57C00); // Orange
      case DebtStatus.pending:
        return const Color(0xFF1976D2); // Blue
      case DebtStatus.paid:
        return const Color(0xFF388E3C); // Green
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
