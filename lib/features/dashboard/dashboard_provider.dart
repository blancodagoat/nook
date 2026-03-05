import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nook/data/models/transaction.dart';
import 'package:nook/data/repositories/repository_provider.dart';
import 'package:nook/data/repositories/transaction_repository_interface.dart';

// Use the repository provider to ensure singleton
final transactionRepositoryProvider = repositoryProvider;

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final totalIncome = await repo.getTotalByType('income', month: selectedMonth);
  final totalExpense = await repo.getTotalByType('expense', month: selectedMonth);
  final recentTransactions = await repo.getRecent();

  return DashboardStats(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    recentTransactions: recentTransactions,
  );
});

final monthlyTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.getByMonth(selectedMonth);
});

final categoryTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.getCategoryTotals(month: selectedMonth);
});

final transactionCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return repo.getTransactionCount(month: selectedMonth);
});

final allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAll();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filterTypeProvider = StateProvider<String?>((ref) => null);

final filteredTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  final filterType = ref.watch(filterTypeProvider);

  List<Transaction> transactions;

  if (query.isNotEmpty) {
    transactions = await repo.search(query);
  } else {
    transactions = await repo.getAll();
  }

  if (filterType != null && filterType != 'All') {
    transactions = transactions.where((t) => t.type == filterType.toLowerCase()).toList();
  }

  return transactions;
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  TransactionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  final TransactionRepository _repository;
  final Ref _ref;

  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      await _repository.insert(transaction);
      state = const AsyncValue.data(null);
      _ref
        ..invalidate(dashboardStatsProvider)
        ..invalidate(monthlyTransactionsProvider)
        ..invalidate(allTransactionsProvider)
        ..invalidate(categoryTotalsProvider)
        ..invalidate(filteredTransactionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(transaction);
      state = const AsyncValue.data(null);
      _ref
        ..invalidate(dashboardStatsProvider)
        ..invalidate(monthlyTransactionsProvider)
        ..invalidate(allTransactionsProvider)
        ..invalidate(categoryTotalsProvider)
        ..invalidate(filteredTransactionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
      _ref
        ..invalidate(dashboardStatsProvider)
        ..invalidate(monthlyTransactionsProvider)
        ..invalidate(allTransactionsProvider)
        ..invalidate(categoryTotalsProvider)
        ..invalidate(filteredTransactionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repo, ref);
});
