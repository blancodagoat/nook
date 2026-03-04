import '../models/transaction.dart';
import 'transaction_repository_interface.dart';

/// MOCK REPOSITORY FOR WEB TESTING ONLY
/// 
/// This is a simple in-memory mock for web testing.
/// DELETE THIS FILE when you're done testing on web - 
/// the iOS app will use TransactionRepositorySqflite instead.
/// 
/// To remove web support later:
/// 1. Delete this file
/// 2. In main.dart, remove the kIsWeb check and always use TransactionRepositorySqflite
/// 3. Remove sqflite_common_ffi_web from pubspec.yaml
/// 4. Delete web/sqflite_sw.js and web/sqlite3.wasm
class TransactionRepositoryMock implements TransactionRepository {
  final List<Transaction> _transactions = [];
  int _nextId = 1;
  bool _seeded = false;

  @override
  Future<int> insert(Transaction transaction) async {
    final newTransaction = transaction.copyWith(id: _nextId++);
    _transactions.add(newTransaction);
    return newTransaction.id!;
  }

  @override
  Future<int> update(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> delete(int id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index >= 0) {
      _transactions.removeAt(index);
      return 1;
    }
    return 0;
  }

  @override
  Future<Transaction?> getById(int id) async {
    return _transactions.cast<Transaction?>().firstWhere(
      (t) => t!.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<List<Transaction>> getAll() async {
    return List.unmodifiable(_transactions..sort((a, b) => b.date.compareTo(a.date)));
  }

  @override
  Future<List<Transaction>> getByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    return _transactions
      .where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) 
        && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1))))
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return _transactions
      .where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) 
        && t.date.isBefore(end.add(const Duration(seconds: 1))))
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    return _transactions
      .where((t) => t.title.toLowerCase().contains(lowerQuery) 
        || t.category.toLowerCase().contains(lowerQuery))
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Transaction>> getRecent({int limit = 10}) async {
    return _transactions
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(limit).toList();
  }

  @override
  Future<double> getTotalByType(String type, {DateTime? month}) async {
    var transactions = _transactions.where((t) => t.type == type);
    
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      transactions = transactions.where((t) => 
        t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) 
        && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1))));
    }
    
    return transactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<Map<String, double>> getCategoryTotals({DateTime? month}) async {
    var transactions = _transactions;
    
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      transactions = transactions.where((t) => 
        t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) 
        && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)))).toList();
    }
    
    final Map<String, double> totals = {};
    for (final t in transactions) {
      totals[t.category] = (totals[t.category] ?? 0.0) + t.amount;
    }
    return totals;
  }

  @override
  Future<int> getTransactionCount({DateTime? month}) async {
    if (month == null) return _transactions.length;
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    return _transactions.where((t) => 
      t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) 
      && t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)))).length;
  }

  @override
  Future<void> seedData() async {
    if (_seeded) return;
    
    final now = DateTime.now();
    final seedTransactions = [
      Transaction(id: _nextId++, title: 'Salary', amount: 5000, type: 'income', category: 'Salary', date: now.subtract(const Duration(days: 2))),
      Transaction(id: _nextId++, title: 'Coffee', amount: 4.50, type: 'expense', category: 'Food & Drink', date: now.subtract(const Duration(days: 1))),
      Transaction(id: _nextId++, title: 'Groceries', amount: 85.30, type: 'expense', category: 'Food & Drink', date: now.subtract(const Duration(days: 1))),
      Transaction(id: _nextId++, title: 'Uber', amount: 25.00, type: 'expense', category: 'Transport', date: now.subtract(const Duration(days: 1))),
      Transaction(id: _nextId++, title: 'Freelance Project', amount: 1200, type: 'income', category: 'Freelance', date: now.subtract(const Duration(days: 3))),
      Transaction(id: _nextId++, title: 'Movie Tickets', amount: 32.00, type: 'expense', category: 'Entertainment', date: now.subtract(const Duration(days: 4))),
      Transaction(id: _nextId++, title: 'Electric Bill', amount: 120.00, type: 'expense', category: 'Housing', date: now.subtract(const Duration(days: 5))),
      Transaction(id: _nextId++, title: 'Pharmacy', amount: 45.00, type: 'expense', category: 'Health', date: now.subtract(const Duration(days: 5))),
      Transaction(id: _nextId++, title: 'Amazon Purchase', amount: 150.00, type: 'expense', category: 'Shopping', date: now.subtract(const Duration(days: 6))),
      Transaction(id: _nextId++, title: 'Dividend', amount: 250.00, type: 'income', category: 'Investment', date: now.subtract(const Duration(days: 7))),
    ];
    
    _transactions.addAll(seedTransactions);
    _seeded = true;
  }
}
