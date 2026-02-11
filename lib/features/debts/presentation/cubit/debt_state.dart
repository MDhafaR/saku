import 'package:equatable/equatable.dart';
import '../../../../data/local/database/app_database.dart';

abstract class DebtState extends Equatable {
  const DebtState();
  @override
  List<Object?> get props => [];
}

class DebtInitial extends DebtState {
  const DebtInitial();
}

class DebtLoading extends DebtState {
  const DebtLoading();
}

class DebtLoaded extends DebtState {
  final List<Debt> debts;
  final Map<int, Person> persons;
  const DebtLoaded(this.debts, this.persons);
  @override
  List<Object?> get props => [debts, persons];
}

class DebtError extends DebtState {
  final String message;
  const DebtError(this.message);
  @override
  List<Object?> get props => [message];
}
