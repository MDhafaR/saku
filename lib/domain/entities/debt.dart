class Debt {
  final String id;
  final String name;
  final String avatarUrl;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final DebtStatus status;
  final String type; // 'debt' or 'loan'

  Debt({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    required this.type,
  });
}

enum DebtStatus { overdue, dueSoon, pending, paid }

extension DebtStatusExtension on DebtStatus {
  String get displayName {
    switch (this) {
      case DebtStatus.overdue:
        return 'Overdue';
      case DebtStatus.dueSoon:
        return 'Due Soon';
      case DebtStatus.pending:
        return 'Pending';
      case DebtStatus.paid:
        return 'Paid';
    }
  }
}
