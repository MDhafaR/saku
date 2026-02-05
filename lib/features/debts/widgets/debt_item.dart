import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../domain/entities/debt.dart';
import '../presentation/pages/debt_detail_page.dart';

class DebtItem extends StatelessWidget {
  final Debt debt;

  const DebtItem({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
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
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _getAvatarBackgroundColor(debt.name).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                _getInitials(debt.name),
                style: TextStyle(
                  color: _getAvatarBackgroundColor(debt.name),
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          // Name and date info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildStatusBadge(debt.status),
                    SizedBox(width: 8.w),
                    Text(
                      debt.status == DebtStatus.paid
                          ? _formatDate(debt.paidDate!)
                          : _formatDate(debt.dueDate),
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12.sp,
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
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DebtStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11.sp,
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
