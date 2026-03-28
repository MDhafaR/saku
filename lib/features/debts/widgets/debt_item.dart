import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/components/saku_card.dart';
import '../../../../data/local/database/app_database.dart';
import '../presentation/pages/debt_detail_page.dart';

class DebtItem extends StatelessWidget {
  final Debt debt;
  final String personName;
  final String? phone;

  const DebtItem({
    super.key,
    required this.debt,
    required this.personName,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final remainingAmount = debt.totalAmount - debt.paidAmount;

    return SakuCard(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DebtDetailPage(debt: debt, personName: personName, phone: phone),
          ),
        );
      },
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getAvatarBackgroundColor(personName).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                _getInitials(personName),
                style: TextStyle(
                  color: _getAvatarBackgroundColor(personName),
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Name and date info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    _buildStatusBadge(debt.status),
                    SizedBox(width: 6.w),
                    Text(
                      debt.status == 'paid' && debt.updatedAt != null
                          ? _formatDate(debt.updatedAt)
                          : debt.dueDate != null
                          ? _formatDate(debt.dueDate!)
                          : 'Tanpa jatuh tempo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10.sp,
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
                'Rp${_formatAmount(debt.status == 'paid' ? debt.totalAmount : remainingAmount)}',
                style: TextStyle(
                  color: debt.type == 'debt'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'overdue':
        return 'Overdue';
      case 'due_soon':
        return 'Due Soon';
      case 'paid':
        return 'Paid';
      default:
        return 'Pending';
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
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
    return colors[name.hashCode.abs() % colors.length];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'overdue':
        return const Color(0xFFEF4444); // Red
      case 'due_soon':
        return const Color(0xFFF59E0B); // Amber
      case 'paid':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF3B82F6); // Blue
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
