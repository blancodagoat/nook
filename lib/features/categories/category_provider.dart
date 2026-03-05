import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nook/data/models/custom_category.dart';
import 'package:nook/data/repositories/custom_category_repository.dart';

final customCategoryRepositoryProvider = Provider<CustomCategoryRepository>((ref) {
  return CustomCategoryRepository();
});

final customCategoriesProvider = FutureProvider<List<CustomCategory>>((ref) async {
  final repo = ref.watch(customCategoryRepositoryProvider);
  return repo.getAll();
});
