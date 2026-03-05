import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nook/data/repositories/transaction_repository_interface.dart';
import 'package:nook/data/repositories/transaction_repository_isar.dart';

final repositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryIsar();
});
