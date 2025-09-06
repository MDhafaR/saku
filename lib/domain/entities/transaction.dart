import 'package:equatable/equatable.dart';

/// Core entity representing a financial transaction.
///
/// A transaction can be an expense or income (`type`), belongs to a category
/// and has a timestamp.  Additional flags (such as whether it has been
/// synchronised) are maintained in the data layer.
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final String category;
  final String type; // 'income' or 'expense'
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, amount, description, category, type, timestamp];
}