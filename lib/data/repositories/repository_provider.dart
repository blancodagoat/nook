import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_repository_interface.dart';
import 'transaction_repository_isar.dart';

final repositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryIsar();
});
