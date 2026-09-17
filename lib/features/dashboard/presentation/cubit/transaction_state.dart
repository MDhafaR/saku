import 'package:equatable/equatable.dart';
import '../../../../data/local/database/app_database.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transfer> transfers;

  const TransactionLoaded(this.transactions, [this.transfers = const []]);

  @override
  List<Object?> get props => [transactions, transfers];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}
