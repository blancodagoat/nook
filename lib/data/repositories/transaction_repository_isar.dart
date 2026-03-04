import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import 'transaction_repository_interface.dart';

class TransactionRepositoryIsar implements TransactionRepository {
  Isar? _isar;

  Future<Isar> get _db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TransactionSchema],
      directory: dir.path,
      inspector: true,
    );
    return _isar!;
  }

  @override
  Future<int> insert(Transaction transaction) async {
    final isar = await _db;
    return await isar.writeTxn(() async {
      return await isar.transactions.put(transaction);
    });
  }

  @override
  Future<int> update(Transaction transaction) async {
    final isar = await _db;
    return await isar.writeTxn(() async {
      await isar.transactions.put(transaction);
      return 1;
    });
  }

  @override
  Future<int> delete(int id) async {
    final isar = await _db;
    return await isar.writeTxn(() async {
      final deleted = await isar.transactions.delete(id);
      return deleted ? 1 : 0;
    });
  }

  @override
  Future<Transaction?> getById(int id) async {
    final isar = await _db;
    return await isar.transactions.get(id);
  }

  @override
  Future<List<Transaction>> getAll() async {
    final isar = await _db;
    return await isar.transactions.where().sortByDateDesc().findAll();
  }

  @override
  Future<List<Transaction>> getByMonth(DateTime month) async {
    final isar = await _db;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return await isar.transactions
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final isar = await _db;
    return await isar.transactions
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> search(String query) async {
    final isar = await _db;
    return await isar.transactions
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .categoryContains(query, caseSensitive: false)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<List<Transaction>> getRecent({int limit = 10}) async {
    final isar = await _db;
    return await isar.transactions.where().sortByDateDesc().limit(limit).findAll();
  }

  @override
  Future<double> getTotalByType(String type, {DateTime? month}) async {
    final isar = await _db;
    
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final transactions = await isar.transactions
          .filter()
          .typeEqualTo(type)
          .dateBetween(startOfMonth, endOfMonth)
          .findAll();
      
      return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
    }
    
    final transactions = await isar.transactions
        .filter()
        .typeEqualTo(type)
        .findAll();
    
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<Map<String, double>> getCategoryTotals({DateTime? month}) async {
    final isar = await _db;
    
    List<Transaction> transactions;
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      transactions = await isar.transactions
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .findAll();
    } else {
      transactions = await isar.transactions.where().findAll();
    }
    
    final Map<String, double> totals = {};
    for (final t in transactions) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    
    return totals;
  }

  @override
  Future<int> getTransactionCount({DateTime? month}) async {
    final isar = await _db;
    
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      return await isar.transactions
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .count();
    }
    
    return await isar.transactions.count();
  }

  @override
  Future<void> seedData() async {
    final isar = await _db;
    final count = await isar.transactions.count();

    if (count == 0) {
      final now = DateTime.now();
      final seedTransactions = [
        Transaction(title: 'Salary', amount: 5000, type: 'income', category: 'Salary', date: now.subtract(const Duration(days: 2))),
        Transaction(title: 'Coffee', amount: 4.50, type: 'expense', category: 'Food & Drink', date: now.subtract(const Duration(days: 1))),
        Transaction(title: 'Groceries', amount: 85.30, type: 'expense', category: 'Food & Drink', date: now.subtract(const Duration(days: 1))),
        Transaction(title: 'Uber', amount: 25.00, type: 'expense', category: 'Transport', date: now.subtract(const Duration(days: 1))),
        Transaction(title: 'Freelance Project', amount: 1200, type: 'income', category: 'Freelance', date: now.subtract(const Duration(days: 3))),
        Transaction(title: 'Movie Tickets', amount: 32.00, type: 'expense', category: 'Entertainment', date: now.subtract(const Duration(days: 4))),
        Transaction(title: 'Electric Bill', amount: 120.00, type: 'expense', category: 'Housing', date: now.subtract(const Duration(days: 5))),
        Transaction(title: 'Pharmacy', amount: 45.00, type: 'expense', category: 'Health', date: now.subtract(const Duration(days: 5))),
        Transaction(title: 'Amazon Purchase', amount: 150.00, type: 'expense', category: 'Shopping', date: now.subtract(const Duration(days: 6))),
        Transaction(title: 'Dividend', amount: 250.00, type: 'income', category: 'Investment', date: now.subtract(const Duration(days: 7))),
      ];

      await isar.writeTxn(() async {
        for (final transaction in seedTransactions) {
          await isar.transactions.put(transaction);
        }
      });
    }
  }
}
