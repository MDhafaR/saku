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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DebtDetailPage(debt: debt)),
        );
      },
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getAvatarBackgroundColor(debt.name).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _getInitials(debt.name),
                style: TextStyle(
                  color: _getAvatarBackgroundColor(debt.name),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name and date info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusBadge(debt.status),
                    const SizedBox(width: 8),
                    Text(
                      debt.status == DebtStatus.paid
                          ? _formatDate(debt.paidDate!)
                          : _formatDate(debt.dueDate),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp${_formatAmount(debt.amount)}',
                style: TextStyle(
                  color: debt.type == 'debt'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DebtStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  String _formatAmount(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return formatted;
  }

  Color _getAvatarBackgroundColor(String name) {
    final colors = [
      const Color(0xFF6366F1), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFFEC4899), // Pink
    ];
    return colors[name.hashCode % colors.length];
  }

  Color _getStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.overdue:
        return const Color(0xFFEF4444); // Red
      case DebtStatus.dueSoon:
        return const Color(0xFFF59E0B); // Amber
      case DebtStatus.pending:
        return const Color(0xFF3B82F6); // Blue
      case DebtStatus.paid:
        return const Color(0xFF10B981); // Green
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
