import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/transaction_repository.dart';

final transactionsProvider = NotifierProvider<TransactionNotifier, List<Transaction>>(TransactionNotifier.new);

class TransactionNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(transaction);
    state = [transaction, ...state]..sort((a, b) => b.date.compareTo(a.date));
  }
  
  Future<void> removeTransaction(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.removeTransaction(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> clearAllTransactions() async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.clearAll();
    state = [];
  }
}

// Derived providers for UI
final summaryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  double income = 0;
  double expenses = 0;
  
  for (var t in transactions) {
    if (t.type == 'income') income += t.amount;
    if (t.type == 'expense') expenses += t.amount;
  }
  
  return {
    'income': income,
    'expenses': expenses,
    'left': income - expenses,
  };
});

/// Map of category name to its metrics (total amount, transaction count)
final categorySummaryProvider = Provider<Map<String, ({double amount, int count, String emoji})>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final Map<String, ({double amount, int count, String emoji})> summary = {};
  
  // Emoji map for quick lookup (matching add_transaction_sheet)
  const emojis = {
    'Food': '🍔',
    'Coffee': '☕',
    'Shopping': '🛍️',
    'Transport': '🚗',
    'Entertainment': '🎮',
    'Health': '💊',
    'Rent': '🏠',
    'Other': '💸',
  };

  for (var t in transactions) {
    if (t.type != 'expense' && t.type != 'debt') continue;
    
    final current = summary[t.category] ?? (amount: 0.0, count: 0, emoji: emojis[t.category] ?? '❓');
    summary[t.category] = (
      amount: current.amount + t.amount,
      count: current.count + 1,
      emoji: current.emoji,
    );
  }
  
  return summary;
});

/// Calculates the consecutive days with at least one transaction.
final streakProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionsProvider);
  if (transactions.isEmpty) return 0;

  final uniqueDates = transactions
      .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (uniqueDates.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // If the last entry is older than yesterday, the streak is broken (0).
  if (uniqueDates.first.isBefore(yesterday)) return 0;

  int streak = 0;
  DateTime currentCheck = uniqueDates.first;

  // Start from the most recent date and count backwards.
  for (var date in uniqueDates) {
    if (date == currentCheck) {
      streak++;
      currentCheck = currentCheck.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
});
