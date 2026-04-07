import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Hive.box('transactions'));
});

class TransactionRepository {
  final Box _box;

  TransactionRepository(this._box);

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  Future<void> removeTransaction(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  List<Transaction> getTransactions() {
    final transactions = <Transaction>[];
    for (var key in _box.keys) {
      final item = _box.get(key);
      if (item != null) {
        transactions.add(Transaction.fromJson(item as Map<dynamic, dynamic>));
      }
    }
    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }
}
