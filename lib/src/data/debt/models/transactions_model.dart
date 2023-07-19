import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../domain/debt/entities/transaction.dart';

part 'transactions_model.g.dart';

@HiveType(typeId: 3)
class TransactionsModel extends HiveObject with EquatableMixin {
  TransactionsModel({
    required this.amount,
    required this.now,
    required this.parentId,
    this.superId,
  });

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime now;

  @HiveField(4, defaultValue: -1)
  int? parentId;

  @HiveField(3)
  int? superId;

  @override
  List<Object?> get props => [
        now,
        amount,
        parentId,
      ];

  Transaction toEntity() => Transaction(
        amount: amount,
        now: now,
        parentId: parentId,
        superId: superId,
      );
}
