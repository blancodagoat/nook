import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<int> insert(Transaction transaction);
  Future<int> update(Transaction transaction);
  Future<int> delete(int id);
  Future<Transaction?> getById(int id);
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getByMonth(DateTime month);
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> search(String query);
  Future<List<Transaction>> getRecent({int limit = 10});
  Future<double> getTotalByType(String type, {DateTime? month});
  Future<Map<String, double>> getCategoryTotals({DateTime? month});
  Future<int> getTransactionCount({DateTime? month});
  Future<void> seedData();
}
