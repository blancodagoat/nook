class Transaction {
  int? id;
  
  String title;
  double amount;
  String type; // "income" | "expense"
  String category;
  DateTime date;
  String? note;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, type: $type, category: $category, date: $date)';
  }
}

class DashboardStats {
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;

  DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  double get balance => totalIncome - totalExpense;
}

class CategorySummary {
  final String category;
  final double total;
  final int count;

  CategorySummary({
    required this.category,
    required this.total,
    required this.count,
  });
}

class DailySummary {
  final DateTime date;
  final double income;
  final double expense;

  DailySummary({
    required this.date,
    required this.income,
    required this.expense,
  });
}
